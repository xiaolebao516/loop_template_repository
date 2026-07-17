# Current Loop State

`LOOP.md` is the sole source of truth for an active Loop's Goal, Boundary / Scope, and Success Criteria. For Standard, `.agent/STATE_MACHINE.md` is the sole source of truth for Stage definitions, transitions, recovery, and required State fields. This file records only the current instance and may be inactive when no Standard instance exists.

## Workflow

`none`

## Stage

`none`

## Status

`inactive`

Status is a one-line human-readable summary of the overall situation; Stage alone identifies workflow position, and Status neither replaces Stage nor introduces a second state-machine vocabulary.

`Stage: none` is valid only while `Workflow: none` and `Status: inactive` are also true. It is not a Standard Stage.

## Active Milestone

`none`

## Current Task

`none`

## Active References

`none`

## Work Directory

`none`

## Progress

`none`

## Current Judgment

`No active Standard Loop or recoverable Standard draft.`

## Next Actions

`none`

## Blockers

`none`

## Verification Status

`none`

While inactive, do not create an Approved Plan, Approval Context, Proposed Contract Draft, Iteration Control, Blocked Context, or `SC-*` rows. Do not record framework deployment, migration, failed deployment, or superseded deployment here.

While inactive, Active References and Work Directory must both remain `none`. During Standard, Active References contains only exact `.agent/reference/` file paths actually used by the current Loop, never directory wildcards or copied reference content. Work Directory contains an exact path only when a temporary work directory has actually been created; do not copy its intermediate material into State.

For an active Standard instance, create only the fields required by the current Stage in `.agent/STATE_MACHINE.md`. Conditional sections are used only when applicable: Approval Context while a decision is pending, Proposed Contract Draft before a new or changed contract is approved, Iteration Control after an unresolved verification failure, Blocked Context in `blocked`, and Model Recommendation only when it is worth preserving across context. Clear them when they become stale. DELIVER restores Work Directory to `none` after its contents are routed or removed.

Lite normally does not modify this file. When a Standard Loop ends, move its concise summary to `LOG.md`; for Lite, follow the conditional logging policy in `LOG.md`.
