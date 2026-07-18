# [PROJECT_NAME] Agent Guide

## Project Configuration

- Project root and stable project map: maintain them in this file.
- Project-specific constraints and protected areas: maintain them in this file.
- Current complex-task contract: `.agent/LOOP.md`.
- Current task state, unengineered learnings, and minimal history: `.agent/STATE.md`.
- Build: `[BUILD_COMMAND]`
- Test: `[TEST_COMMAND]`
- Verify: `[VERIFY_COMMAND]`

Build, Test, and Verify must resolve to deterministic scripts or explicit commands. Replace every project placeholder with a verified project-specific value before relying on it.

## Project Initialization

When the user asks to initialize Agent Loop Engineering:

1. Audit the project structure, existing documentation, and any legacy Agent material.
2. Audit existing build, test, run, and verification methods; prefer reliable scripts and CI commands already used by the project.
3. When no reliable unified entry exists, create the thinnest deterministic wrapper script needed by the project.
4. Actually run the applicable commands, then record the single official Build, Test, and Verify entries in this file. Do not leave command placeholders as claimed initialization results.
5. Distinguish automated verification from external human acceptance and map both to exact project locations or procedures.
6. Semantically merge lasting legacy Agent rules; do not preserve a competing control framework.
7. Engineer repeated errors and mechanical procedures into scripts, tools, tests, Skills, or a short rule when evidence justifies it.
8. Initialization creates no business LOOP or History entry, leaves STATE inactive, and does not commit or push by default.

## Operating Rules

1. Clarify requirements before implementation when ambiguity could change behavior, scope, risk, or acceptance.
2. Before changing the repository, inspect Git status and protect all existing user modifications. Never discard unrelated work.
3. Execute simple, clear, local, low-risk work directly against the user's request; it may leave LOOP unchanged.
4. Use `.agent/LOOP.md` for complex, uncertain, high-risk, or multi-file work. Goal states the intended result and completion condition; Boundaries state allowed and prohibited scope, protected content, and approval limits; SOP states the actual execution steps.
5. Keep `.agent/STATE.md` current enough to resume interrupted work without copying the full LOOP contract.
6. Stay within approved boundaries. Ask before changing protected content, public interfaces, core algorithms, architecture, important parameters, or performing irreversible operations.
7. Before completion, actually run every applicable Build, Test, and Verify command. Compilation alone is not acceptance when observable behavior also requires verification.
8. Deliver concise evidence, limitations, and remaining actions. Follow project Git rules and user authorization for commit and push.

## Main Flow

Clarify when needed → Execute → Verify → Learn → Deliver

## Failure and Learning Rules

- Classify each failure before retrying, for example as requirement, environment, dependency, configuration, implementation, data, verification, permission, or external-service failure.
- Do not blindly retry the same cause. A new attempt must introduce a meaningful change, new evidence, or a new diagnosis.
- Do not exceed five meaningful attempts for the same unresolved root cause; then stop, preserve the evidence, and ask for direction or change the approach.
- Record in STATE Learnings only information that is not yet engineered, remains useful, and includes the problem, cause, correction, evidence, and upgrade result when applicable.
- Promote repeated problems to deterministic scripts, tools, tests, Skills, or a short AGENTS rule. Once an engineering constraint covers the learning, compress STATE to a concise pointer instead of retaining repeated narrative.
- Append one compact STATE History entry per completed task; do not store full transcripts or duplicate the LOOP contract.

## Model Guidance

Prefer a strong model for architecture, migration, security, and high-uncertainty work; a balanced model for ordinary cross-file development; and a fast model for clear mechanical work. If the preferred model is unavailable, continue only when safe and never lower the verification or acceptance standard.
