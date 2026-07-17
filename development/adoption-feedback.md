# Adoption Feedback

This file belongs only to the template repository's research and development process. It is not deployed to target projects and must not record target-project business requirements, code details, experiment data, or sensitive information.

Treat every finding as a candidate. Promote a finding to `template/` or a future deployment Skill only after validation and explicit approval. Temporary findings may be closed, archived, or deleted when they no longer provide value.

## Active Adoption

- Target type: mature Windows Qt project.
- Adoption result: framework files installed; control-plane migration rejected before commit.
- Deployment changes were never released or committed to the target project.

## Observed Friction

1. **dual_control_plane:** A compatibility migration retained `REQUIREMENTS.md`, `tasks.md`, and `PROJECT_CONTEXT.md` while introducing `LOOP.md`, `STATE.md`, `STATE_MACHINE.md`, and `LOG.md`, creating two control planes for requirements, plans, state, acceptance, and history.
2. **legacy_control_files_misclassified:** `tasks.md` was legacy task state; `REQUIREMENTS.md` combined approval and completion state; and `PROJECT_CONTEXT.md` combined instructions, map, workflow, and current facts. Only `PROJECT_PROGRESS.md` was an independent human deliverable to retain.
3. **state_weakened_for_legacy_compatibility:** Retaining `tasks.md` reduced deployed STATE to a pointer and prevented it from taking over current-task responsibility.
4. **deployment_logged_in_target:** Deployment activity was written to target `tasks`, STATE, and LOG. Deployment must remain an external template-repository process; only a completed deployment's real project Loops belong in target LOOP/STATE/LOG.
5. **source_provenance_missing:** The deployment report lacked verifiable Source Commit, Template Tree Hash, Source Worktree Clean, and Deployment Source information.

## Template Gaps

- **bootstrap_state_validation:** Validate whether the latest template defines a legal clean initialization with no active Loop. Do not invent a target-project Stage or create a completed deployment Loop.

## Deployment Prompt Gaps

- **migration_mode_and_provenance:** Deployment guidance needs an explicit migration choice, legacy-control-file classification, and source-provenance record.

## Candidate Changes

- Add explicit compatibility-migration and replacement-migration choices; default to replacement when files are confirmed legacy Agent control files.
- Classify pre-existing files as project assets, human deliverables, or legacy Agent control files before deployment.
- Keep deployment itself out of target LOOP/STATE/LOG and record template source commit and tree hash at deployment start.
- Require a content-coverage audit before deleting legacy control files; move lasting information to passive, on-demand project documentation rather than a second control plane.

## Validation Needed

- Whether the latest template supports legal no-active-Loop initialization.
- Whether replacement migration lets new LOOP/STATE independently align requirements, plan, execute, verify, and recover after legacy control files are removed.
- Whether passive long-term specification documents avoid increasing daily context.
- Whether the first real Lite and Standard tasks operate without any legacy control files.

## Decisions

- Keep all findings from this single adoption as candidates; do not change formal template rules without validation and approval.

## Closed Findings

- None. The rejected deployment introduced no released or committed target-project change.
