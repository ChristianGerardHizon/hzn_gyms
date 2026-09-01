import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../dashboard/presentation/controllers/dashboard_refresh.dart';
import 'sale_provider.dart';

/// Refreshes sale detail, paginated sales list, and dashboard KPIs after void.
void refreshAfterSaleVoided(WidgetRef ref, String saleId) {
  refreshAfterSaleVoidedOnContainer(ref.container, saleId);
}

/// Same as [refreshAfterSaleVoided] using a [ProviderContainer] (safe after async gaps).
void refreshAfterSaleVoidedOnContainer(ProviderContainer container, String saleId) {
  container.invalidate(saleProvider(saleId));
  refreshSalesDataOnContainer(container);
}
