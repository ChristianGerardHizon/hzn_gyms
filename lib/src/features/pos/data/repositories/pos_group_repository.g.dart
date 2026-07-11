// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_group_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(posGroupRepository)
final posGroupRepositoryProvider = PosGroupRepositoryProvider._();

final class PosGroupRepositoryProvider
    extends
        $FunctionalProvider<
          PosGroupRepository,
          PosGroupRepository,
          PosGroupRepository
        >
    with $Provider<PosGroupRepository> {
  PosGroupRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'posGroupRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$posGroupRepositoryHash();

  @$internal
  @override
  $ProviderElement<PosGroupRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PosGroupRepository create(Ref ref) {
    return posGroupRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PosGroupRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PosGroupRepository>(value),
    );
  }
}

String _$posGroupRepositoryHash() =>
    r'483c9341482a416c82949ce378e0bbc5b0ae0771';
