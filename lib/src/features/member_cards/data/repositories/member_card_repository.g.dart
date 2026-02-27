// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_card_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the MemberCardRepository instance.

@ProviderFor(memberCardRepository)
final memberCardRepositoryProvider = MemberCardRepositoryProvider._();

/// Provides the MemberCardRepository instance.

final class MemberCardRepositoryProvider extends $FunctionalProvider<
    MemberCardRepository,
    MemberCardRepository,
    MemberCardRepository> with $Provider<MemberCardRepository> {
  /// Provides the MemberCardRepository instance.
  MemberCardRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'memberCardRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$memberCardRepositoryHash();

  @$internal
  @override
  $ProviderElement<MemberCardRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MemberCardRepository create(Ref ref) {
    return memberCardRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemberCardRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemberCardRepository>(value),
    );
  }
}

String _$memberCardRepositoryHash() =>
    r'7cece9e5c6c0ba4ec297773c7c84dd462ddd9e9e';
