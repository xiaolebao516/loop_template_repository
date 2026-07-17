# Loop Contract

This file becomes the canonical contract only for an active Loop. A Loop Goal is the bounded result that Loop must continuously advance and eventually deliver. It may represent a short requirement set, a milestone, a feature, a bug fix, or any sustained task that needs state, feedback, verification, and iteration.

## Status

`inactive`

There is currently no active Standard Loop. This inactive record is lifecycle metadata, not a current Loop contract. Do not infer a requirement from `none` values below.

## Goal

`none`

## Boundary / Scope

`none`

## Success Criteria

`none`

On PERSIST for an approved new Loop, replace the inactive Goal, Boundary / Scope, and Success Criteria with the approved contract and stable numbered `SC-*` identifiers. Do not materially rewrite an active Goal, Scope, or Success Criteria without user confirmation. Starting a Loop after a completed Loop creates a new instance; it is not a Stage transition.

## SOP

1. Read the project map and current Loop contract.
2. Select the appropriate Workflow through `AGENTS.md` and load only that Workflow Skill.
3. Execute the current Stage within the approved boundary.
4. Verify the Stage exit conditions and the applicable Success Criteria.
5. Update current State or task results without duplicating this contract.
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
