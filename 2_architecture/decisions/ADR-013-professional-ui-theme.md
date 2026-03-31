<!-- Model: Claude Sonnet 4.6 -->

# ADR-013: Professional UI Theme -- Material 3 with Native Implementation

## Status

Proposed

---

## Context

RQ-NFR-002 was added to the requirements to establish a professional-grade user
interface standard across all screens. The current theme implementation is
minimal (indigo seed color only) and does not provide cohesive typography,
component styling, or dark mode support.

A choice must be made between:

1. **Native Flutter Material 3** -- Use built-in `ThemeData` for colors and
   typography, with manual refinement of component styles.
2. **Third-party theme package** (e.g., `flex_color_scheme`) -- Add a dependency
   for pre-built professional schemes and advanced customization.

### Requirements driving this decision

- **RQ-NFR-002:** Professional-grade UI with Material Design 3, cohesive color
  scheme, consistent typography, thoughtful component styling, light/dark modes
  with OS preference detection.

### Scope

This ADR addresses:
- Color scheme selection and seed color
- Typography (font family, sizes, weights)
- Component styling (buttons, input fields, cards, dialogs)
- Dark mode implementation
- System theme adaptation

### Package evaluation

| # | Option | Evaluation | Outcome |
|---|---|---|---|
| A | **Native Material 3** (`ThemeData` + manual styling) | Already imported in Flutter. Zero new dependencies. Requires careful design but offers full control. Sufficient for professional appearance. | **Accepted** |
| B | **`flex_color_scheme`** | 40+ pre-built schemes; higher abstraction; reduces manual work; well-maintained. Adds 1 dependency. | **Considered but not selected** -- native approach is sufficient for insurance/asset inventory domain |
| C | **Material Theme Builder (online tool)** | Export pre-generated `ThemeData` code. One-time setup. No runtime dependency. | **Accepted as design tool** -- use to guide native implementation |

---

## Decisions

### D-58: Native Material 3 implementation with professional blue-grey seed color (RQ-NFR-002)

**Decision:** Implement a professional-grade theme using only Flutter's native
`ThemeData` API with no external theme packages. The seed color shall be a
deep professional blue-grey (`Color(0xFF1A5276`), chosen to evoke trust,
stability, and corporate professionalism appropriate for an insurance asset
inventory application.

```dart
// lib/main.dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF1A5276),  // Deep professional blue
    brightness: Brightness.light,
  ),
  useMaterial3: true,
),
darkTheme: ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF5DADE2),  // Light blue for dark mode
    brightness: Brightness.dark,
  ),
  useMaterial3: true,
),
themeMode: ThemeMode.system,  // Respects OS preference
```

**Rationale:**
- Blue-grey is universally associated with trust, stability, and professionalism
  -- critical for an insurance justification application.
- Light seed color for dark mode ensures readability and proper contrast.
- `ThemeMode.system` provides seamless adaptation to user's OS dark mode
  preference.
- Material 3 `ColorScheme.fromSeed()` automatically derives semantic colors
  (primary container, surface, error, etc.) for consistency.
- No external dependencies keeps the project lean and maintainable.

**Consequences:**
- Users with OS dark mode enabled will automatically see the dark theme.
- All Material components (buttons, cards, dialogs, input fields) will inherit
  the theme colors automatically.
- Existing and future use of `Theme.of(context)` throughout the codebase
  will immediately reflect the new professional appearance.

---

### D-59: Typography -- Roboto with Material 3 standard sizes (RQ-NFR-002)

**Decision:** Rely on Material 3's default typography scale (based on
Roboto font) without additional font files. The standard Material
`textTheme` provides:

- `displayLarge`, `displayMedium`, `displaySmall` -- for large headings
- `headlineLarge`, `headlineMedium`, `headlineSmall` -- for section titles
- `titleLarge`, `titleMedium`, `titleSmall` -- for component titles
- `bodyLarge`, `bodyMedium`, `bodySmall` -- for body text
- `labelLarge`, `labelMedium`, `labelSmall` -- for labels and buttons

**Rationale:**
- Material 3 typography is specifically designed for readability and hierarchy.
- Roboto is ubiquitous on Android; Material web defaults ensure it's available
  on all platforms.
- No need for custom Google Fonts imports; reduces bundle size and improves
  startup performance.
