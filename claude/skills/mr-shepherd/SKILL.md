---
name: mr-shepherd
description: Watch a set of GitLab merge requests and keep them moving. Reports new reviewer and GitLab Duo comments, failed pipelines, merge conflicts and merges, then addresses each one (fixes review feedback, rebases conflicts, triages CI failures) within the user's rules. One hub session watches every MR; other sessions hand MRs to it with `add`. Use when the user asks to monitor, babysit or shepherd MRs through review, or invoke with /mr-shepherd [add] [mr-iids...].
argument-hint: "[add] [mr-iids...]"
---

# MR shepherd

All MRs are watched from one place: a single hub session and one shared state dir, `~/.claude/mr-shepherd/`. This avoids two sessions acting on the same event.

- **`/mr-shepherd add <iids>`** (in any session): hand the MRs to the hub. See "Hand off MRs". Don't start a watcher.
- **`/mr-shepherd [iids]`**: become the hub and watch **$ARGUMENTS** (or the ones the user names) in `gitlab-org/gitlab` until they merge, and handle what comes up. If a hub is already running, hand the MRs off instead.

## Hand off MRs

1. Add them: `python3 ~/.claude/skills/mr-shepherd/scripts/watch.py add <iids>`. It prints each handoff note's path and whether a watcher is running.
2. For each MR, write the handoff note at that path (`~/.claude/mr-shepherd/notes/<iid>.md`), so the hub doesn't start from nothing. Keep it short:
   ```
   # !<iid> <title>
   Why: <what the MR is for, one or two lines>
   Reviewers: <who, and whether they've been asked>
   Approved by the user: <actions already OK'd, e.g. "resolve answered Duo threads", or "none">
   Open: <anything still pending or waiting on the user>
   ```
   If a note already exists, add to it rather than replacing it.
3. If a hub is running, tell it: use `ListAgents`, find the session named `mr-shepherd`, and `SendMessage` it `added !<iid>, see notes/<iid>.md`. If there's no hub, tell the user the MRs are queued and that `/mr-shepherd` in any session starts the hub.
4. Stop. The hub handles everything from here, so don't watch, fix or post for these MRs in this session.

## Start the watch (hub)

1. Name this session `mr-shepherd` (`/rename mr-shepherd`) so other sessions can find it.
2. Add any MRs from the arguments with `watch.py add` (as in "Hand off MRs").
3. Start one Monitor:
   ```
   python3 ~/.claude/skills/mr-shepherd/scripts/watch.py 2>&1 | grep --line-buffered -E '^!|Traceback|Error'
   ```
   with `timeout_ms: 1800000`. The watcher exits on its own before the timeout (`! WATCH WINDOW ENDED`); re-arm it with the same command. The state file stops events repeating.
4. If it prints `! WATCHER ALREADY RUNNING (pid …, cwd …)`, another session is the hub. Don't start a second one: hand the MRs off instead, and tell the user where the hub is running. If the user says that hub is gone, check the pid with `ps` before killing it.
5. Before the first event, check each MR once by hand: pipeline, approvals, unresolved threads, conflicts, and its handoff note if it has one. The first pass only records existing notes.
6. Each time an MR is added later, the watcher prints `!123 ADDED to watch; handoff note: <path>`. Read the note, then do the same check by hand. Its existing comments aren't replayed.

Events look like `!123 user: comment… <link>`, `!123 BOT OPEN THREAD project_278964_bot_…: suggestion… <link>`, `!123 PIPELINE failed: <url>`, `!123 HAS CONFLICTS (branch)`, `!123 AUTO-MERGE BLOCKED by 2 unresolved thread(s) started by: …`, `!123 APPROVAL RESET for: alice (…)`, `!123 ADDED to watch; …`, `!123 MERGED, no longer watching`.

## Work in a separate worktree

Never edit or switch branches in the user's checkout. Use a scratch worktree on `origin/master` (`git worktree add <scratchpad>/wt origin/master`, then symlink `config/database.yml` and `config/gitlab.yml` from the main checkout). For each MR: `git checkout -B <branch> origin/<branch>`, change, check, push, then go back to a detached `origin/master`.

## Handling each event

### Reviewer comment (a person)
- Read the full note and its position (`glab api .../notes/<id>`). Check the claim against the code before acting.
- If it asks for a change inside the MR's scope, make the smallest change that does it, run rubocop and the affected specs, push, and reply on the thread.
- If it asks a design or policy question, or wants work beyond the MR, bring it to the user with a recommendation. Don't act on it yet.
- Never resolve a reviewer's thread. They resolve their own.

