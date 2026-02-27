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
    r'184f3422239794b85def8d2bf835f9f2be11b719';
