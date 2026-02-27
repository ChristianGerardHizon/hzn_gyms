import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/membership_add_on_repository.dart';
import '../../domain/membership_add_on.dart';

part 'membership_add_ons_controller.g.dart';

/// Controller for managing add-ons for a specific membership plan.
@riverpod
class MembershipAddOnsController extends _$MembershipAddOnsController {
  MembershipAddOnRepository get _repository =>
      ref.read(membershipAddOnRepositoryProvider);

  @override
  Future<List<MembershipAddOn>> build(String membershipId) async {
    final result = await _repository.fetchByMembership(membershipId);

    return result.fold(
      (failure) => throw failure,
      (addOns) => addOns,
    );
  }

  /// Refreshes the add-on list.
  Future<void> refresh() async {
    _repository.invalidateCache();
    state = const AsyncLoading();

    final result = await _repository.fetchByMembership(membershipId);

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (addOns) => AsyncData(addOns),
    );
  }

  /// Creates a new add-on.
  Future<MembershipAddOn?> createAddOn(MembershipAddOn addOn) async {
    final result = await _repository.create(addOn);
    return result.fold(
      (failure) => null,
      (created) {
        refresh();
        return created;
      },
    );
  }

  /// Updates an existing add-on.
  Future<bool> updateAddOn(MembershipAddOn addOn) async {
    final result = await _repository.update(addOn);
    return result.fold(
      (failure) => false,
      (_) {
        refresh();
        return true;
      },
    );
  }

  /// Deletes an add-on.
  Future<bool> deleteAddOn(String id) async {
    final result = await _repository.delete(id);
    return result.fold(
      (failure) => false,
      (_) {
        refresh();
        return true;
      },
    );
  }
}
