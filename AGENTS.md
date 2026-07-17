# Repository Maintenance Instructions

## Repository Purpose

This repository maintains a deployable Agent Loop Engineering template. The current V0 scope contains only Lite and Standard workflows.

- `README.md` is for template maintainers.
- `template/` contains product files intended for deployment to target projects.

## Source Repository and Deployed Artifact Boundary

This root `AGENTS.md` governs maintenance of this source repository.

- `template/AGENTS.md` is a deployed artifact, not the Workflow router for the current repository-maintenance task.
- Do not use `template/.agent/STATE.md` to record repository-maintenance progress.
- When reviewing or editing `template/`, treat its contents as product artifacts, not as the source repository's current runtime state.
- When maintaining this repository, follow this file even when the task changes a file below `template/`.

## Maintenance Rules

1. Before modifying files, check Git status and upstream state.
2. Preserve user changes and do not overwrite unrelated work.
3. Do not expand the approved V0 scope without user approval.
4. Before changing a template contract, Workflow Skill, or golden rule, state the intended impact.
5. Do not add Strict Workflow, Hook, multi-Agent, deployment tooling, Worktree, CLI, or automatic model-selection capabilities unless explicitly approved.
6. Treat build, formatting, and test results as evidence; also perform semantic consistency checks appropriate to the change.
7. Do not commit or push unless the user explicitly requests it.

## Minimum Validation

Check, as applicable:

- the expected file set and directory structure;
- `.agent/` and `.agents/` path references;
- Standard Workflow to State Stage mapping;
- LOOP Success Criteria identifiers against STATE references;
- Workflow Skill frontmatter;
- mutually exclusive Lite and Standard trigger conditions;
- after changing template structure, Skills, or protocol files, run `scripts/check-template.ps1` and its corresponding test before final acceptance;
- `git diff --check`; and
- `git status`.

Do not duplicate the deployable `template/AGENTS.md` golden rules or Workflow details here.
