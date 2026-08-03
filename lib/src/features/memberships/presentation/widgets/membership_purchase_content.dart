import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/currency_format.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../../core/widgets/state/error_state.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../pos/domain/sale.dart';
import '../../../sales/presentation/widgets/unpaid_sale_flow.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../data/membership_purchase_orchestrator.dart';
import '../../data/membership_sale_helper.dart';
import '../../data/repositories/member_membership_add_on_repository.dart';
import '../../data/repositories/member_membership_repository.dart';
import '../../domain/member_membership.dart';
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
/// - **Guest** (`guestMode: true`): Walk-in / day-pass sale — customer name
///   only, plans with [Membership.memberNotRequired], no MemberMembership.
class MembershipPurchaseContent extends HookConsumerWidget {
  const MembershipPurchaseContent({
    super.key,
    this.memberId = '',
    this.memberName = '',
    this.onPurchased,
    this.collectOnly = false,
    this.guestMode = false,
    this.selectedMembership,
    this.selectedAddOns,
    this.preselectedMembershipId,
    this.isRenewal = false,
  });

  /// The member to purchase for (ignored in [guestMode]).
  final String memberId;
  final String memberName;

  /// Called after a successful purchase (standalone mode only).
  ///
  /// [sale] is null when the renewal was excluded from sales (no receipt).
  final void Function(Sale? sale, num totalPrice, {bool queuedOffline})?
  onPurchased;

  /// When true, only manages selection state without executing purchase.
  final bool collectOnly;

  /// When true, sell as walk-in (name + sale only, no member membership).
  final bool guestMode;

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
    final latestActiveEndDate = useState<DateTime?>(null);
    final customStartDate = useState<DateTime?>(null);
    final startDateManuallySet = useState(false);
    final guestNameController = useTextEditingController();
    final guestName = useState('');

