# [PROJECT_NAME] Agent Guide

## Project Map

- Project root: `[PROJECT_ROOT]`
- Key directories: `[KEY_DIRECTORIES]`
- Loop contract: `.agent/LOOP.md`
- Current execution state: `.agent/STATE.md`
- Completed task log: `.agent/LOG.md`
- Model recommendation policy: `.agent/MODEL_POLICY.md`
- Workflow skills: `.agents/skills/`

## Command Entry Points

| Action | Command |
| --- | --- |
| Build | `[BUILD_COMMAND]` |
| Run | `[RUN_COMMAND]` |
| Test | `[TEST_COMMAND]` |
| Verify | `[VERIFY_COMMAND]` |

Replace every placeholder with a project-specific value before relying on it.

## Golden Rules

1. Preserve user changes and avoid unrelated modifications.
2. Ask the user when a critical requirement has multiple reasonable interpretations.
3. Stay within the approved scope; do not change core requirements or weaken success criteria.
4. Treat compilation and test results as evidence, not as completion. Complete work against the Loop success criteria and observable behavior.
5. Diagnose ordinary implementation and execution problems autonomously.
6. Obtain user confirmation before high-impact decisions, public interface changes, irreversible operations, or changes to core algorithms, architecture, or dependencies.

## Workflow Selection

Before execution, recommend one workflow and load only its Skill. State the Recommended Workflow, Confidence, Triggered Conditions, Why not the other Workflow, and Whether user confirmation is required.

### Lite Basis Conditions

Recommend Lite only when all of the following hold: the requirement is clear; the work is local, low-risk, and easily reversible; it does not need formal plan approval, sustained state, external research, or complex real-operation verification; and it does not affect core algorithms, architecture, public interfaces, important technical parameters, or a formal delivery.

### Strong Triggers

Recommend Standard when any one of these conditions applies:

- formal plan approval is required;
- sustained state or cross-context recovery is required;
- external research or a repository-constraint audit will affect the approach;
- the work affects a core algorithm, architecture, public interface, or important technical parameter;
- rollback is difficult or the error cost is high;
- complex real-operation verification is required;
- the result affects an important experiment, report, or formal delivery;
- the root cause is unknown; or
- failures have repeated without a new diagnosis.

### Weak Signals

Do not let any one of these signals force Standard by itself:

- multiple files change, but the change is clear and low-coupling;
- minor ambiguity does not affect the core approach;
- some codebase understanding is needed; or
- the work has several clear, low-risk, reversible steps.

### Selection and Override

1. Any Strong Trigger recommends Standard.
2. With no Strong Trigger, recommend Standard only when multiple Weak Signals together materially increase planning, risk, or recovery cost.
3. Otherwise recommend Lite only if every Lite Basis Condition holds. Multiple files alone are not sufficient to require Standard.
4. When evidence is insufficient, make a low-confidence recommendation and ask the user to confirm the workflow before execution.
5. The user may select Lite or Standard explicitly. A Lite task that later needs Standard pauses for an approved upgrade; an established Standard task never automatically downgrades to Lite.

A workflow override never waives confirmation for high-impact or irreversible work, a material Goal / Scope / Success Criteria change, or a core algorithm, architecture, public interface, or important parameter change. It also never waives necessary real-operation verification or any other Golden Rule in this file or `.agent/LOOP.md`. When the user selects Lite while such a gate applies, explain the gate that remains in force.

Load `.agents/skills/workflow-lite/SKILL.md` only for Lite and `.agents/skills/workflow-standard/SKILL.md` only for Standard.

## Operating Context

1. Read `.agent/LOOP.md` for the current Goal, Boundary / Scope, and Success Criteria.
2. Load only the selected Workflow Skill.
3. Read and maintain `.agent/STATE.md` when the selected workflow requires it.
4. Read `.agent/MODEL_POLICY.md` at task start and when its recommendation checkpoints apply. It recommends capability and reasoning effort only; it never switches a model automatically.
5. Use `.agent/LOG.md` only for completed-task records as defined there.

Do not store current task progress or extensive project knowledge in this file. Route durable knowledge to the appropriate project documentation, script, test, Skill, or engineering constraint.
