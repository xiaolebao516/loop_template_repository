# Model Recommendation Policy

## Purpose and Boundaries

Recommend a target model capability and reasoning effort for the current work. This policy does not select, configure, or switch models automatically, and it does not replace Workflow selection, approval gates, or verification.

Make the capability decision and the reasoning-effort decision separately. The recommendation is advisory and the user remains in control.

## Recommendation Output

At an applicable checkpoint, provide only the information that is useful:

- **Model Capability:** `FAST`, `BALANCED`, or `DEEP`
- **Reasoning Effort:** `low`, `medium`, or `high`
- **Recommendation Reason:** the task and stage facts supporting the recommendation
- **Switch Benefit:** `unknown`, `none`, `low`, `medium`, or `high`

Assess the Workflow, Stage, requirement clarity, planning complexity, codebase breadth, root-cause uncertainty, execution type, error cost, and verification risk.

## Configurable Environment Mapping

This is a modifiable example mapping, not a permanent fact about the current environment or a record of the currently selected model:

| Capability | Example model family | Typical reasoning effort |
| --- | --- | --- |
| `FAST` | Luna or Terra | `low` or `medium` |
| `BALANCED` | Terra | `medium` or `high` |
| `DEEP` | Sol | `high` |

Verify available models and controls in the active environment before treating this mapping as usable. Keep concrete mappings in this policy, not in `STATE.md`.

## Unknown Current Configuration

Compare switch benefit only when the current model and reasoning effort are reliably known. When either is unknown, still recommend the target capability and reasoning effort, set **Switch Benefit** to `unknown`, and do not claim that the current configuration is insufficient or excessive.

## Stage Guidance

| Work situation | Usual recommendation |
| --- | --- |
| Simple, clear local execution | `FAST` with `low` or `medium` effort |
| Complex ALIGN or PLAN | `DEEP` with `high` effort |
| RESEARCH_GAP repository audit | `BALANCED` or `DEEP`, depending on ambiguity and impact |
| Clear implementation work | `FAST` or `BALANCED`, depending on codebase breadth and error cost |
| Complex bug root-cause analysis | `DEEP` with `high` effort |
| Fixed build or test execution | `FAST` with `low` effort |
| VERIFY | `FAST`, `BALANCED`, or `DEEP` in proportion to verification risk |
| LEARN or REPORT | normally `BALANCED`; use `DEEP` for a complex synthesis |

Choose the least costly capability that can reliably handle the work. Use a higher reasoning effort when uncertainty, planning complexity, root-cause analysis, or error cost warrants it; use lower effort for stable mechanical work.

## Prompt Cadence

Proactively mention a recommendation only when:

1. a task starts;
2. the Workflow changes;
3. the nature of the work changes significantly;
4. the current configuration is known and Switch Benefit is `medium` or `high`; or
5. the user asks.

Do not repeatedly interrupt for a Switch Benefit of `none`, `low`, or `unknown`.

## State Recording

For Standard or cross-context work, record only the current effective recommendation in the optional `STATE.md` section when it will help recovery. Lite normally does not record one. Update or clear a stale recommendation rather than preserving history.
