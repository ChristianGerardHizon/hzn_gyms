// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_check_ins_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for fetching a specific member's check-in history.

@ProviderFor(memberCheckIns)
final memberCheckInsProvider = MemberCheckInsFamily._();

/// Provider for fetching a specific member's check-in history.

final class MemberCheckInsProvider extends $FunctionalProvider<
        AsyncValue<List<CheckIn>>, List<CheckIn>, FutureOr<List<CheckIn>>>
    with $FutureModifier<List<CheckIn>>, $FutureProvider<List<CheckIn>> {
  /// Provider for fetching a specific member's check-in history.
  MemberCheckInsProvider._(
      {required MemberCheckInsFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'memberCheckInsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$memberCheckInsHash();

  @override
  String toString() {
    return r'memberCheckInsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<CheckIn>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<CheckIn>> create(Ref ref) {
    final argument = this.argument as String;
    return memberCheckIns(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MemberCheckInsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memberCheckInsHash() => r'136df7cc4b0427ccdcfaece98f9e82cc6d3cd056';

/// Provider for fetching a specific member's check-in history.

final class MemberCheckInsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<CheckIn>>, String> {
  MemberCheckInsFamily._()
      : super(
          retry: null,
          name: r'memberCheckInsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for fetching a specific member's check-in history.

  MemberCheckInsProvider call(
    String memberId,
  ) =>
      MemberCheckInsProvider._(argument: memberId, from: this);

  @override
  String toString() => r'memberCheckInsProvider';
}
