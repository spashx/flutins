// RQ-ABT-001 / D-63
// Riverpod provider for runtime package metadata.
// Model: Claude Opus 4.6

import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'package_info_provider.g.dart';

/// Provides [PackageInfo] with app name, version, and package identifier
/// resolved at runtime from the platform -- D-63 / RQ-ABT-001.
@Riverpod(keepAlive: true)
Future<PackageInfo> packageInfo(PackageInfoRef ref) {
  return PackageInfo.fromPlatform();
}
