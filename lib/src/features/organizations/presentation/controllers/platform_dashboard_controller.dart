import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/organization.dart';
import '../../domain/organization_setup_checks.dart';
import '../controllers/organizations_controller.dart';

part 'platform_dashboard_controller.g.dart';

/// Summary metrics for the platform admin dashboard.
@Riverpod(keepAlive: true)
Future<PlatformDashboardSummary> platformDashboardSummary(Ref ref) async {
  final organizations = await ref.watch(organizationsControllerProvider.future);
  return PlatformDashboardSummary.fromOrganizations(organizations);
}

/// Recent organizations for the platform dashboard (newest first, max 5).
@Riverpod(keepAlive: true)
Future<List<Organization>> platformRecentOrganizations(Ref ref) async {
  final organizations = await ref.watch(organizationsControllerProvider.future);
  final sorted = [...organizations]
    ..sort((a, b) {
      final aCreated = a.created ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bCreated = b.created ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bCreated.compareTo(aCreated);
    });
  return sorted.take(5).toList();
}
