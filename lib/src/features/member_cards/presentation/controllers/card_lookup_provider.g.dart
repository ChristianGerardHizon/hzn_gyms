// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_lookup_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Looks up an active member card by its card value.
///
/// Used by the check-in flow to resolve a scanned card to a member.

@ProviderFor(cardLookup)
final cardLookupProvider = CardLookupFamily._();

/// Looks up an active member card by its card value.
///
/// Used by the check-in flow to resolve a scanned card to a member.

final class CardLookupProvider extends $FunctionalProvider<
        AsyncValue<MemberCard?>, MemberCard?, FutureOr<MemberCard?>>
    with $FutureModifier<MemberCard?>, $FutureProvider<MemberCard?> {
  /// Looks up an active member card by its card value.
  ///
  /// Used by the check-in flow to resolve a scanned card to a member.
  CardLookupProvider._(
      {required CardLookupFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'cardLookupProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$cardLookupHash();

  @override
  String toString() {
    return r'cardLookupProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<MemberCard?> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<MemberCard?> create(Ref ref) {
    final argument = this.argument as String;
    return cardLookup(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CardLookupProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cardLookupHash() => r'bd3febfd2f0ed440c15d6a3d425b0b8639797bb6';

/// Looks up an active member card by its card value.
///
/// Used by the check-in flow to resolve a scanned card to a member.

final class CardLookupFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<MemberCard?>, String> {
  CardLookupFamily._()
      : super(
          retry: null,
          name: r'cardLookupProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Looks up an active member card by its card value.
  ///
  /// Used by the check-in flow to resolve a scanned card to a member.

  CardLookupProvider call(
    String cardValue,
  ) =>
      CardLookupProvider._(argument: cardValue, from: this);

  @override
  String toString() => r'cardLookupProvider';
}
