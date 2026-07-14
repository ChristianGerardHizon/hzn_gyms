import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../data/repositories/reports_repository.dart';
import '../../domain/inventory_report.dart';

part 'inventory_report_controller.g.dart';

/// Fetches and caches inventory report data (current stock snapshot).
@Riverpod(keepAlive: true)
Future<InventoryReport> inventoryReport(Ref ref) async {
  final branchId = ref.watch(currentBranchIdProvider);
  final repository = ref.read(reportsRepositoryProvider);

  final result = await repository.getInventoryReport(branchId: branchId);

  return result.fold((failure) => throw failure, (report) => report);
}
