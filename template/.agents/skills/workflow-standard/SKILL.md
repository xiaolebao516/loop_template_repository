---
name: workflow-standard
description: "Execute engineering work when at least one Standard condition applies: multi-file or multi-module change; requirement ambiguity that affects the approach; plan approval; sustained state or cross-context recovery; external research or repository-constraint audit; complex real-world validation; or impact on an important experiment, report, or delivery. Do not use for an independent low-risk change that satisfies every Lite condition."
---

# Standard Workflow

Follow `AGENTS.md`, read `.agent/LOOP.md` and `.agent/STATE.md`, and load no other Workflow Skill while using Standard.

Use this sequence:

`ALIGN -> RESEARCH_GAP -> PLAN -> APPROVAL -> PERSIST -> EXECUTE -> VERIFY -> LEARN -> REPORT (when required) -> DELIVER`

Map workflow phases to State stages as follows:

| Workflow phase | State stage |
| --- | --- |
| ALIGN | `alignment` |
| RESEARCH_GAP | `research-gap` |
| PLAN | `planning` |
| APPROVAL | `awaiting-approval` |
| PERSIST | Persist state, then use `execution` |
| EXECUTE | `execution` |
| VERIFY | `verification` |
| LEARN | `learning` |
| REPORT | `reporting` |
| DELIVER | `completed` |

Use `blocked` from any phase when further meaningful progress is not possible.

## ALIGN

Confirm the current Loop Goal, Boundary / Scope, constraints, and Success Criteria. Clarify the current milestone and task. Ask only questions whose answers would materially change the plan or acceptance result. Do not rewrite the Goal during execution without user confirmation.

## RESEARCH_GAP

Determine whether the task lacks an external technical fact, standard, paper, device parameter, or other evidence. Allow the user to conduct external GPT research by default, then audit the result against repository code and project constraints. Suggest a second research pass only when a new critical external question appears. Do not default to broad web research within Codex.

## PLAN

Provide concrete implementation steps and verification methods. State material risks, assumptions, and files likely to change.

## APPROVAL

Before the user approves the implementation plan, allow only:

- read-only repository inspection;
- safe investigation commands; and
- STATE updates for Workflow, Stage, Current Judgment, confirmed facts, unresolved questions, existing evidence, a clearly marked Draft Plan, and the next action awaiting approval.

Do not modify implementation code, product behavior, formal delivery files, or perform irreversible or high-impact operations before approval. Do not present a Draft Plan as approved. When approval covers only part of the plan, execute only that approved part.

## PERSIST

When the task starts a new Loop, or the user approves a material change to the current Loop Goal, Boundary / Scope, or Success Criteria:

1. Write the approved Goal, Boundary / Scope, and numbered Success Criteria to `.agent/LOOP.md`.
2. Initialize or update `.agent/STATE.md` with the approved milestone, task, plan, current judgment, and steps.
3. Create or update the Verification Status table by `SC-*` identifier only; do not copy criterion text.
4. Set the State Stage to `execution`.

When the task is an ordinary subtask within the existing Loop, do not rewrite `.agent/LOOP.md`. Update only the relevant State milestone, task, steps, progress, and verification rows. Rewrite the Loop contract only after the user approves a material Goal, Scope, or Success Criteria change.

Set referenced Success Criteria to `pending` unless existing evidence justifies another status.

## Lite Upgrade Handoff

When entering Standard from Lite, read the Lite handoff package. Incorporate existing evidence into Current Judgment and changes already made into Progress. Reuse confirmed facts and do not repeat completed investigation.

If the user approved only the workflow upgrade, enter ALIGN / PLAN. If the user also approved the new scope, plan, and Success Criteria, enter PERSIST directly.

## EXECUTE

Complete implementation, targeted tests, fixes, and iteration within the approved boundary. Make each iteration produce a substantive modification, new evidence, or new diagnosis. Perform at most five meaningful iterations for the same unresolved failure. When failures repeat without new information, stop mechanical retries and reassess or ask the user.

Update State at material progress changes. Do not change the Goal, expand scope, or weaken Success Criteria without user confirmation.

## VERIFY

Use real builds, runs, tests, or user-observable behavior appropriate to each Success Criterion. Treat compilation and self-written test results as evidence rather than the definition of completion. Verify UI and interaction work through real operation whenever practical.

For every `SC-*` identifier in `.agent/LOOP.md`, update the `.agent/STATE.md` verification table with:

- `pending`, `passed`, `failed`, or `blocked`;
- a short result; and
- necessary evidence or a reproduction path.

Do not duplicate Success Criterion text in State.

## LEARN

Follow `.agent/LOOP.md` Learning and Evolution. Record current candidates in STATE Current Judgment, recommend a destination and rationale, and obtain user approval before changing a Skill, the root or deployed `AGENTS.md`, a Hook, or a strong engineering constraint.

## REPORT

Run this phase only when the task or project requires a report. Build it from research results, current State, completed-task logs, actual changes, and verification evidence. Do not reconstruct an unsupported process from memory.

## DELIVER

Summarize changes, verification by Success Criterion, known limitations, remaining actions, and how the user can accept the result. Append one concise task entry to `.agent/LOG.md`, then remove stale temporary information from State. Follow project Git rules and do not commit or push unless explicitly authorized.
