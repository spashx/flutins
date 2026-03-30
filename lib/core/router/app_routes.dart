// RQ-NFR-001 / D-08
// All named route paths are declared here as constants.
// No route string may appear outside this file.

abstract final class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String itemEdit = '/item/:id';
  static const String itemCreate = '/item/new';
  static const String tagManagement = '/tags';
  static const String export = '/export';
}
