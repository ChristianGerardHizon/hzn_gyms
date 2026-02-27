import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/currency_format.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../pos/domain/sale.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../data/membership_sale_helper.dart';
import '../../data/repositories/member_membership_add_on_repository.dart';
import '../../data/repositories/member_membership_repository.dart';
import '../../domain/membership.dart';
import '../../domain/membership_add_on.dart';
import '../controllers/membership_add_ons_controller.dart';
import '../controllers/memberships_controller.dart';

/// Reusable membership plan selection + add-on content.
///
/// Two modes:
/// - **Standalone** (`collectOnly: false`): Renders its own purchase button
///   and executes the full purchase flow (creates MemberMembership + add-on
///   records). Used by [PurchaseMembershipDialog].
/// - **Collect-only** (`collectOnly: true`): Only manages selection state via
///   the provided [selectedMembership] and [selectedAddOns] notifiers.
///   Does not render a purchase button. The parent widget handles the save.
class MembershipPurchaseContent extends HookConsumerWidget {
  const MembershipPurchaseContent({
    super.key,
    required this.memberId,
    required this.memberName,
    this.onPurchased,
    this.collectOnly = false,
    this.selectedMembership,
    this.selectedAddOns,
  });

  /// The member to purchase for.
  final String memberId;
  final String memberName;

  /// Called after a successful purchase (standalone mode only).
  /// Receives the created [Sale] and total price.
  final void Function(Sale sale, num totalPrice)? onPurchased;

  /// When true, only manages selection state without executing purchase.
  final bool collectOnly;

  /// External state for the selected membership plan (collect-only mode).
  final ValueNotifier<Membership?>? selectedMembership;

  /// External state for selected add-ons (collect-only mode).
  final ValueNotifier<Set<MembershipAddOn>>? selectedAddOns;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final membershipsAsync = ref.watch(membershipsControllerProvider);

    // Use external notifiers in collect-only mode, local state otherwise.
    final localMembership = useState<Membership?>(null);
    final localAddOns = useState<Set<MembershipAddOn>>({});
    final isPurchasing = useState(false);

    final membershipState = selectedMembership ?? localMembership;
    final addOnsState = selectedAddOns ?? localAddOns;