    useEffect(() {
      void listener() {
        searchQuery.value = searchController.text;
      }

      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    useEffect(() {
      if (!guestMode) return null;
      void listener() {
        guestName.value = guestNameController.text;
      }

      guestNameController.addListener(listener);
      return () => guestNameController.removeListener(listener);
    }, [guestNameController, guestMode]);

    // Load latest active membership end date for stacking.
    useEffect(() {
      if (guestMode || memberId.isEmpty) return null;
      var cancelled = false;
      Future<void> loadActive() async {
        final branchId = ref.read(effectiveBranchIdForWriteProvider);
        final result = await ref
            .read(memberMembershipRepositoryProvider)
            .fetchActive(memberId, validAtBranchId: branchId);
        if (cancelled) return;
        result.fold((_) => latestActiveEndDate.value = null, (memberships) {
          latestActiveEndDate.value = memberships.isNotEmpty
              ? memberships.first.endDate
              : null;
        });
      }

      loadActive();
      return () => cancelled = true;
    }, [memberId, guestMode]);

    // Keep default start date in sync until the user customizes it.
    useEffect(() {
      if (guestMode || startDateManuallySet.value) return null;
      customStartDate.value = computeMembershipStartDate(
        latestActiveEndDate: latestActiveEndDate.value,
      );
      return null;
    }, [latestActiveEndDate.value, guestMode, startDateManuallySet.value]);

    final membershipState = selectedMembership ?? localMembership;
    final addOnsState = selectedAddOns ?? localAddOns;
    final skipPlanSelection = preselectedMembershipId != null;

    final selectedPlan = membershipState.value;
    final bonusDays = MembershipAddOn.totalBonusDays(addOnsState.value);
    final defaultStart = computeMembershipStartDate(
      latestActiveEndDate: latestActiveEndDate.value,
    );
    final previewStart = selectedPlan == null
        ? null
        : (customStartDate.value ?? defaultStart);
    final previewEnd = selectedPlan == null || previewStart == null
        ? null
        : computeMembershipEndDate(
            startDate: previewStart,
            durationValue: selectedPlan.durationValue,
            durationUnit: selectedPlan.durationUnit,
            bonusDays: bonusDays,
          );
    final isStacking =
        latestActiveEndDate.value != null &&
        !isBeforeToday(latestActiveEndDate.value!);
    final isUsingStackedDefault =
        previewStart != null &&
        toLocalDateOnly(previewStart) == toLocalDateOnly(defaultStart) &&
        isStacking;
    final dateFormat = useMemoized(() => DateFormat.yMMMd());

    Future<void> pickStartDate() async {
      final initial = previewStart ?? DateTime.now();
      final now = DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: toLocalDateOnly(initial),
        firstDate: DateTime(now.year - 1),
        lastDate: DateTime(now.year + 2, 12, 31),
      );
      if (picked == null) return;
      startDateManuallySet.value = true;
      customStartDate.value = toLocalDateOnly(picked);
    }

    void resetStartDateToDefault() {
      startDateManuallySet.value = false;
      customStartDate.value = defaultStart;
    }

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

      final resolvedName = guestMode
          ? guestNameController.text.trim()
          : memberName.trim();
      if (guestMode && resolvedName.isEmpty) {
        showErrorSnackBar(
          context,
          message: 'Enter the customer name',
          useRootMessenger: false,
        );
        return;
      }

      final skipSale = !guestMode && isRenewal && excludeFromSales.value;

      // Prevent silent redo when an unpaid sale already exists.
      if (!skipSale) {
        final canCreate = await resolveOpenUnpaidBeforeCreate(
          context,
          ref,
          memberId: guestMode ? null : memberId,
          customerName: resolvedName,
        );
        if (!canCreate || !context.mounted) return;
      }

      isPurchasing.value = true;

      final branchId = ref.read(effectiveBranchIdForWriteProvider) ?? '';
      final auth = ref.read(currentAuthProvider);
      final orchestrator = ref.read(membershipPurchaseOrchestratorProvider);

      if (orchestrator.shouldQueueOffline) {
        final result = await orchestrator.purchase(
          memberId: guestMode ? null : memberId,
          memberName: resolvedName,
          plan: plan,
          addOns: addOnsState.value,
          branchId: branchId,
          soldBy: auth?.user.id,
          excludeFromSales: skipSale,
          latestActiveEndDate: guestMode ? null : latestActiveEndDate.value,
          customStartDate: guestMode
              ? null
              : (customStartDate.value ??
                    computeMembershipStartDate(
                      latestActiveEndDate: latestActiveEndDate.value,
                    )),
          guestMode: guestMode,
        );

        isPurchasing.value = false;

        result.fold(
          (failure) {
            if (context.mounted) {
              showErrorSnackBar(
                context,
                message: guestMode
                    ? 'Failed to queue sale: ${failure.messageString}'
                    : 'Failed to queue membership: ${failure.messageString}',
                useRootMessenger: false,
              );
            }
          },
          (purchaseResult) {
            if (context.mounted) {
              final message = guestMode
                  ? 'Sale queued — will sync when online'
                  : skipSale
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

      Sale? createdSale;

      if (!skipSale) {
        final saleResult = await createMembershipSale(
          ref: ref,
          memberId: guestMode ? null : memberId,
          customerName: resolvedName,
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
              message: guestMode
                  ? 'Failed to create sale'
                  : 'Failed to create sale for membership',
              useRootMessenger: false,
            );
          }
          return;
        }
      }

      if (guestMode) {
        isPurchasing.value = false;
        if (context.mounted) {
          showSuccessSnackBar(
            context,
            message: 'Sale created for $resolvedName',
            useRootMessenger: false,
          );
          onPurchased?.call(createdSale, totalPrice);
        }
        return;
      }

      final startDate = toLocalDateOnly(
        customStartDate.value ??
            computeMembershipStartDate(
              latestActiveEndDate: latestActiveEndDate.value,
            ),
      );
      final endDate = computeMembershipEndDate(
        startDate: startDate,
        durationValue: plan.durationValue,
        durationUnit: plan.durationUnit,
        bonusDays: MembershipAddOn.totalBonusDays(addOnsState.value),
      );

      // Create MemberMembership record (optionally linked to the sale).
      // Linked unpaid sales start as pending until payment completes.
      final repo = ref.read(memberMembershipRepositoryProvider);
      final result = await repo.create(
        memberId: memberId,
        membershipId: plan.id,
        startDate: startDate,
        endDate: endDate,
        branchId: branchId,
        saleId: createdSale?.id,
        soldBy: auth?.user.id,
        status: createdSale != null
            ? MemberMembershipStatus.pending
            : MemberMembershipStatus.active,
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

      // Create add-on records for each selected add-on
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
        if (guestMode)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: guestNameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Customer name *',
                hintText: 'Name for this day pass / walk-in',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
        // Plan list and add-ons
        Expanded(
          child: membershipsAsync.when(
            data: (memberships) {
              void sortPlans(List<Membership> plans) {
                plans.sort(Membership.compareForList);
              }

              final catalogPlans = memberships
                  .where(
                    (m) =>
                        guestMode ? m.memberNotRequired : !m.memberNotRequired,
                  )
                  .toList();

              final activePlans = catalogPlans
                  .where((m) => m.isActive)
                  .toList();
              sortPlans(activePlans);

              final inactivePlans = catalogPlans
                  .where((m) => !m.isActive)
                  .toList();
              sortPlans(inactivePlans);

              final visiblePlans = showInactive.value
                  ? [...activePlans, ...inactivePlans]
                  : activePlans;

              if (visiblePlans.isEmpty && !skipPlanSelection) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      guestMode
                          ? 'No walk-in / day pass plans yet.\n'
                                'Create a membership plan and enable '
                                '"Walk-in / day pass".'
                          : 'No membership plans available.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

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
            error: (error, _) => ErrorState.fromError(
              error,
              compact: true,
              onRetry: () => ref.invalidate(membershipsControllerProvider),
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
                if (!guestMode &&
                    previewStart != null &&
                    previewEnd != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isUsingStackedDefault
                              ? 'Starts after current membership'
                              : 'Membership period',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: isPurchasing.value ? null : pickStartDate,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.event,
                                  size: 20,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Start date',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                      Text(
                                        dateFormat.format(previewStart),
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'Change',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ends ${dateFormat.format(previewEnd)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (bonusDays > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Includes ${bonusDays == 1 ? '1 extra day' : '$bonusDays extra days'} from add-ons',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                        if (isStacking &&
                            latestActiveEndDate.value != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Current ends ${dateFormat.format(latestActiveEndDate.value!)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        if (startDateManuallySet.value && isStacking) ...[
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: isPurchasing.value
                                  ? null
                                  : resetStartDateToDefault,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Use day after current membership',
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (!guestMode && isRenewal)
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
                if (!guestMode && isRenewal) const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed:
                        membershipState.value != null &&
                            !isPurchasing.value &&
                            (!guestMode || guestName.value.trim().isNotEmpty)
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
                            guestMode
                                ? Icons.directions_walk
                                : isRenewal
                                ? Icons.autorenew
                                : Icons.shopping_cart,
                          ),
                    label: Text(
                      membershipState.value != null
                          ? guestMode
                                ? 'Sell ${membershipState.value!.name} - ${totalPrice.toCurrency()}'
                                : excludeFromSales.value && isRenewal
                                ? 'Renew ${membershipState.value!.name} (no sale)'
                                : '${isRenewal ? 'Renew' : 'Purchase'} ${membershipState.value!.name} - ${totalPrice.toCurrency()}'
                          : guestMode
                          ? 'Select a walk-in plan'
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
              final subtitle = addOn.extendsDuration
                  ? '${addOn.durationDisplay} · ${addOn.price.toCurrency()}'
                  : addOn.price.toCurrency();

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
                subtitle: Text(subtitle),
                secondary: Icon(
                  addOn.extendsDuration
                      ? Icons.event_available
                      : Icons.extension,
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
