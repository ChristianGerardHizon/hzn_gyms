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
    r'52fbc35d5aaf52a91b147e30dc9b90e819bd953d';
