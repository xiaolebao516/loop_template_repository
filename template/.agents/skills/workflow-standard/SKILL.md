---
name: workflow-standard
description: "Apply the Standard workflow when AGENTS.md identifies a strong trigger, or multiple weak signals materially raise planning, risk, or recovery cost. Also use when the user explicitly selects Standard. Do not automatically downgrade an established Standard workflow to Lite."
---

# Standard Workflow

Follow `AGENTS.md` and load no other Workflow Skill while using Standard.

## Protocol and Recovery

Use the workflow recommendation and any user override from `AGENTS.md`; that file owns the complete classification rules and non-waivable gates.

After Standard is selected, read in this order:

`LOOP.md -> STATE_MACHINE.md -> STATE.md -> this Skill`

`.agent/STATE_MACHINE.md` is the sole source of truth for Standard Stage definitions, legal transitions, approval handling, PERSIST, DELIVER, recovery, iteration counting, and State update timing. On entry or recovery, validate the current State against that protocol. If State is incomplete or conflicts with LOOP, stop and explain the discrepancy rather than guessing.

First identify whether STATE is inactive. Do not treat framework installation as a Standard Loop. From inactive, initialize STATE at `alignment` when the task still needs alignment or planning, while LOOP remains inactive until PERSIST. If the user already supplied and approved the complete Goal, Boundary / Scope, numbered Success Criteria, and implementation plan, follow the protocol's direct PERSIST initialization instead. The protocol defines cancellation back to inactive.

Read `.agent/MODEL_POLICY.md` only at its defined recommendation checkpoints. It recommends capability and reasoning effort only and never changes the model automatically.

## Reference and Work Use

Load only the exact reference files required by the current task; never recursively load `.agent/reference/`. Do not treat project Human Deliverables as default working context; read them only at an exact project-mapped path for the task that needs them.

Use `.agent/work/<loop-id>/` only when complex research, analysis, or recovery material must persist. Record actual reference and work paths in STATE, keep work material temporary, and do not promote unconfirmed intermediate judgments into the contract. Complete work classification and cleanup before DELIVER.

## Stage Work

## ALIGN

Confirm the current Loop contract, constraints, milestone, task, and material ambiguities. Produce the aligned facts or draft information required by the protocol.

## RESEARCH_GAP

Determine and close only the evidence gap that affects the approach. Record a concise audited conclusion and evidence reference in Current Judgment; do not store a research-chat transcript. Create temporary work only when the protocol's persistence threshold is met.

## PLAN

Produce a concrete Draft Plan with verification methods, risks, assumptions, and likely files. Mark its status accurately.

## APPROVAL

Present the required decision and maintain only the permitted draft, evidence, and decision information. Apply the protocol when a response approves, partly approves, rejects, or changes the proposal.

## PERSIST

Run the protocol-defined PERSIST action before entering execution. Do not perform part of it out of order.

## Lite Upgrade Handoff

When entering Standard from Lite, read the Lite handoff package. Incorporate existing evidence into Current Judgment and changes already made into Progress. Reuse confirmed facts and do not repeat completed investigation.

If the user approved only the workflow upgrade, follow the protocol from alignment. If the user also approved the new scope, plan, and Success Criteria, use its initialization and PERSIST rules without a duplicate approval request.

## EXECUTE

Complete the approved implementation and targeted diagnostics. Work only within the approved boundary and use the protocol-defined iteration control when verification has failed.

## VERIFY

Run the protocol-required real verification and update every applicable `SC-*` row with its status, concise result, and necessary evidence. Do not copy criterion text into State.

## LEARN

Follow `.agent/LOOP.md` Learning and Evolution. Record a current candidate only when it has lasting value, recommend a destination and rationale, and obtain user approval before changing a Skill, the root or deployed `AGENTS.md`, a Hook, or a strong engineering constraint.

## REPORT

Run this phase only when required. Build the report from evidence; a report problem does not alter already verified implementation results.

## DELIVER

Run the protocol-defined DELIVER action, then enter completed only after it succeeds. Follow project Git rules and do not commit or push unless explicitly authorized.
