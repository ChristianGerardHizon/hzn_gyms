// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for a single member by ID.

@ProviderFor(member)
final memberProvider = MemberFamily._();

/// Provider for a single member by ID.

final class MemberProvider
    extends $FunctionalProvider<AsyncValue<Member?>, Member?, FutureOr<Member?>>
    with $FutureModifier<Member?>, $FutureProvider<Member?> {
  /// Provider for a single member by ID.
  MemberProvider._(
      {required MemberFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'memberProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$memberHash();

  @override
  String toString() {
    return r'memberProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Member?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Member?> create(Ref ref) {
    final argument = this.argument as String;
    return member(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MemberProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memberHash() => r'fd89b8c389699a0f0e89bed5ec7974d055967ea5';

/// Provider for a single member by ID.

final class MemberFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Member?>, String> {
  MemberFamily._()
      : super(
          retry: null,
          name: r'memberProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for a single member by ID.

  MemberProvider call(
    String id,
  ) =>
      MemberProvider._(argument: id, from: this);

  @override
  String toString() => r'memberProvider';
}