### GitLab Duo comment
- Always tag `@GitLabDuo` in the reply, or the agent won't see it.
- Verify the finding. If it's right, fix it and say so. If it's wrong, reply with the evidence (file:line, gem version, the rule that covers it). Don't just disagree.
- If Duo's state stays "requested changes" after it accepts a reply, offer to re-request its review (`/request_review @GitLabDuo` as a quick-action-only note).
- Resolve an answered Duo thread only if the user has said that's OK.

### Other bot comments (Danger, test summaries, and similar)
The watcher reports every bot comment, tagged `BOT`. Never ignore them. Danger's suggestions open resolvable threads (tagged `OPEN THREAD`) that block merging just like a reviewer's.
- **Status notes** with no thread, such as the reviewer roulette table or a test result summary: read them for anything actionable, such as suggested reviewers or failed tests, and mention what matters in the update. Nothing to reply to.
- **Suggestion threads:** check each suggestion against the code. Apply it if it's right and in scope, then push. If it's wrong or out of scope, reply with the reason (for example, "order matters here, so `match_array` would hide a swap"). Bring the list to the user with a recommendation for each, since replying and resolving need their OK.
- A thread is still open until it's resolved, even after a reply. Check `detailed_merge_status` for `discussions_not_resolved`.

### Approval bot risk-rating thread
- It's informational, but it blocks merging while it's unresolved. Resolve it only with the user's OK. It may re-post after a push.

### Failed pipeline
1. List failed jobs: `pipelines/<id>/jobs?scope=failed`. Also check child pipelines: `pipelines/<id>/bridges`, then their jobs.
2. Read each log and classify it:
   - **Caused by the MR:** fix it.
   - **Infrastructure:** artifact upload, DNS or runner errors. Look for "N examples, 0 failures" followed by an upload or runner error.
   - **Flaky or broken master:** a test unrelated to the diff.
   - **`pre-merge-checks` on a merge train:** the MR's own pipeline was still running when the train started.
3. For anything not caused by the MR, check the CI health trackers (`gitlab-org/quality/analytics/ci-health-incidents`, `ci-health-systemic`, `gitlab-org/quality/test-failure-issues`) and look for an open quarantine MR. Link what you find.
4. Retry failed jobs automatically, without asking: `POST jobs/<id>/retry`. Retry each job at most 3 times. Count earlier attempts of the same job name in that pipeline (`pipelines/<id>/jobs?include_retried=true`). A failure caused by the MR needs a fix, not a retry. After 3 failed retries, stop and report the job and its latest error to the user.
5. Ask before starting a new pipeline.

### Stuck pipeline
A pipeline can sit in `running` for hours with nothing running. Each time a watch expires, check every watched MR's head pipeline if it has been running for more than 2 hours:
1. List unfinished jobs across pages: `pipelines/<id>/jobs?per_page=100&page=N`, looking for `created`, `pending` and `running`. List bridges: `pipelines/<id>/bridges`.
2. It's stuck when no job is `running` and a bridge's downstream pipeline (often in another project, such as gitlab-foss `13083`) has stayed `created` or `pending` for 30+ minutes, with none of its jobs started. Check it with `projects/<downstream project_id>/pipelines/<id>`.
3. Restart it without asking. Cancel the stuck downstream pipeline (`POST projects/<project_id>/pipelines/<id>/cancel`). Once its bridge shows `canceled`, retry the bridge (`POST jobs/<bridge id>/retry`). Then confirm the new downstream pipeline has started jobs.
4. Each restart counts toward the bridge's 3 retries. After 3, stop and report it to the user.

### Merge conflict
- Rebase in the worktree: `git rebase origin/master`. Before resolving, read the master commit that conflicts (`git log <merge-base>..origin/master -- <file>`, then `git show`).
- Keep both intents. For example, add master's new permission to the MR's sorted list, or keep a reviewer's fresh rewrite instead of undoing it.
- If a 3-way merge looks muddled, rebuild that file instead: take the MR's version and port master's commits onto it by hand. Then diff the result against the MR's version to confirm only master's changes differ.
- After resolving, run `ruby -c` and rubocop, push with `git push --force-with-lease`, and confirm `has_conflicts` is false.

