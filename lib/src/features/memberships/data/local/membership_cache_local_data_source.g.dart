// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_cache_local_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(membershipCacheLocalDataSource)
final membershipCacheLocalDataSourceProvider =
    MembershipCacheLocalDataSourceProvider._();

final class MembershipCacheLocalDataSourceProvider
    extends
        $FunctionalProvider<
          MembershipCacheLocalDataSource,
          MembershipCacheLocalDataSource,
          MembershipCacheLocalDataSource
        >
    with $Provider<MembershipCacheLocalDataSource> {
  MembershipCacheLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'membershipCacheLocalDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$membershipCacheLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<MembershipCacheLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MembershipCacheLocalDataSource create(Ref ref) {
    return membershipCacheLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MembershipCacheLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MembershipCacheLocalDataSource>(
        value,
      ),
    );
  }
}

String _$membershipCacheLocalDataSourceHash() =>
    r'5ab5fe40a1aaa645ac87dc65e74acb35bfea6a61';
