// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_members_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Count of new members registered today at the current branch.
///
/// Derived from [todaysNewMembersList] so the card and breakdown dialog
/// never disagree.

@ProviderFor(todaysNewMembersCount)
final todaysNewMembersCountProvider = TodaysNewMembersCountProvider._();

/// Count of new members registered today at the current branch.
///
/// Derived from [todaysNewMembersList] so the card and breakdown dialog
/// never disagree.

final class TodaysNewMembersCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Count of new members registered today at the current branch.
  ///
  /// Derived from [todaysNewMembersList] so the card and breakdown dialog
  /// never disagree.
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
    r'acb042a211fb33a82de0cfda7ae696e6bacac75e';

/// Members registered today (KPI breakdown list), each paired with the
/// membership plan they signed up for, filtered to the current branch.
///
/// Members are attributed to a branch via [NewMemberEntry.effectiveBranchId].
/// Unfiltered when viewing all branches. Sorted newest first.

@ProviderFor(todaysNewMembersList)
final todaysNewMembersListProvider = TodaysNewMembersListProvider._();

/// Members registered today (KPI breakdown list), each paired with the
/// membership plan they signed up for, filtered to the current branch.
///
/// Members are attributed to a branch via [NewMemberEntry.effectiveBranchId].
/// Unfiltered when viewing all branches. Sorted newest first.

final class TodaysNewMembersListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<NewMemberEntry>>,
          List<NewMemberEntry>,
          FutureOr<List<NewMemberEntry>>
        >
    with
        $FutureModifier<List<NewMemberEntry>>,
        $FutureProvider<List<NewMemberEntry>> {
  /// Members registered today (KPI breakdown list), each paired with the
  /// membership plan they signed up for, filtered to the current branch.
  ///
  /// Members are attributed to a branch via [NewMemberEntry.effectiveBranchId].
  /// Unfiltered when viewing all branches. Sorted newest first.
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
  $FutureProviderElement<List<NewMemberEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<NewMemberEntry>> create(Ref ref) {
    return todaysNewMembersList(ref);
  }
}

String _$todaysNewMembersListHash() =>
    r'5a270ba9e6f5432464999aca76aa6881d307430a';
