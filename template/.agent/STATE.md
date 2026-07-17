# Current Loop State

`LOOP.md` is the only source of truth for the current Goal, Boundary / Scope, and Success Criteria. Do not restate or rewrite them here. For Standard, `.agent/STATE_MACHINE.md` is the only source of truth for Stage definitions, transitions, recovery, and required State fields.

Lite does not normally maintain a complete State. Initialize or complete this file when a task starts in Standard or when Lite is approved to upgrade to Standard. Standard updates State at key stages and keeps only information that is still current. When a Standard task ends, move its concise summary to `LOG.md`; for Lite, follow the conditional logging policy in `LOG.md`. Remove stale temporary state after delivery.

## Workflow

`[lite | standard]`

## Stage

`[ALLOWED_STAGE]`

## Status

`[CURRENT_STATUS]`

Use Status as a one-line human-readable summary of the overall situation; Stage alone identifies workflow position, and Status neither replaces Stage nor introduces a second state-machine vocabulary.

## Model Recommendation (Optional)

Use this section only when Standard or cross-context work has a recommendation worth preserving for recovery. Lite normally leaves it empty. Keep only the currently effective recommendation; update or clear it when it becomes stale. Do not record a recommendation history or a concrete model mapping here.

- Capability: `[FAST | BALANCED | DEEP]`
- Reasoning Effort: `[low | medium | high]`
- Recommendation Reason: `[CURRENT_REASON]`
- Switch Benefit: `[unknown | none | low | medium | high]`

## Active Milestone

`[CURRENT_MILESTONE_WITHIN_THE_LOOP]`

## Current Task

`[CURRENT_TASK]`

## Plan Status (Optional)

Use this section when a Standard plan exists. Keep it consistent with Approval Context.

`[draft | partially-approved | approved]`

## Plan and Steps

1. `[STEP_AND_CURRENT_STATE]`

## Approval Context (Optional)

Create this section only while a user decision is pending. After approval, preserve the concise approval evidence in Current Judgment or the approved Plan and clear this section.

- Approval Subject: `[PLAN | CONTRACT | WORKFLOW_UPGRADE | COMBINED]`
- Decision Status: `[pending | approved | partially-approved | rejected | revision-requested]`
- Approval Evidence: `[USER_MESSAGE_OR_REFERENCE]`
- Approved Portion: `[APPROVED_SCOPE_OR_NONE]`
- Remaining Decision: `[PENDING_DECISION_OR_NONE]`

## Proposed Contract Draft (Optional)

Create this section only for a new or materially changed Loop contract that is not yet approved. It is a draft, not the current Goal, Scope, or Success Criteria. On approval, write the contract to `LOOP.md` through PERSIST, then clear this section.

`[CONCISE_DRAFT_OR_DURABLE_REFERENCE]`

## Progress

- `[CURRENT_RESULT_OR_CHANGE]`

## Current Judgment

`[CURRENT_EVIDENCE_BASED_JUDGMENT]`

## Iteration Control (Optional)

Create this section only after the first verification failure for an unresolved failure. Clear it when that failure is resolved. Follow the counting and reset rules in `.agent/STATE_MACHINE.md`.

- Active Failure: `[SC_ID_AND_STABLE_FAILURE_SIGNATURE]`
- Meaningful Iterations: `[0_TO_5]`
- Latest Verification Evidence: `[EVIDENCE]`
- Current Diagnosis / Repair Hypothesis: `[DIAGNOSIS]`
- Last Meaningful Attempt: `[ATTEMPT_OR_NONE]`
- Reset Reason: `[REASON_OR_NONE]`

## Next Actions

1. `[NEXT_ACTION]`

## Blockers

- `[BLOCKER_OR_NONE]`

## Blocked Context (Optional)

Create this section only when Stage is `blocked`. Clear it after the recorded resolution is verified and the task resumes.

- Blocked From Stage: `[NONTERMINAL_STAGE]`
- Required Resolution: `[FACT_PERMISSION_DEPENDENCY_OR_DECISION]`
- Resume Stage: `[RECORDED_STAGE]`
- Resolution Evidence: `[EVIDENCE_OR_PENDING]`

## Verification Status

Reference every Success Criterion in `LOOP.md` by its stable identifier. Do not copy the criterion text. Use only `pending`, `passed`, `failed`, or `blocked` as the verification status. Keep the result concise and include evidence or a reproduction path when needed.

| Criterion | Status | Short result | Evidence / reproduction path |
| --- | --- | --- | --- |
| SC-1 | pending | `[RESULT]` | `[EVIDENCE_OR_PATH]` |
| SC-2 | pending | `[RESULT]` | `[EVIDENCE_OR_PATH]` |