    // Reset add-on selections when membership changes.
    // Scheduled post-frame to avoid setState during build when using
    // external ValueNotifiers from a parent widget.
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        addOnsState.value = {};
      });
      return null;
    }, [membershipState.value?.id]);

    // Compute total price
    final addOnTotal =
        addOnsState.value.fold<num>(0, (sum, a) => sum + a.price);
    final totalPrice = (membershipState.value?.price ?? 0) + addOnTotal;

    Future<void> handlePurchase() async {
      final plan = membershipState.value;
      if (plan == null) return;

      isPurchasing.value = true;

      final branchId = ref.read(currentBranchIdProvider) ?? '';
      final auth = ref.read(currentAuthProvider);
      final startDate = DateTime.now();
      final endDate = startDate.add(Duration(days: plan.durationDays));

      // 1. Create a Sale record for this membership purchase
      final saleResult = await createMembershipSale(
        ref: ref,
        memberId: memberId,
        memberName: memberName,
        plan: plan,
        addOns: addOnsState.value,
        branchId: branchId,
      );

      Sale? createdSale;
      saleResult.fold(
        (failure) {},
        (sale) => createdSale = sale,
      );

      if (createdSale == null) {
        isPurchasing.value = false;
        if (context.mounted) {
          showErrorSnackBar(
            context,
            message: 'Failed to create sale for membership',
            useRootMessenger: false,
          );
        }
        return;
      }

      final saleId = createdSale!.id;

      // 2. Create MemberMembership record linked to the sale
      final repo = ref.read(memberMembershipRepositoryProvider);
      final result = await repo.create(
        memberId: memberId,
        membershipId: plan.id,
        startDate: startDate,
        endDate: endDate,
        branchId: branchId,
        saleId: saleId,
        soldBy: auth?.user.id,
      );

      final createdMembership = result.fold(
        (failure) => null,
        (membership) => membership,
      );

      if (createdMembership == null) {
        isPurchasing.value = false;
        if (context.mounted) {
          showErrorSnackBar(
            context,
            message: 'Failed to purchase membership',
            useRootMessenger: false,
          );
        }
        return;
      }

      // 3. Create add-on records for each selected add-on
      if (addOnsState.value.isNotEmpty) {
        final addOnRepo =
            ref.read(memberMembershipAddOnRepositoryProvider);
        for (final addOn in addOnsState.value) {
          await addOnRepo.create(
            memberMembershipId: createdMembership.id,
            membershipAddOnId: addOn.id,
            addOnName: addOn.name,
            price: addOn.price,
          );
        }
      }

      isPurchasing.value = false;

      if (context.mounted) {
        showSuccessSnackBar(
          context,
          message: 'Membership purchased for $memberName',
          useRootMessenger: false,
        );
        onPurchased?.call(createdSale!, totalPrice);
      }
    }

    return Column(
      children: [
        // Plan list and add-ons
        Expanded(
          child: membershipsAsync.when(
            data: (memberships) {
              final activePlans =
                  memberships.where((m) => m.isActive).toList();

              if (activePlans.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.card_membership_outlined,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No active membership plans available',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  // Plan selection
                  ...activePlans.map((plan) {
                    final isSelected =
                        membershipState.value?.id == plan.id;

                    return Card(
                      elevation: isSelected ? 2 : 0,
                      color: isSelected
                          ? theme.colorScheme.primaryContainer
                          : null,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.card_membership,
                            color: isSelected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        title: Text(plan.name),
                        subtitle: Text(
                          '${plan.durationDisplay} - ${plan.price.toCurrency()}',
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: theme.colorScheme.primary,
                              )
                            : null,
                        onTap: () => membershipState.value = plan,
                      ),
                    );
                  }),

                  // Add-ons section (only when plan is selected)
                  if (membershipState.value != null)
                    AddOnSelectionSection(
                      membershipId: membershipState.value!.id,
                      selectedAddOns: addOnsState,
                    ),
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (_, __) => Center(
              child: Text(
                'Error loading plans',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ),
        ),

        // Purchase button (standalone mode only)
        if (!collectOnly)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: membershipState.value != null &&
                        !isPurchasing.value
                    ? handlePurchase
                    : null,
                icon: isPurchasing.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.shopping_cart),
                label: Text(
                  membershipState.value != null
                      ? 'Purchase ${membershipState.value!.name} - ${totalPrice.toCurrency()}'
                      : 'Select a plan',
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Section showing available add-ons for the selected membership plan.
class AddOnSelectionSection extends ConsumerWidget {
  const AddOnSelectionSection({
    super.key,
    required this.membershipId,
    required this.selectedAddOns,
  });

  final String membershipId;
  final ValueNotifier<Set<MembershipAddOn>> selectedAddOns;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final addOnsAsync =
        ref.watch(membershipAddOnsControllerProvider(membershipId));

    return addOnsAsync.when(
      data: (addOns) {
        final activeAddOns = addOns.where((a) => a.isActive).toList();
        if (activeAddOns.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Add-Ons (Optional)',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 4),
            ...activeAddOns.map((addOn) {
              final isSelected = selectedAddOns.value.contains(addOn);

              return CheckboxListTile(
                value: isSelected,
                onChanged: (checked) {
                  final current =
                      Set<MembershipAddOn>.from(selectedAddOns.value);
                  if (checked == true) {
                    current.add(addOn);
                  } else {
                    current.remove(addOn);
                  }
                  selectedAddOns.value = current;
                },
                title: Text(addOn.name),
                subtitle: Text(addOn.price.toCurrency()),
                secondary: Icon(
                  Icons.extension,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                dense: true,
              );
            }),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
