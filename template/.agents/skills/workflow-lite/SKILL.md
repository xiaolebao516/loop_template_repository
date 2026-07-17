---
name: workflow-lite
description: "Apply the Lite workflow only when AGENTS.md recommends Lite for a clearly defined, local, low-risk, and reversible engineering change: no strong trigger is present and weak signals do not collectively raise planning, risk, or recovery cost. Also use when the user explicitly selects Lite; required confirmation and verification gates still apply."
---

# Lite Workflow

Follow `AGENTS.md` and the current contract in `.agent/LOOP.md` when the task belongs to that Loop. Load no other Workflow Skill while using Lite.

## Selection and Model Recommendation

Use the workflow recommendation and any user override from `AGENTS.md`; that file owns the complete classification rules. A Lite override does not waive any applicable confirmation, safety, or verification gate. Read `.agent/MODEL_POLICY.md` at its defined checkpoints, recommend only the target capability and reasoning effort, and never switch a model automatically.

## Standalone Lite Tasks

Not every Lite task needs to become a Loop. For an independent Lite task unrelated to the current Loop:

- use the user's request as the local acceptance basis;
- do not create or rewrite `.agent/LOOP.md` or `.agent/STATE.md`; and
- do not verify against unrelated Loop Success Criteria.

If the task would change the current Loop Goal, Boundary / Scope, or Success Criteria, pause and request approval to upgrade to Standard.

## Procedure

1. Determine whether the task belongs to the current Loop, then understand the requested result, boundary, and applicable acceptance basis.
2. Ask the user only when a critical ambiguity would change the implementation or acceptance result.
3. Execute the local change directly within scope.
4. Run targeted verification against observable behavior and the applicable Success Criteria or local acceptance basis.
5. Deliver a concise summary of changes, evidence, limitations, and remaining actions.
6. Perform a minimal learning check for information that remains useful beyond this task.

## Default Behavior

- Do not create a complex plan or require formal plan approval unless an applicable confirmation or safety gate still requires it.
- Do not maintain a complete `.agent/STATE.md`.
- Read a specific `.agent/reference/` file only when the current task clearly needs it; never recursively load the reference directory.
- Do not create `.agent/work/` by default. Upgrade to Standard if sustained research material, complex intermediate State, or long-term recovery becomes necessary.
- Do not modify `.agent/LOOP.md`, `.agent/STATE.md`, or `.agent/LOG.md` by default; the conditional lasting-value logging rule below remains the only exception.
- Do not create unnecessary research or reporting documents.
- Do not treat compilation or a passing self-written test as sufficient completion by itself.

## Upgrade to Standard

Pause execution, explain the reason, and request user approval before upgrading when:

- the modification scope expands materially;
- a requirement becomes materially ambiguous;
- work must continue across multiple stages or a long context;
- a formal plan decision is needed;
- external research is needed;
- acceptance requires complex real-world operation;
- failures repeat or the root cause remains unclear; or
- the result affects an important experiment, report, or delivery.

Before requesting an upgrade, provide a concise handoff package:

- **Upgrade reason:** `[WHY_LITE_NO_LONGER_FITS]`
- **Existing evidence:** `[CONFIRMED_FACTS_OR_RESULTS]`
- **Changes already made:** `[CHANGES_OR_NONE]`
- **Unfinished work:** `[REMAINING_WORK]`
- **Goal / Scope / Success Criteria impact:** `[IMPACT_OR_NONE]`
- **Known questions or blockers:** `[QUESTIONS_OR_BLOCKERS]`

Do not repeat facts already confirmed in this handoff after upgrading.

If the user approves only the workflow upgrade, load only the Standard Skill, resume at ALIGN / PLAN, and wait for implementation-plan approval. If the upgrade request already includes the new scope, plan, and Success Criteria, the user may approve the upgrade and implementation plan together; reuse that approval and continue through PERSIST without a duplicate approval request.

## Learning and Logging

Discard task-local observations after delivery. When a stable fact, reusable procedure, significant decision, or recurring risk has lasting value, append one concise entry to `.agent/LOG.md` and propose its durable destination when appropriate. Otherwise, do not add a Lite log entry.
