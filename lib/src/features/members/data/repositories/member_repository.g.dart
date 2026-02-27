// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the MemberRepository instance.

@ProviderFor(memberRepository)
final memberRepositoryProvider = MemberRepositoryProvider._();

/// Provides the MemberRepository instance.

final class MemberRepositoryProvider extends $FunctionalProvider<
    MemberRepository,
    MemberRepository,
    MemberRepository> with $Provider<MemberRepository> {
  /// Provides the MemberRepository instance.
  MemberRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'memberRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$memberRepositoryHash();

  @$internal
  @override
  $ProviderElement<MemberRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MemberRepository create(Ref ref) {
    return memberRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemberRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemberRepository>(value),
    );
  }
}

String _$memberRepositoryHash() => r'cf765c937712c9e0bdf945a5d380e96ab4e5d56c';
