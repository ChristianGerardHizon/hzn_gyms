// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_memberships_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing a member's memberships (subscriptions).
///
/// Fetches all memberships for a specific member by ID.

@ProviderFor(MemberMembershipsController)
final memberMembershipsControllerProvider =
    MemberMembershipsControllerFamily._();

/// Controller for managing a member's memberships (subscriptions).
///
/// Fetches all memberships for a specific member by ID.
final class MemberMembershipsControllerProvider extends $AsyncNotifierProvider<
    MemberMembershipsController, List<MemberMembership>> {
  /// Controller for managing a member's memberships (subscriptions).
  ///
  /// Fetches all memberships for a specific member by ID.
  MemberMembershipsControllerProvider._(
      {required MemberMembershipsControllerFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'memberMembershipsControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$memberMembershipsControllerHash();

  @override
  String toString() {
    return r'memberMembershipsControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MemberMembershipsController create() => MemberMembershipsController();

  @override
  bool operator ==(Object other) {
    return other is MemberMembershipsControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memberMembershipsControllerHash() =>
    r'a826e07952b392e8a5928f2bf1368a5bd66cda1e';

/// Controller for managing a member's memberships (subscriptions).
///
/// Fetches all memberships for a specific member by ID.

final class MemberMembershipsControllerFamily extends $Family
    with
        $ClassFamilyOverride<
            MemberMembershipsController,
            AsyncValue<List<MemberMembership>>,
            List<MemberMembership>,
            FutureOr<List<MemberMembership>>,
            String> {
  MemberMembershipsControllerFamily._()
      : super(
          retry: null,
          name: r'memberMembershipsControllerProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Controller for managing a member's memberships (subscriptions).
  ///
  /// Fetches all memberships for a specific member by ID.

  MemberMembershipsControllerProvider call(
    String memberId,
  ) =>
      MemberMembershipsControllerProvider._(argument: memberId, from: this);

  @override
  String toString() => r'memberMembershipsControllerProvider';
}

/// Controller for managing a member's memberships (subscriptions).
///
/// Fetches all memberships for a specific member by ID.

abstract class _$MemberMembershipsController
    extends $AsyncNotifier<List<MemberMembership>> {
  late final _$args = ref.$arg as String;
  String get memberId => _$args;

  FutureOr<List<MemberMembership>> build(
    String memberId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref
        as $Ref<AsyncValue<List<MemberMembership>>, List<MemberMembership>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<MemberMembership>>, List<MemberMembership>>,
        AsyncValue<List<MemberMembership>>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
