
---
applyTo: "lib/**,test/**"
---
# Flutter/Dart-specific rules (project structure, null safety, state management, etc.)

- **Target platforms:** Windows and Android. Use Flutter/Dart idioms; avoid platform-specific code unless behind an abstraction layer.
- **Project structure:**
  - `lib/` - application source code, organized by feature (`lib/<feature>/`).
  - `lib/core/` - shared abstractions, constants, utilities, and DI setup.
  - `test/` - mirrors `lib/` structure; test files named `<source_file>_test.dart`.
- **Dart language:**
  - Enable and enforce **sound null safety** in all files.
  - Use `async`/`await` exclusively; never use raw `.then()` / `.catchError()` callback chains.
  - Use `const` constructors wherever possible.
- **State management:** Undecided — document the choice in `ADR-002-state-management.md` before writing any stateful widget beyond trivial UI state.
- **Dependency injection:** Undecided — document in `ADR-003-dependency-injection.md` before introducing any DI mechanism.
- **New pub dependencies:** Every new package added to `pubspec.yaml` MUST be justified by a requirement ID or ADR reference in a comment on the same line.
## Code Quality
Constants shared across classes MUST be centralized in a dedicated constants file under `lib/core/constants/`.