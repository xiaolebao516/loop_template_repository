# Adoption Feedback

This file belongs only to the template repository's research and development process. It is not deployed to target projects and must not record target-project business requirements, code details, experiment data, or sensitive information.

Treat every finding as a candidate. Promote a finding to `template/` or a future Skill only after validation and explicit approval. Temporary findings may be closed, archived, or deleted when they no longer provide value.

## Active Adoption

- A replacement migration succeeded in the first mature Windows Qt project; one Loop control plane replaced the legacy Agent control files.
- The inactive bootstrap passed in the real deployment. Source Commit, Template Tree Hash, and clean-worktree gates correctly stopped deployment from an outdated template source.
- The first real Standard Loop, DOC-001, completed. Its project-governance work used the reference/work separation introduced by this MVP update.
- DOC-001 was interrupted by account usage limits and later closed successfully. This does not by itself prove cross-session recovery from repository state alone.

## Observed Friction

- Tool-level replacement of high-risk files may require a second human authorization after the risk is explained.

## Template Gaps

- None active after the inactive bootstrap and reference/work MVP contracts were defined. Remaining evidence needs are tracked below.

## Deployment Prompt Gaps

- None active. Replacement migration classification and source-provenance gates were validated in the first mature-project adoption.

## Candidate Changes

- Human-document audit and layering may become a Skill candidate if it recurs with clear net benefit.
- Weekly or project-report generation may become a separate Skill candidate under the same evidence threshold.

## Validation Needed

- **Independent Lite:** Does not read STATE_MACHINE, create work, or modify LOOP / STATE / LOG; reads only an exact reference file when needed.
- **True cross-session Standard recovery:** A new session resumes only from LOOP, STATE, exact reference files, and necessary work, without old conversation context.
- **Multiple real Loops:** Confirm the minimal LOG remains sufficient and the boundary between a completed instance and the next initialization remains clear.
- **Approval paths:** Validate combined approval, partial approval, and recovery after awaiting-approval.
- **Cross-project use:** Validate reference/work in a different project type before adding any further default structure.
- **Skill candidates:** Reconsider human-document audit/layering and weekly/project reporting only after repeated evidence of net benefit.

## Decisions

- Inactive is lifecycle metadata, not an eleventh Stage.
- Deployment activity never enters target-project LOOP, STATE, or LOG.
- Replacement migration classifies and migrates legacy Agent control files instead of retaining a compatibility control plane.
- Reference and work are general Loop information layers: reference holds task-selected durable Agent material, while work holds optional temporary complex-Loop material.
- Human-document directories, weekly reports, and legacy-document governance remain project adaptations or future Skill candidates, not generic template defaults.

## Closed Findings

- **dual_control_plane / legacy_control_files_misclassified / state_weakened_for_legacy_compatibility:** Closed by the successful replacement migration and single Loop control plane.
- **deployment_logged_in_target:** Closed by keeping deployment history outside target LOOP / STATE / LOG.
- **source_provenance_missing:** Closed by validated Source Commit, Template Tree Hash, and clean-worktree gates.
- **bootstrap_state_undefined / bootstrap_state_validation:** Closed by the deployed inactive lifecycle protocol.
