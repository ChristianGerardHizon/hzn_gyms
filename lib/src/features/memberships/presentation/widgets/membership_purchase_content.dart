import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/currency_format.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../pos/domain/sale.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../data/membership_purchase_orchestrator.dart';
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
    this.preselectedMembershipId,
    this.isRenewal = false,
  });

  /// The member to purchase for.
  final String memberId;
  final String memberName;

  /// Called after a successful purchase (standalone mode only).
  ///
  /// [sale] is null when the renewal was excluded from sales (no receipt).
  final void Function(Sale? sale, num totalPrice, {bool queuedOffline})?
  onPurchased;

  /// When true, only manages selection state without executing purchase.
  final bool collectOnly;

  /// External state for the selected membership plan (collect-only mode).
  final ValueNotifier<Membership?>? selectedMembership;

  /// External state for selected add-ons (collect-only mode).
  final ValueNotifier<Set<MembershipAddOn>>? selectedAddOns;

  /// When set, pre-selects this plan and skips the plan selection list.
  final String? preselectedMembershipId;

  /// Whether this flow is renewing an existing membership.
  final bool isRenewal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final membershipsAsync = ref.watch(membershipsControllerProvider);

    // Use external notifiers in collect-only mode, local state otherwise.
    final localMembership = useState<Membership?>(null);
    final localAddOns = useState<Set<MembershipAddOn>>({});
    final isPurchasing = useState(false);
    final excludeFromSales = useState(false);
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final showInactive = useState(false);

    useEffect(() {
      void listener() {
        searchQuery.value = searchController.text;
      }

      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    final membershipState = selectedMembership ?? localMembership;
    final addOnsState = selectedAddOns ?? localAddOns;
    final skipPlanSelection = preselectedMembershipId != null;

    // Pre-select the membership plan when renewing.
    useEffect(() {
      if (preselectedMembershipId == null) return null;

      final memberships = membershipsAsync.asData?.value;
      if (memberships == null) return null;

      final plan = memberships.cast<Membership?>().firstWhere(
        (m) => m?.id == preselectedMembershipId,
        orElse: () => null,
      );

      if (plan != null && plan.isActive) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          membershipState.value = plan;
        });
      }

      return null;
    }, [preselectedMembershipId, membershipsAsync]);

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
    final addOnTotal = addOnsState.value.fold<num>(
      0,
      (sum, a) => sum + a.price,
    );
    final totalPrice = (membershipState.value?.price ?? 0) + addOnTotal;

    Future<void> handlePurchase() async {
      final plan = membershipState.value;
      if (plan == null) return;

      isPurchasing.value = true;

      final branchId = ref.read(effectiveBranchIdForWriteProvider) ?? '';
      final auth = ref.read(currentAuthProvider);
      final orchestrator = ref.read(membershipPurchaseOrchestratorProvider);
      final skipSale = isRenewal && excludeFromSales.value;

      if (orchestrator.shouldQueueOffline) {
        final result = await orchestrator.purchase(
          memberId: memberId,
          memberName: memberName,
          plan: plan,
          addOns: addOnsState.value,
          branchId: branchId,
          soldBy: auth?.user.id,
          excludeFromSales: skipSale,
        );

        isPurchasing.value = false;

        result.fold(
          (failure) {
            if (context.mounted) {
              showErrorSnackBar(
                context,
                message: 'Failed to queue membership: ${failure.messageString}',
                useRootMessenger: false,
              );
            }
          },
          (purchaseResult) {
            if (context.mounted) {
              final message = skipSale
                  ? 'Membership renewal queued (excluded from sales) — will sync when online'
                  : isRenewal
                  ? 'Membership renewal queued — will sync when online'
                  : 'Membership purchase queued — will sync when online';
              showSuccessSnackBar(
                context,
                message: message,
                useRootMessenger: false,
              );
              onPurchased?.call(
                purchaseResult.sale,
                purchaseResult.totalPrice,
                queuedOffline: true,
              );
            }
          },
        );
        return;
      }

      final startDate = DateTime.now();
      final endDate = startDate.add(Duration(days: plan.durationDays));

      Sale? createdSale;

      if (!skipSale) {
        // 1. Create a Sale record for this membership purchase
        final saleResult = await createMembershipSale(
          ref: ref,
          memberId: memberId,
          memberName: memberName,
          plan: plan,
          addOns: addOnsState.value,
          branchId: branchId,
        );

        saleResult.fold((failure) {}, (sale) => createdSale = sale);

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
      }

      // 2. Create MemberMembership record (optionally linked to the sale)
      final repo = ref.read(memberMembershipRepositoryProvider);
      final result = await repo.create(
        memberId: memberId,
        membershipId: plan.id,
        startDate: startDate,
        endDate: endDate,
        branchId: branchId,
        saleId: createdSale?.id,
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
            message: skipSale
                ? 'Failed to renew membership'
                : 'Failed to purchase membership',
            useRootMessenger: false,
          );
        }
        return;
      }

      // 3. Create add-on records for each selected add-on
      if (addOnsState.value.isNotEmpty) {
        final addOnRepo = ref.read(memberMembershipAddOnRepositoryProvider);
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
          message: skipSale
              ? 'Membership renewed for $memberName (excluded from sales)'
              : 'Membership purchased for $memberName',
          useRootMessenger: false,
        );
        onPurchased?.call(createdSale, totalPrice);
      }
    }

    return Column(
      children: [
        // Plan list and add-ons
        Expanded(
          child: membershipsAsync.when(
            data: (memberships) {
              void sortPlans(List<Membership> plans) {
                plans.sort((a, b) {
                  if (a.isFavorite != b.isFavorite) {
                    return a.isFavorite ? -1 : 1;
                  }
                  return a.name.toLowerCase().compareTo(b.name.toLowerCase());
                });
              }

              final activePlans = memberships.where((m) => m.isActive).toList();
              sortPlans(activePlans);

              final inactivePlans = memberships
                  .where((m) => !m.isActive)
                  .toList();
              sortPlans(inactivePlans);

              final visiblePlans = showInactive.value
                  ? [...activePlans, ...inactivePlans]
                  : activePlans;

              if (skipPlanSelection) {
                final plan = membershipState.value;
                if (plan == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'This membership plan is no longer available.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(8),
                  children: [
                    Card(
                      color: theme.colorScheme.primaryContainer,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary,
                          child: Icon(
                            Icons.card_membership,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                        title: Text(plan.name),
                        subtitle: Text(
                          '${plan.durationDisplay} - ${plan.price.toCurrency()}',
                        ),
                      ),
                    ),
                    AddOnSelectionSection(
                      membershipId: plan.id,
                      selectedAddOns: addOnsState,
                    ),
                  ],
                );
              }

              final query = searchQuery.value.toLowerCase().trim();
              final filteredPlans = query.isEmpty
                  ? visiblePlans
                  : visiblePlans.where((m) {
                      return m.name.toLowerCase().contains(query) ||
                          (m.description?.toLowerCase().contains(query) ??
                              false) ||
                          m.durationDisplay.toLowerCase().contains(query);
                    }).toList();

              final hasInactive = inactivePlans.isNotEmpty;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            hintText: showInactive.value
                                ? 'Search all membership plans...'
                                : 'Search membership plans...',
                            border: const OutlineInputBorder(),
                            isDense: true,
                            suffixIcon: searchQuery.value.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () => searchController.clear(),
                                  )
                                : null,
                          ),
                        ),
                        if (hasInactive) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: FilterChip(
                              selected: showInactive.value,
                              showCheckmark: false,
                              avatar: Icon(
                                showInactive.value
                                    ? Icons.visibility
                                    : Icons.visibility_off_outlined,
                                size: 16,
                              ),
                              label: Text(
                                showInactive.value
                                    ? 'Including inactive'
                                    : 'Include inactive',
                              ),
                              labelStyle: theme.textTheme.labelMedium,
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              onSelected: (selected) {
                                showInactive.value = selected;
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(8),
                      children: [
                        if (filteredPlans.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Text(
                                query.isEmpty
                                    ? (showInactive.value
                                          ? 'No membership plans available'
                                          : 'No active membership plans available')
                                    : 'No plans match "${searchQuery.value}"',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        else
                          ...filteredPlans.map((plan) {
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
                                      : theme
                                            .colorScheme
                                            .surfaceContainerHighest,
                                  child: Icon(
                                    Icons.card_membership,
                                    color: isSelected
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(child: Text(plan.name)),
                                    if (!plan.isActive) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme
                                              .colorScheme
                                              .surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          'Inactive',
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                subtitle: Text(
                                  '${plan.durationDisplay} - ${plan.price.toCurrency()}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (plan.isFavorite)
                                      Icon(
                                        Icons.star,
                                        size: 20,
                                        color: theme.colorScheme.primary,
                                      ),
                                    if (isSelected) ...[
                                      if (plan.isFavorite)
                                        const SizedBox(width: 4),
                                      Icon(
                                        Icons.check_circle,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ],
                                  ],
                                ),
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
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
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

        // Purchase / renew actions (standalone mode only)
        if (!collectOnly)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isRenewal)
                  CheckboxListTile(
                    value: excludeFromSales.value,
                    onChanged: isPurchasing.value
                        ? null
                        : (checked) {
                            excludeFromSales.value = checked ?? false;
                          },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: const Text('Exclude from sales'),
                    subtitle: Text(
                      'Renew without creating a sale or receipt',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                if (isRenewal) const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed:
                        membershipState.value != null && !isPurchasing.value
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
                        : Icon(
                            isRenewal ? Icons.autorenew : Icons.shopping_cart,
                          ),
                    label: Text(
                      membershipState.value != null
                          ? excludeFromSales.value && isRenewal
                                ? 'Renew ${membershipState.value!.name} (no sale)'
                                : '${isRenewal ? 'Renew' : 'Purchase'} ${membershipState.value!.name} - ${totalPrice.toCurrency()}'
                          : isRenewal
                          ? 'Plan unavailable'
                          : 'Select a plan',
                    ),
                  ),
                ),
              ],
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
    final addOnsAsync = ref.watch(
      membershipAddOnsControllerProvider(membershipId),
    );

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
                  final current = Set<MembershipAddOn>.from(
                    selectedAddOns.value,
                  );
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
