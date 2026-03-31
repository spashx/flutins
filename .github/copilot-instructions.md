---
applyTo: "**"
---

# Project Engineering Rules

## Session Kickoff Checklist

At the start of every session, run these steps in order before any task:

1. Read this file fully if it has not been loaded in context yet.
2. Read any domain- or stack-specific instruction files present in the project.
3. Scan `1_requirements/` for open or unimplemented requirement IDs.
4. Scan `2_architecture/decisions/` for existing ADRs to avoid creating duplicates.
5. Determine the tier (S / M / L -- see Task Tiers section) of the incoming task.

---

## Agentic Planning Workflow (MANDATORY — apply to every task)

1. **Plan before acting.** For any non-trivial task, list the steps before executing them. Use a todo list and mark each step in-progress then completed as you go.
2. **Read before editing.** NEVER modify a file you have not read in the current session. Always read the relevant file section first.
3. **Verify after each step.** After creating or editing files, check for compile/lint errors before proceeding to the next step.
4. **Ask only when blocking.** Infer and proceed for anything that can be reasonably deduced. Ask ONLY when one of the following is true: 
(a) a requirement ID is missing and cannot be inferred from context; 
(b) an operation is destructive or irreversible and affects shared infrastructure; 
(c) two valid designs have meaningfully different and irreconcilable long-term trade-offs. Everything else: decide and proceed.
(d) After 3 failure STOP EVERYTHING and ask support of the user.
5. **No scope creep.** Implement ONLY what was explicitly requested. Do not add features, refactor surrounding code, or introduce new abstractions beyond the task scope.
6. **Self-check before declaring done.** Before ending a task, verify every item in the Delivery Checklist below.


## Delivery Checklist

Before marking any task complete, confirm ALL of the following:

- [ ] Every new artifact references a requirement ID (`RQ-<FTR>-<NNN>`).
- [ ] Every new function/method has at least one passing unit test (Gherkin format).
- [ ] Every architectural decision has a corresponding ADR with a Mermaid diagram.
- [ ] No string or numeric literal is duplicated inline — all are named constants.
- [ ] No failing test was modified to force it to pass.
- [ ] Code compiles and passes static analysis with no errors.

## Task Tiers

Tag every task with a tier before starting. The tier determines which steps are mandatory.

| Tier | Criteria | Tests required | ADR required | Full checklist |
|------|----------|:-:|:-:|:-:|
| **S - Small** | Edits <= 5 lines, no new files, no new public API | No | No | No |
| **M - Medium** | New method or class, new file, contained to one module | Yes | No | No |
| **L - Large** | Cross-cutting change, new public API, or new dependency | Yes | Yes | Yes |

- Default to **M** when uncertain.
- A Tier S task that unexpectedly requires a new file must be re-tiered to M or L before continuing.
- Only Tier L tasks require the full Delivery Checklist above.

## Requirements Authoring

- Write all requirements in **EARS format** (Easy Approach to Requirements Syntax). For example:
  - **Ubiquitous requirements:** "The system shall allow users to reset their password."
  - **Event-driven requirements:** "When a user forgets their password, the system shall send a password reset email."
  - **State-driven requirements:** "While the user is logged in, the system shall display a logout button."
  Requirements must be clear, concise, and testable and shall answer SMART criteria (Specific, Measurable, Achievable, Relevant, Time-bound).
- Assign every requirement a unique, unambiguous identifier: `RQ-<FTR>-<NNN>` where `<FTR>` is a 3-letter functional-area trigram (uppercase) and `<NNN>` is a zero-padded sequence number (e.g., `RQ-USR-001`).

## Traceability (MANDATORY)

- Every generated artifact (source file, test, ADR, documentation) MUST reference the requirement ID(s) it fulfills.
- Embed the requirement ID in: file headers, class/function doc comments, test case names, and ADR filenames.
- An artifact with no traceable requirement ID is considered incomplete and must not be delivered.

## Architecture Decision Records (ADRs)

- Create an ADR for every cross-cutting architectural choice (state management, DI framework, navigation, storage, platform channel strategy, etc.).
- Every ADR MUST use the following structure exactly:
  ```
  # ADR-NNN: <Short Title>
  ## Status
  [Proposed | Accepted | Deprecated | Superseded by ADR-NNN]
  ## Context
  What problem or force requires a decision?
  ## Decision
  What was decided, and why?
  ## Consequences
  What becomes easier, harder, or constrained as a result?
  ## Diagram
  [Mermaid diagram -- required]
  ```
