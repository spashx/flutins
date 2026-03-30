// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$exportNotifierHash() => r'f05bf33ceec52bde7298ce7133c201ecb05496cf';

/// Async controller for export operations -- RQ-EXP-001 / RQ-EXP-002 / D-50.
///
/// State is `AsyncValue<String?>`:
/// - `AsyncData(null)` -- idle.
/// - `AsyncLoading` -- export in progress.
/// - `AsyncData(filePath)` -- export completed; holds the output file path.
/// - `AsyncError` -- generation failed.
///
/// Copied from [ExportNotifier].
@ProviderFor(ExportNotifier)
final exportNotifierProvider =
    AutoDisposeAsyncNotifierProvider<ExportNotifier, String?>.internal(
      ExportNotifier.new,
      name: r'exportNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$exportNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ExportNotifier = AutoDisposeAsyncNotifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
