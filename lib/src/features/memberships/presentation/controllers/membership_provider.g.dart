// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for a single membership plan by ID.

@ProviderFor(membership)
final membershipProvider = MembershipFamily._();

/// Provider for a single membership plan by ID.

final class MembershipProvider extends $FunctionalProvider<
        AsyncValue<Membership?>, Membership?, FutureOr<Membership?>>
    with $FutureModifier<Membership?>, $FutureProvider<Membership?> {
  /// Provider for a single membership plan by ID.
  MembershipProvider._(
      {required MembershipFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'membershipProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$membershipHash();

  @override
  String toString() {
    return r'membershipProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Membership?> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Membership?> create(Ref ref) {
    final argument = this.argument as String;
    return membership(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MembershipProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$membershipHash() => r'ba3fff279bd3d4d3f64d8a1ada12835323a4c2ef';

/// Provider for a single membership plan by ID.

final class MembershipFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Membership?>, String> {
  MembershipFamily._()
      : super(
          retry: null,
          name: r'membershipProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for a single membership plan by ID.

  MembershipProvider call(
    String id,
  ) =>
      MembershipProvider._(argument: id, from: this);

  @override
  String toString() => r'membershipProvider';
}
