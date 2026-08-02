import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../../core/widgets/dialog_close_handler.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../dashboard/presentation/controllers/dashboard_refresh.dart';
import '../../../pos/domain/sale.dart';
import '../../../sales/presentation/widgets/record_payment_dialog.dart';
import '../controllers/member_memberships_controller.dart';
import 'membership_purchase_content.dart';

/// Result returned when a membership is purchased successfully.
class MembershipPurchaseResult {
  const MembershipPurchaseResult({
    this.sale,
    required this.totalPrice,
    this.queuedOffline = false,
  });

  /// Null when the renewal was excluded from sales (no receipt created).
  final Sale? sale;
  final num totalPrice;
  final bool queuedOffline;

  bool get excludedFromSales => sale == null;
}

/// Shows a dialog for purchasing a membership for a member.
///
/// Returns a [MembershipPurchaseResult] if the membership was purchased
/// successfully, or `null` if the dialog was dismissed.
Future<MembershipPurchaseResult?> showPurchaseMembershipDialog(
  BuildContext context, {
  required String memberId,
  required String memberName,
  String? preselectedMembershipId,
  bool isRenewal = false,
}) {
  return showConstrainedDialog<MembershipPurchaseResult>(
    context: context,
    builder: (context) => PurchaseMembershipDialog(
      memberId: memberId,
      memberName: memberName,
      preselectedMembershipId: preselectedMembershipId,
      isRenewal: isRenewal,
    ),
  );
}

/// Shows a walk-in / day-pass sale dialog (customer name + plan, no member).
Future<MembershipPurchaseResult?> showWalkInSaleDialog(BuildContext context) {
  return showConstrainedDialog<MembershipPurchaseResult>(
    context: context,
    builder: (context) => const PurchaseMembershipDialog(guestMode: true),
  );
}

/// Success message shown after a membership renewal completes.
String membershipRenewalSuccessMessage({
  required bool queuedOffline,
  required bool excludedFromSales,
}) {
  if (queuedOffline) {
    return excludedFromSales
        ? 'Membership renewal queued (excluded from sales) — will sync when online'
        : 'Membership renewal queued — will sync when online';
  }
  return 'Membership renewed successfully';
}

/// Whether the purchase flow should open [showRecordPaymentDialog].
bool shouldOpenRecordPaymentAfterPurchase({
  required bool isRenewal,
  required MembershipPurchaseResult result,
}) {
  if (isRenewal) return false;
  if (result.excludedFromSales) return false;
  if (result.queuedOffline) return false;
  return result.sale != null;
}

/// Opens the purchase (or renew) flow and records payment when complete.
///
/// Returns `true` when a membership was saved (including renewals).
Future<bool> purchaseMembershipAndRecordPayment(
  BuildContext context,
  WidgetRef ref, {
  required String memberId,
  required String memberName,
  String? preselectedMembershipId,
  bool isRenewal = false,
}) async {
  final result = await showPurchaseMembershipDialog(
    context,
    memberId: memberId,
    memberName: memberName,
    preselectedMembershipId: preselectedMembershipId,
    isRenewal: isRenewal,
  );

  if (result == null) return false;

  ref.invalidate(memberMembershipsControllerProvider(memberId));
  refreshDashboardAfterMemberChange(ref);

  if (isRenewal) {
    if (context.mounted) {
      showSuccessSnackBar(
        context,
        message: membershipRenewalSuccessMessage(
          queuedOffline: result.queuedOffline,
          excludedFromSales: result.excludedFromSales,
        ),
      );
    }
    return true;
  }

  if (result.excludedFromSales) {
    return true;
  }

  if (result.queuedOffline) {
    if (context.mounted) {
      showInfoSnackBar(
        context,
        message: 'Membership queued — record payment once synced and online.',
      );
    }
    return true;
  }

  if (!shouldOpenRecordPaymentAfterPurchase(isRenewal: isRenewal, result: result)) {
    return true;
  }

  if (context.mounted) {
    await showRecordPaymentDialog(
      context,
      sale: result.sale!,
      balanceDue: result.totalPrice,
    );
    if (context.mounted) refreshDashboardAfterMemberChange(ref);
  }
  return true;
}

/// Opens walk-in sale flow and records payment when complete.
Future<void> sellWalkInAndRecordPayment(
  BuildContext context,
  WidgetRef ref,
) async {
  final result = await showWalkInSaleDialog(context);
  if (result == null || !context.mounted) return;

  if (result.queuedOffline) {
    showInfoSnackBar(
      context,
      message: 'Sale queued — record payment once synced and online.',
    );
    return;
  }

  if (result.sale != null) {
    // Show the new walk-in on Recent Transactions and Sales list before payment.
    refreshSalesData(ref);
    await showRecordPaymentDialog(
      context,
      sale: result.sale!,
      balanceDue: result.totalPrice,
    );
    // Refresh again so paid status / KPI totals match the payment.
    if (context.mounted) refreshSalesData(ref);
  }
}

class PurchaseMembershipDialog extends StatelessWidget {
  const PurchaseMembershipDialog({
    super.key,
    this.memberId = '',
    this.memberName = '',
    this.preselectedMembershipId,
    this.isRenewal = false,
    this.guestMode = false,
  });

  final String memberId;
  final String memberName;
  final String? preselectedMembershipId;
  final bool isRenewal;
  final bool guestMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ScaffoldMessenger(
      child: Builder(
        builder: (context) => DialogCloseHandler(
          child: ConstrainedDialogContent(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                guestMode
                                    ? 'Walk-in'
                                    : isRenewal
                                    ? 'Renew Membership'
                                    : 'Purchase Membership',
                                style: theme.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                guestMode
                                    ? 'Day pass — name and plan only'
                                    : 'For $memberName',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Plan list, add-ons, and purchase button
                  Expanded(
                    child: MembershipPurchaseContent(
                      memberId: memberId,
                      memberName: memberName,
                      guestMode: guestMode,
                      preselectedMembershipId: preselectedMembershipId,
                      isRenewal: isRenewal,
                      onPurchased:
                          (sale, totalPrice, {queuedOffline = false}) =>
                              Navigator.of(context).pop(
                                MembershipPurchaseResult(
                                  sale: sale,
                                  totalPrice: totalPrice,
                                  queuedOffline: queuedOffline,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
