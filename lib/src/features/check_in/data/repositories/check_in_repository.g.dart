// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the CheckInRepository instance.

@ProviderFor(checkInRepository)
final checkInRepositoryProvider = CheckInRepositoryProvider._();

/// Provides the CheckInRepository instance.

final class CheckInRepositoryProvider extends $FunctionalProvider<
    CheckInRepository,
    CheckInRepository,
    CheckInRepository> with $Provider<CheckInRepository> {
  /// Provides the CheckInRepository instance.
  CheckInRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'checkInRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$checkInRepositoryHash();

  @$internal
  @override
  $ProviderElement<CheckInRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CheckInRepository create(Ref ref) {
    return checkInRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CheckInRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CheckInRepository>(value),
    );
  }
}

String _$checkInRepositoryHash() => r'f99b9d01aae7243713866c9e41219353eaf4df8f';
