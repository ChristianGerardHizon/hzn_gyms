// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_members_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Count of new members registered today.
///
/// Queries the members collection with a date filter on `created`.
/// Members are global (no branch filter).

@ProviderFor(todaysNewMembersCount)
final todaysNewMembersCountProvider = TodaysNewMembersCountProvider._();

/// Count of new members registered today.
///
/// Queries the members collection with a date filter on `created`.
/// Members are global (no branch filter).

final class TodaysNewMembersCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Count of new members registered today.
  ///
  /// Queries the members collection with a date filter on `created`.
  /// Members are global (no branch filter).
  TodaysNewMembersCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todaysNewMembersCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todaysNewMembersCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return todaysNewMembersCount(ref);
  }
}

String _$todaysNewMembersCountHash() =>
    r'ac616133ea3d40457fc1a236175704b6d2d6a24f';

/// Members registered today (KPI breakdown list).
///
/// Same filter as [todaysNewMembersCount]; sorted newest first.

@ProviderFor(todaysNewMembersList)
final todaysNewMembersListProvider = TodaysNewMembersListProvider._();

/// Members registered today (KPI breakdown list).
///
/// Same filter as [todaysNewMembersCount]; sorted newest first.

final class TodaysNewMembersListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Member>>,
          List<Member>,
          FutureOr<List<Member>>
        >
    with $FutureModifier<List<Member>>, $FutureProvider<List<Member>> {
  /// Members registered today (KPI breakdown list).
  ///
  /// Same filter as [todaysNewMembersCount]; sorted newest first.
  TodaysNewMembersListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todaysNewMembersListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todaysNewMembersListHash();

  @$internal
  @override
  $FutureProviderElement<List<Member>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Member>> create(Ref ref) {
    return todaysNewMembersList(ref);
  }
}

String _$todaysNewMembersListHash() =>
    r'c24aa11942214f4636455ce0a5cb43fe6dae5afe';
