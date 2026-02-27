// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expiring_memberships_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Memberships expiring within the next 7 days.
///
/// Queries memberMemberships where status = 'active'
/// and endDate is between now and now + 7 days.

@ProviderFor(expiringMemberships)
final expiringMembershipsProvider = ExpiringMembershipsProvider._();

/// Memberships expiring within the next 7 days.
///
/// Queries memberMemberships where status = 'active'
/// and endDate is between now and now + 7 days.

final class ExpiringMembershipsProvider extends $FunctionalProvider<
        AsyncValue<List<MemberMembership>>,
        List<MemberMembership>,
        FutureOr<List<MemberMembership>>>
    with
        $FutureModifier<List<MemberMembership>>,
        $FutureProvider<List<MemberMembership>> {
  /// Memberships expiring within the next 7 days.
  ///
  /// Queries memberMemberships where status = 'active'
  /// and endDate is between now and now + 7 days.
  ExpiringMembershipsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'expiringMembershipsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$expiringMembershipsHash();

  @$internal
  @override
  $FutureProviderElement<List<MemberMembership>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<MemberMembership>> create(Ref ref) {
    return expiringMemberships(ref);
  }
}

String _$expiringMembershipsHash() =>
    r'f8ae560f239cb8d03dd6dbd337dece06ee3ede10';
