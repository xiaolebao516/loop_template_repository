# Loop Contract

This file is the canonical contract for the current Loop. A Loop Goal is the bounded result this Loop must continuously advance and eventually deliver. It may represent a short requirement set, a milestone, a feature, a bug fix, or any sustained task that needs state, feedback, verification, and iteration.

Keep this section structure stable. When starting a new Loop, replace the Goal, Boundary / Scope, and Success Criteria. During an active Loop, do not materially rewrite the Goal or change the success criteria without user confirmation.

## Goal

`[LOOP_GOAL]`

Define a result with a clear boundary that is as completable and verifiable as practical. Do not substitute a broad project vision unless that vision is the actual deliverable of this Loop.

## Boundary / Scope

### In Scope

- `[IN_SCOPE_ITEM]`

### Out of Scope

- `[OUT_OF_SCOPE_ITEM]`

### Decision Boundary

The Agent may decide ordinary implementation details, investigate local problems, iterate within the approved scope, and add necessary targeted verification.

Ask the user before proceeding when:

- requirements have multiple materially different interpretations;
- the work would change a core algorithm, metric, architecture, dependency, or public interface;
- the scope must expand;
- a Success Criterion must be added, removed, weakened, or materially changed; or
- the work introduces a high-impact risk or irreversible operation.

## Success Criteria

Use stable identifiers for every criterion. Do not renumber an existing criterion during the same Loop.

- **SC-1:** `[VERIFIABLE_OUTCOME]`
- **SC-2:** `[VERIFIABLE_OUTCOME]`

Add or remove criteria when starting a new Loop. During an active Loop, obtain user confirmation before materially changing this list.

## SOP

1. Read the project map and current Loop contract.
2. Select the appropriate Workflow through `AGENTS.md` and load only that Workflow Skill.
3. Execute the current stage within the approved boundary.
4. Verify the stage exit conditions and the applicable Success Criteria.
5. Update current state or task results without duplicating this contract.
6. Review potential learning and route durable knowledge appropriately.
7. Deliver the result with verification evidence and remaining limitations.

## Stop and Escalation Conditions

- **Success:** All applicable Success Criteria are passed with sufficient evidence and the deliverable is complete.
- **Blocked:** A required dependency, permission, fact, or user decision prevents further meaningful work. Record the blocker and the next unblocking action.
- **Escalation:** Stop and ask the user when the decision boundary would be crossed or when continuing could materially change the approved result.
- **No meaningful progress:** Stop mechanical retries when a new attempt produces no new evidence, modification, or diagnosis. Reassess the cause or ask the user.
- **Iteration limit:** Perform at most five execution iterations that each produce a substantive change, new evidence, or new diagnosis for the same unresolved failure. Repeating the same failed command does not count as a meaningful iteration.

## Learning and Evolution

Review completed work for knowledge that remains useful beyond the current task. Discard temporary information; route stable facts to project documentation, repeatable operations to scripts, mechanically detectable failures to tests or preflight checks, repeated multi-step procedures to Skill candidates, and universal high-impact rules to `AGENTS.md` candidates.

Obtain user approval before modifying a Skill, `AGENTS.md`, or a strong engineering constraint. Promote knowledge only when repeated evidence justifies the added maintenance cost.
