// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_members_count_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Count of members with currently active memberships.
///
/// Queries memberMemberships where status = 'active'
/// and current date is between startDate and endDate.

@ProviderFor(activeMembersCount)
final activeMembersCountProvider = ActiveMembersCountProvider._();

/// Count of members with currently active memberships.
///
/// Queries memberMemberships where status = 'active'
/// and current date is between startDate and endDate.

final class ActiveMembersCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Count of members with currently active memberships.
  ///
  /// Queries memberMemberships where status = 'active'
  /// and current date is between startDate and endDate.
  ActiveMembersCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeMembersCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeMembersCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return activeMembersCount(ref);
  }
}

String _$activeMembersCountHash() =>
    r'a84b6fbe5a2b71bf5894ec0d23cb6aaba9fef09d';

/// Active memberships for the current branch (KPI breakdown list).
///
/// Same filter as [activeMembersCount]; one row per membership.

@ProviderFor(activeMembersList)
final activeMembersListProvider = ActiveMembersListProvider._();

/// Active memberships for the current branch (KPI breakdown list).
///
/// Same filter as [activeMembersCount]; one row per membership.

final class ActiveMembersListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MemberMembership>>,
          List<MemberMembership>,
          FutureOr<List<MemberMembership>>
        >
    with
        $FutureModifier<List<MemberMembership>>,
        $FutureProvider<List<MemberMembership>> {
  /// Active memberships for the current branch (KPI breakdown list).
  ///
  /// Same filter as [activeMembersCount]; one row per membership.
  ActiveMembersListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeMembersListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeMembersListHash();

  @$internal
  @override
  $FutureProviderElement<List<MemberMembership>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MemberMembership>> create(Ref ref) {
    return activeMembersList(ref);
  }
}

String _$activeMembersListHash() => r'4fe3c971b3eada0dcbea86f030175c9f6e4318b3';