- Material's sizing hierarchy is proven and professional.

**Consequences:**
- All text throughout the app inherits Material 3 typography standards.
- No custom font files to manage or load.

---

### D-60: Component styling -- Rounded corners and Material elevation (RQ-NFR-002)

**Decision:** Apply consistent Material 3 component styling:

```dart
// Buttons: elevated with rounded corners
elevatedButtonTheme: ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
)

// Text Input: outlined with rounded corners
inputDecorationTheme: InputDecorationTheme(
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
  ),
)

// Cards: rounded corners with subtle elevation
cardTheme: CardTheme(
  elevation: 1,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
)

// Dialogs: Material 3 shape and no extra padding
dialogTheme: DialogTheme(
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
)
```

**Rationale:**
- Rounded corners (12dp) provide modern, approachable appearance while
  maintaining professionalism.
- Material elevation hierarchy (subtle shadows) adds depth and visual hierarchy.
- Consistent border radius across all components creates visual cohesion.
- Material 3 surface and color semantics automatically adapt corners to theme.

**Consequences:**
- All buttons, cards, input fields, and dialogs throughout the app adopt the
  rounded-corner aesthetic.
- Shadows and elevation automatically respond to theme context (light/dark).

---

### D-61: Dark mode support via `ThemeMode.system` (RQ-NFR-002)

**Decision:** Automatically adapt to the user's OS dark mode preference by:

1. Defining a `darkTheme` with appropriate seed color for dark surfaces.
2. Setting `themeMode: ThemeMode.system` so Flutter listens to OS settings.
3. No toggle or settings screen required at this stage.

**Rationale:**
- RQ-NFR-002 explicitly requires light/dark modes with OS preference detection.
- Users expect apps to respect their accessibility/display settings.
- Zero friction -- no additional UI or settings logic required.
- Can be extended with a manual theme toggle in future iterations.

**Consequences:**
- Dark mode is automatically enabled for users with system-wide dark mode active.
- Users cannot currently override the mode within the app (acceptable for now).

---

## Implementation Steps

| Step | Artifact | Description |
|---|---|---|
| 1 | `lib/main.dart` | Update `FlutinsApp.build()` with full `ThemeData` configuration (D-58, D-59, D-60, D-61) |
| 2 | Preview | Run `flutter run -d windows` and visually verify all screens (home, item form, tag management, export) render correctly with the new theme |
| 3 | Verify | `flutter analyze` -- 0 issues; existing tests still pass (no logic changes) |
| 4 | Document | Update implementation status in `1_requirements/top-level-requirements-ai-reviewed-implementation-status.md` |

---

## Consequences Summary

| Decision | Benefit | Trade-off |
|---|---|---|
| D-58: Native Material 3 | Zero dependencies; full control; Material 3 semantic colors | Requires deliberate design choices vs. pre-built schemes |
| D-59: Roboto + Material typography | No custom font files; standard readability; performance | Less distinctive typography than custom fonts (appropriate for professional context) |
| D-60: Rounded corners + elevation | Modern, cohesive appearance | Slightly more Material 3 opinionated (not minimalist) |
| D-61: System dark mode | Respects user accessibility settings; zero friction | No in-app theme toggle yet (future enhancement) |

---

## Design Rationale

The insurance/asset inventory domain demands **trust, clarity, and professionalism**.

- **Blue-grey seed color** → Trustworthy, stable, corporate
- **Material 3** → Modern, accessible, widely recognized
- **Rounded corners (12dp)** → Approachable yet professional
- **Subtle elevation** → Depth and visual hierarchy without overwhelm
- **System dark mode** → Respects user intent; reduces eye strain
- **No custom fonts** → Cleaner, faster, professional (Roboto is industry standard)

This combination creates a **high-credibility user interface** suitable for
stewarding valuable personal possessions and justifying them to insurance
providers.

---

## Future Enhancements

| Enhancement | Trigger | Scope |
|---|---|---|
| In-app theme toggle | User feature request | Add settings screen with light/dark/system options |
| Custom seed color picker | Branding refresh | Allow users to choose accent color |
| Accessibility refinements | Accessibility audit | Increase contrast, adjust button sizes, improve text scaling |
| Custom font (Google Fonts) | Design enhancement | Source professional serif/sans-serif for brand distinction |
