import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/printer_config_repository.dart';
import '../../domain/printer_config.dart';

part 'printer_configs_controller.g.dart';

/// Controller for managing printer configuration list state.
///
/// Provides methods for fetching and CRUD operations on printer configs.
@Riverpod(keepAlive: true)
class PrinterConfigsController extends _$PrinterConfigsController {
  PrinterConfigRepository get _repository =>
      ref.read(printerConfigRepositoryProvider);

  @override
  Future<List<PrinterConfig>> build() async {
    final result = await _repository.fetchAll();
    return result.fold(
      (failure) => throw failure,
      (configs) => configs,
    );
  }

  /// Refreshes the printer config list.
  Future<void> refresh() async {
    // Avoid wiping previous data so list UIs stay mounted.
    if (!state.hasValue) {
      state = const AsyncLoading();
    }

    final result = await _repository.fetchAll();

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (configs) => AsyncData(configs),
    );
  }

  /// Creates a new printer configuration.
  Future<bool> createConfig(PrinterConfig config) async {
    final result = await _repository.create(config);

    return result.fold(
      (failure) => false,
      (newConfig) {
        // If the new config is default, update other configs in list
        final currentList = state.value ?? [];
        List<PrinterConfig> updatedList;

        if (newConfig.isDefault) {
          updatedList = currentList.map((c) {
            return c.copyWith(isDefault: false);
          }).toList();
        } else {
          updatedList = List.from(currentList);
        }

        updatedList.insert(0, newConfig);
        state = AsyncData(updatedList);
        return true;
      },
    );
  }

  /// Updates an existing printer configuration.
  Future<bool> updateConfig(PrinterConfig config) async {
    final result = await _repository.update(config);

    return result.fold(
      (failure) => false,
      (updatedConfig) {
        final currentList = state.value ?? [];

        // If updated config is default, unset default on others
        final updatedList = currentList.map((c) {
          if (c.id == updatedConfig.id) {
            return updatedConfig;
          }
          if (updatedConfig.isDefault && c.isDefault) {
            return c.copyWith(isDefault: false);
          }
          return c;
        }).toList();

        state = AsyncData(updatedList);
        return true;
      },
    );
  }

  /// Deletes a printer configuration (soft delete).
  Future<bool> deleteConfig(String id) async {
    final result = await _repository.delete(id);

    return result.fold(
      (failure) => false,
      (_) {
        final currentList = state.value ?? [];
        final updatedList = currentList.where((c) => c.id != id).toList();
        state = AsyncData(updatedList);
        return true;
      },
    );
  }

  /// Sets a printer as the default.
  Future<bool> setAsDefault(String id) async {
    final result = await _repository.setAsDefault(id);

    return result.fold(
      (failure) => false,
      (_) {
        final currentList = state.value ?? [];
        final updatedList = currentList.map((c) {
          return c.copyWith(isDefault: c.id == id);
        }).toList();
        state = AsyncData(updatedList);
        return true;
      },
    );
  }

  /// Gets the default printer from the current list.
  PrinterConfig? get defaultPrinter {
    final list = state.value ?? [];
    try {
      return list.firstWhere((c) => c.isDefault && c.isEnabled);
    } catch (_) {
      return null;
    }
  }
}
