# Current Loop State

`LOOP.md` is the only source of truth for the current Goal, Boundary / Scope, and Success Criteria. Do not restate or rewrite them here.

Lite does not normally maintain a complete State. Initialize or complete this file when a task starts in Standard or when Lite is approved to upgrade to Standard. Standard updates State at key stages and keeps only information that is still current. When a Standard task ends, move its concise summary to `LOG.md`; for Lite, follow the conditional logging policy in `LOG.md`. Remove stale temporary state after delivery.

Allowed Stage values:

- `alignment`
- `research-gap`
- `planning`
- `awaiting-approval`
- `execution`
- `verification`
- `learning`
- `reporting`
- `completed`
- `blocked`

## Workflow

`[lite | standard]`

## Stage

`[ALLOWED_STAGE]`

## Status

`[CURRENT_STATUS]`

Use Status as a one-line human-readable summary of the overall situation; Stage alone identifies workflow position, and Status neither replaces Stage nor introduces a second state-machine vocabulary.

## Active Milestone

`[CURRENT_MILESTONE_WITHIN_THE_LOOP]`

## Current Task

`[CURRENT_TASK]`

## Plan and Steps

1. `[STEP_AND_CURRENT_STATE]`

## Progress

- `[CURRENT_RESULT_OR_CHANGE]`

## Current Judgment

`[CURRENT_EVIDENCE_BASED_JUDGMENT]`

## Next Actions

1. `[NEXT_ACTION]`

## Blockers

- `[BLOCKER_OR_NONE]`

## Verification Status

Reference every Success Criterion in `LOOP.md` by its stable identifier. Do not copy the criterion text. Use only `pending`, `passed`, `failed`, or `blocked` as the verification status. Keep the result concise and include evidence or a reproduction path when needed.

| Criterion | Status | Short result | Evidence / reproduction path |
| --- | --- | --- | --- |
| SC-1 | pending | `[RESULT]` | `[EVIDENCE_OR_PATH]` |
| SC-2 | pending | `[RESULT]` | `[EVIDENCE_OR_PATH]` |