### Auto-merge set but threads unresolved
An MR set to merge when the pipeline succeeds won't merge while any thread is open. It just sits there. Whenever an MR has auto-merge on (the `AUTO-MERGE BLOCKED` event, or `merge_when_pipeline_succeeds: true` when you check it), make sure every thread is resolved:
- **Answered GitLab Duo threads** and **approval bot risk-rating threads:** resolve them if the user has OK'd that, otherwise ask. Before resolving a Duo thread, confirm it's answered: we replied, and either Duo accepted the reply or a later Duo review was clean.
- **Duo threads with no reply yet:** handle them as Duo comments above, then resolve.
- **Reviewer threads:** don't resolve them yourself. If you've replied and it's waiting on the reviewer, tell the user which reviewer and thread are holding up the merge. They can ask the reviewer, or tell you to post a short note there.
- Re-check `detailed_merge_status` afterwards. It should move off `discussions_not_resolved`.

### Approval reset after a push
A push can reset approvals, depending on the project's settings. After every push, check `merge_requests/<iid>/approvals`. The watcher also reports `APPROVAL RESET`. For each person whose approval was dropped (bots like GitLab Duo excepted):
- Re-request their review: `PUT merge_requests/<iid>` with `reviewer_ids` that keep the existing reviewers, or post a note with only `/request_review @<user>`.
- Post a short comment tagging them, saying what changed since they approved and asking them to take another look. Name the commit SHA.
- Doing this after your own push is part of the push. It needs no separate OK.

### Fully approved
The watcher reports `FULLY APPROVED` once no approvals are left and auto-merge isn't set. If the user has asked you to finish approved MRs:
1. Add the `pipeline::tier-3` label if it isn't there (`PUT merge_requests/<iid>` with `add_labels`).
2. Start a new pipeline: `POST merge_requests/<iid>/pipelines`.
3. Set auto-merge: `PUT merge_requests/<iid>/merge` with `merge_when_pipeline_succeeds=true` and `sha=<head sha>`.
4. Then make sure every thread is resolved (see the auto-merge section above).
Otherwise, tell the user it's ready and ask.

### Merged or closed
- The watcher drops it from `mrs.txt`. Report it in one line. If the merge unblocks follow-up work you'd planned, say so.

## Posting rules

- Replies start with `_🤖 From agent._`, unless the user approved the exact text, in which case leave the header off. Keep replies to a sentence or two and plain, and name the commit SHA that fixes it.
- Never post, re-request reviews, resolve threads or start pipelines without the user's OK, unless they've already approved that kind of action in this session. Retrying failed jobs and restarting stuck downstream pipelines need no OK (up to 3 retries per job, see "Failed pipeline" and "Stuck pipeline").
- Don't claim anything you haven't checked. If you got something wrong in a posted reply, edit the reply.

## Checks before every push

- Rubocop on the changed files. For spec changes, run the affected specs locally. Use the user's serialized rspec wrapper if there is one, since concurrent runs deadlock the shared test DB.
- If the local test environment lags master (gems, schema, Gitaly), test on the closest commit you can and say plainly that CI is the first full run.
- Commit subject at most 72 characters, body lines at most 72, and a body when the commit touches 30+ lines across 3+ files.
- If a pre-push hook fails because of the local environment rather than the change (for example `openapi_docs` when master's docs are stale locally), exclude only that hook (`LEFTHOOK_EXCLUDE=openapi_docs`) and mention it.

## Gotchas learned the hard way

- **zsh doesn't split `$VAR` into words.** Wrap multi-file shell loops in `bash -c '...'`, or arguments arrive as one string.
- **Don't use `git stash` in worktrees.** The stash list is shared with the user's checkout. Copy files to the scratchpad or commit instead. If you stash by mistake, check it matches your copy, then drop it.
- **Write scripts with the Write tool,** not heredocs. Shell escaping corrupts regexes and backslashes.
- **Check a bulk conversion script on one file first,** and run `ruby -c` on everything it touched.
- **After master moves, `bundle install` in the worktree** if commands fail with `Bundler::GemNotFound`. Then `git checkout -- Gemfile.lock`.
- **Re-check a branch after a force-push** with `git ls-remote origin refs/heads/<branch>`.
- **A failed pre-commit hook doesn't stop a chained push.** Check `git log -1` shows the new commit before pushing or opening an MR, or you'll push an empty branch.

## Reporting

After each event, give the user a short update: what happened, what you did (with SHAs and links), and anything waiting on them. Collect open questions together instead of asking one at a time. When nothing happens, say so in one line per expiry.