- Every ADR MUST include at least one Mermaid diagram.
- **Traceability is mandatory in every ADR.** The ADR filename, title, and body MUST reference the requirement ID(s) (`RQ-<FTR>-<NNN>`) that motivated the decision. An ADR with no requirement reference is incomplete and must not be committed.
- Store ADRs in `architecture/decisions/`.
- Name ADR files: `ADR-<NNN>-<short-title>.md` (e.g., `ADR-001-state-management.md`).
- **LLM Model Identifier** - include the exact model name and version used in the geerated ADR in a comment at the top of the file.

## Code Quality

- All generated code MUST comply with SOLID principles:
  - **S** - Single Responsibility: one class = one reason to change.
  - **O** - Open/Closed: open for extension, closed for modification.
  - **L** - Liskov Substitution: subtypes must be substitutable for their base types.
  - **I** - Interface Segregation: no client should depend on methods it does not use.
  - **D** - Dependency Inversion: depend on abstractions, not concretions.
- **No duplicated literals (strings or numbers).** Every constant MUST be declared as a named class-level or method-level constant. 
- **No magic numbers.** Every numeric value with domain meaning MUST be a named constant.
- **LLM Model Identifier** - include the exact model name and version used in the implementation in a comment at the top of every generated source file.

## Testing

- Every generated function or method MUST have at least one unit test.
- Write all tests and acceptance criteria in **Gherkin format** (Given / When / Then).
- A function is considered delivered ONLY when ALL of the following conditions are met:
  1. All associated unit tests pass without any modification to the test implementation.
  2. Traceability to the fulfilled requirement ID is explicit and unambiguous.
- **NEVER modify a failing test solely to make it pass.** A test may only be changed if the change correctly reflects new or corrected expected behavior.

## Anti-Patterns (NEVER do these)

- Never recreate a file from scratch when a targeted edit on the existing file suffices.
- Never run a broad workspace search when the file path or symbol is already known.
- Never add error handling, logging, or fallbacks for scenarios that cannot occur in the current design.
- Never introduce a new abstraction, helper, or utility for a one-off operation.
- Never add documentation, comments, or type annotations to code you did not change.
- Never assume a constant or configuration value -- read the source file first.
- Never guess a fix and retry the same failing approach twice. If the first targeted fix fails, stop and report.

## Error Recovery Protocol

When a compile, lint, or test step fails:

1. **Read the full error message** before taking any action.
2. **Fix the root cause** -- do not suppress, comment out, or work around the failure.
3. **One attempt:** apply the targeted fix, then re-run the failing check.
4. **If still failing:** stop, report the exact error and what was attempted, and wait for guidance. Do not guess a second time.
5. **Never skip a verification step** to move forward -- a broken state must be resolved before proceeding



```mermaid
graph TD
    A["🚀 Session Kickoff"] --> A1["1. Load Instructions"]
    A1 --> A2["2. Read Stack-Specific Docs"]
    A2 --> A3["3. Scan Requirements"]
    A3 --> A4["4. Scan Architecture Decisions"]
    A4 --> A5["5. Determine Task Tier"]
    
    A5 --> B{Task Tier}
    B -->|Tier S: ≤5 lines| C["✓ No tests/ADR needed"]
    B -->|Tier M: New class/file| D["✓ Tests required"]
    B -->|Tier L: Cross-cutting| E["✓ Tests + ADR required"]
    
    C --> F["📋 Planning Phase"]
    D --> F
    E --> F
    
    F --> F1["MANDATORY: Plan steps before acting"]
    F1 --> F2["Read files before editing"]
    F2 --> F3["Infer & decide; ask only if blocking"]
    
    F3 --> G["⚙️ Implementation Phase"]
    G --> G1["Execute planned steps"]
    G1 --> G2["Check for errors after each step"]
    G2 --> G3{Errors?}
    
    G3 -->|Yes| H["🔧 Error Recovery"]
    H --> H1["Read full error message"]
    H1 --> H2["Fix root cause"]
    H2 --> H3["Re-run check once"]
    H3 --> H4{Still failing?}
    H4 -->|Yes| I["⛔ STOP & Report"]
    H4 -->|No| G2
    
    G3 -->|No| J["✅ Delivery Checklist"]
    J --> J1["Requirement IDs present?"]
    J1 --> J2["Tests passing?"]
    J2 --> J3["ADR + Diagram present?"]
    J3 --> J4["No duplicate literals?"]
    J4 --> J5["Code compiles clean?"]
    
    J5 --> K{All checks pass?}
    K -->|No| L["❌ Mark incomplete"]
    L --> G
    K -->|Yes| M["🎉 Task Complete"]
    
    style A fill:#e1f5e1
    style F fill:#e3f2fd
    style G fill:#fff3e0
    style H fill:#ffcdd2
    style J fill:#f3e5f5
    style M fill:#c8e6c9
    style I fill:#ffcdd2
   