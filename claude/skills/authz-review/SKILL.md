---
name: authz-review
description: Review a GitLab merge request for authorization correctness. Checks out the MR branch, reads the team's authorization guidelines, and provides structured feedback focused on policy design, permission conventions, and testing patterns. Use when reviewing authorization-related MRs, or invoke with /review-authz [mr-number].
argument-hint: "[mr-number]"
disable-model-invocation: true
allowed-tools: Bash(glab mr view:*), Bash(glab mr checkout:*), Bash(git log:*), Bash(git show:*), Bash(git diff:*), Bash(git branch:*), Read, Grep, Glob
---

# Authorization MR Review

Review GitLab merge request **!$0** for authorization correctness.

## Step 1: Load Authorization Guidelines

Read the team's authorization documentation to use as the review lens:

```
doc/development/permissions.md
doc/development/permissions/review_guidelines.md
doc/development/permissions/conventions.md
doc/development/permissions/authorizations.md
doc/development/permissions/testing_guidelines.md
```

These documents are the source of truth for this review. Do not apply rules from
memory — apply only what is documented there.

## Step 2: Fetch MR Information and Checkout Branch

1. Run `glab mr view -c $0` to get:
   - MR title, description, and labels
   - Author and reviewers
   - MR comments and any existing review threads
   - Source and target branches (note the target branch)
2. Run `glab mr checkout $0` to checkout the MR branch
3. Identify the changes compared to the target branch:
   - `git log <target-branch>..HEAD --oneline`
   - `git diff <target-branch>...HEAD --stat`
   - `git diff <target-branch>...HEAD --name-only`

## Step 3: Understand the Changes in Full Context

1. **Read changed files completely** using the Read tool — do not rely only on diffs
2. For every policy file changed, also read the full policy class to understand the surrounding rules
3. Use Grep to find all usages of any new or renamed permissions across the codebase
4. Check for corresponding spec files and read them in full
5. If a condition's `:scope` is set or changed, grep for other usages of that condition to assess cache-sharing impact

## Step 4: Analyze Against Authorization Guidelines

Work through the following checklist. For each item, note whether it passes,
has a concern, or is not applicable to this MR.

### Permission Design (from `conventions.md`)

- [ ] Is a new permission actually needed, or does an existing one cover this?
- [ ] Does the permission name follow `action_resource` format?
- [ ] Is the action from the preferred set (`create`, `read`, `update`, `delete`), or is a non-standard action justified?
- [ ] Are disallowed action words used (`admin`, `manage`, `write`, `view`, `edit`, `list`)?
- [ ] Does the permission name encode a resource boundary (`_project_`, `_group_`) that should be removed?
- [ ] Is a permission definition file present (`config/authz/permissions/...`)?

### Policy Structure (from `review_guidelines.md`)

- [ ] Are all rules for the same condition grouped in one `.policy` block?
- [ ] Are any permissions enabled in `BasePolicy`? (must not be)
- [ ] Are any permission names constructed dynamically at runtime? (must not be)
- [ ] Is `:scope` set correctly on all conditions? (`:user` = user data only, `:subject` = subject data only, `:global` = neither, no scope = both)
- [ ] Are permissions cascaded through intermediate abilities? (prefer direct grants)
- [ ] Are nested `rule { role & condition }` blocks used instead of `prevent`? (anti-pattern)
- [ ] Are `admin | owner` rules present? (redundant, `owner` covers `admin`)
- [ ] Are OR conditions used as shorthand (e.g. `planner_or_reporter_access`)? (use separate rules)

### Where Permissions Are Checked (from `authorizations.md`)

- [ ] Is authorization enforced in the service or finder layer, not only at the API/controller layer?
- [ ] If a frontend ability check is added, is there a corresponding backend check?
- [ ] Is `push_frontend_ability` used for JavaScript/Vue ability checks?

### Testing (from `testing_guidelines.md`)

- [ ] Is there one `describe` block per permission? (not grouped)
- [ ] Does every role table include all roles explicitly, including those expected to be disallowed?
- [ ] Is `let_it_be` for the subject defined inside each `describe` block, not at the top scope?
- [ ] Does the subject fixture have a descriptive name (`private_project`, `public_project`) rather than generic `project`?
- [ ] Are `expect_allowed` / `expect_disallowed` helpers used instead of `be_allowed`?
- [ ] Are feature flag and licensed feature contexts present where relevant?
- [ ] Is admin mode tested in both enabled and disabled states where relevant?

## Step 5: Provide Structured Feedback

### Summary
[One sentence: what authorization change does this MR make?]

### What's Done Well
[Specific positive observations, especially where guidelines are followed well]

### Concerns

Group by severity:

**Blocking** — guideline violations that must be fixed before merge:
- [file:line] description of issue and which guideline it violates

**Non-blocking** — suggestions that improve correctness or consistency:
- [file:line] description and rationale

### Questions
[Clarifying questions for the author — e.g. intended access level for a new permission, rationale for a non-standard action name]

### Recommendation
[One of: ✅ Approve | ⚠️ Request Changes | 💬 Comment]

---

## Review Tone Guidelines

- Be specific: reference file paths and line numbers
- Distinguish blocking from non-blocking clearly
- Link to the relevant guideline doc and section when flagging a violation — the author should be able to read the rule themselves
- If the intent of a change is unclear, ask before assuming it's wrong
- Acknowledge when the MR follows guidelines well — positive reinforcement helps the conventions stick

