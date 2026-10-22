# Personal preferences

## Posting to GitLab and other shared places
- Never post comments, reviews or replies on MRs/issues unless I ask. When I ask for a review, keep it local and report back to me here.
- When I do ask you to post, start the comment by saying it's from an AI agent, e.g. `_🤖 From agent._`
  - Skip that header when I've reviewed and approved the exact text before it's posted; it then goes out as mine.
  - Never put the header in issue or MR descriptions.
- Keep posted comments very concise. Say what's decided and why in a few sentences, with no preamble.
- All posted comments should use natural human language and be understandable by someone without in-depth domain knowledge.

### Slack
- Never send messages, replies, drafts, scheduled messages or reactions on my behalf unless I explicitly ask
- When I do ask, show me the exact content and wait for my approval before sending
- Reading and searching Slack is fine without asking
- Do not add the sent with claude trailer

### Google Drive and Google Docs
- Never create, update, copy, share, or trash files without my explicit permission
- When I do ask, show me the content first and wait for my approval before writing
- Reading and searching Drive is fine without asking

### Merge requests
- Keep the description concise and easily understandable by someone without domain knowledge
- It should be clear why a change is being made versus just describing what changed
- Do not explain specific code changes. That is easily seen in the diff
- When requesting a review add a comment with a polite review request from the selected reviewer in addition to the actual review request. Do not add an agent header to the comment.

## Git
- Don't commit or push unless I ask
- Never add the agent co-authoried trailer

## Write-ups
- Default to short and easily understandable. I'll ask if I want more detail.

<!-- orbit:setup:begin -->
## Orbit

Prefer `glab orbit` commands to bash tools for file/code search and callers/callees. Grep means `glab orbit grep`.

- Unknown code? `glab orbit grep 'words'`. FTS. Terms AND; `a|b` OR.
- grep shows IDs and file:lines. Source? `glab orbit context path:120-180`. Callers/callees? `glab orbit context Definition:123`.
- Do not reread unchanged files. Reuse shown source.
- Need file map? `glab orbit context path`. Directory? `glab orbit context dir`.
- Too broad? Add `--path`/`--kind`.
<!-- orbit:setup:end -->
