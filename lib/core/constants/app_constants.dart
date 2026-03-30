// RQ-NFR-001 / D-09 / D-11
// Single source of truth for all application-wide constants.
// No string or numeric literal may be duplicated inline across the codebase.

/// Application-level identity constants (D-11).
abstract final class AppConstants {
  AppConstants._();

  static const String appName = 'Flutins';
  static const String packageId = 'com.spashx.flutins';

  // -------------------------------------------------------------------------
  // Layout
  // -------------------------------------------------------------------------

  /// Outer horizontal / vertical padding for scrollable form screens.
  static const double formPadding = 16.0;

  /// Vertical gap between consecutive form fields.
  static const double formFieldSpacing = 12.0;

  /// Vertical gap before a new form section heading.
  static const double formSectionSpacing = 24.0;

  /// Border radius for card and placeholder containers.
  static const double cardBorderRadius = 8.0;

  /// Height of the main-photo placeholder card in the item form.
  static const double photoPlaceholderHeight = 160.0;

  /// Vertical gap between list tile items on the home screen.
  static const double listItemSpacing = 0.0;
}
