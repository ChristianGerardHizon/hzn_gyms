import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../quantity_units/data/repositories/quantity_unit_repository.dart';
import '../../../quantity_units/domain/quantity_unit.dart';

part 'quantity_units_controller.g.dart';

/// Controller for managing quantity units list in settings.
@Riverpod(keepAlive: true)
class QuantityUnitsController extends _$QuantityUnitsController {
  @override
  Future<List<QuantityUnit>> build() async {
    return _fetchUnits();
  }

  QuantityUnitRepository get _repository =>
      ref.read(quantityUnitRepositoryProvider);

  Future<List<QuantityUnit>> _fetchUnits() async {
    final result = await _repository.fetchAll();
    return result.fold(
      (failure) => throw failure,
      (units) => units,
    );
  }

  /// Refreshes the quantity units list.
  Future<void> refresh() async {
    // Avoid wiping previous data so list UIs stay mounted.
    if (!state.hasValue) {
      state = const AsyncValue.loading();
    }
    state = await AsyncValue.guard(_fetchUnits);
  }

  /// Creates a new quantity unit.
  ///
  /// Returns true if successful, false otherwise.
  Future<bool> createUnit(QuantityUnit unit) async {
    final result = await _repository.create(unit);
    return result.fold(
      (failure) => false,
      (created) {
        // Refresh the list
        refresh();
        return true;
      },
    );
  }

  /// Updates an existing quantity unit.
  ///
  /// Returns true if successful, false otherwise.
  Future<bool> updateUnit(QuantityUnit unit) async {
    final result = await _repository.update(unit);
    return result.fold(
      (failure) => false,
      (updated) {
        // Refresh the list
        refresh();
        return true;
      },
    );
  }

  /// Deletes a quantity unit by ID (soft delete).
  ///
  /// Returns true if successful, false otherwise.
  Future<bool> deleteUnit(String id) async {
    final result = await _repository.delete(id);
    return result.fold(
      (failure) => false,
      (_) {
        // Refresh the list
        refresh();
        return true;
      },
    );
  }
}
