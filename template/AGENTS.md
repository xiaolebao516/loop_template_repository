# [PROJECT_NAME] Agent Guide

## Project Map

- Project root: `[PROJECT_ROOT]`
- Key directories: `[KEY_DIRECTORIES]`
- Loop contract: `.agent/LOOP.md`
- Current execution state: `.agent/STATE.md`
- Completed task log: `.agent/LOG.md`
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

Choose one workflow before execution and load only its Skill.

- Use Lite for clear, local, low-risk, reversible work that does not need sustained state or formal approval. Load `.agents/skills/workflow-lite/SKILL.md`.
- Use Standard for cross-file work, material ambiguity, external research, sustained progress, complex verification, or important delivery. Load `.agents/skills/workflow-standard/SKILL.md`.

If a Lite task meets an escalation condition, pause and request approval before switching to Standard.

## Operating Context

1. Read `.agent/LOOP.md` for the current Goal, Boundary / Scope, and Success Criteria.
2. Load only the selected Workflow Skill.
3. Read and maintain `.agent/STATE.md` when the selected workflow requires it.
4. Use `.agent/LOG.md` only for completed-task records as defined there.

Do not store current task progress or extensive project knowledge in this file. Route durable knowledge to the appropriate project documentation, script, test, Skill, or engineering constraint.
