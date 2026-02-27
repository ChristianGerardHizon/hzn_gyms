import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/routes/sales_history.routes.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../core/utils/currency_format.dart';
import '../../../../core/widgets/cached_avatar.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../data/repositories/member_repository.dart';
import '../../../memberships/domain/member_membership.dart';
import '../../../memberships/presentation/controllers/member_memberships_controller.dart';
import '../../../memberships/presentation/widgets/purchase_membership_dialog.dart';
import '../../../check_in/presentation/controllers/member_check_ins_controller.dart';
import '../../../pos/data/repositories/sales_repository.dart';
import '../../../pos/domain/sale.dart';
import '../../../sales/presentation/widgets/record_payment_sheet.dart';
import '../controllers/member_provider.dart';
import '../controllers/members_controller.dart';
import '../controllers/paginated_members_controller.dart';
import '../../../member_cards/domain/member_card.dart';
import '../../../member_cards/presentation/controllers/member_cards_controller.dart';
import '../../../member_cards/presentation/widgets/add_card_sheet.dart';
import '../widgets/member_form_dialog.dart';

/// Member detail page showing member information and sales history.
class MemberDetailPage extends HookConsumerWidget {
  const MemberDetailPage({
    super.key,
    required this.memberId,
  });

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberAsync = ref.watch(memberProvider(memberId));
    final isTablet = Breakpoints.isTabletOrLarger(context);
    final isUploading = useState(false);

    return memberAsync.when(
      data: (member) {
        if (member == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Member Not Found'),
              automaticallyImplyLeading: !isTablet,
            ),
            body: const Center(
              child: Text('The requested member could not be found.'),
            ),
          );
        }

        final theme = Theme.of(context);
        final dateFormat = DateFormat('MMM dd, yyyy');

        return Scaffold(
          appBar: AppBar(
            title: Text(member.name),
            automaticallyImplyLeading: !isTablet,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  ref.invalidate(memberProvider(memberId));
                  showInfoSnackBar(
                    context,
                    message: 'Refreshing...',
                    duration: const Duration(seconds: 1),
                  );
                },
                tooltip: 'Refresh',
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditSheet(context, ref),
              ),
              PopupMenuButton<String>(
                onSelected: (value) =>
                    _handleMenuAction(context, ref, value, member.id),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Delete'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Member info card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildAvatar(
                            context,
                            theme,
                            ref,
                            isUploading,
                            photoUrl: member.photo,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  member.name,
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (member.mobileNumber != null &&
                                    member.mobileNumber!.isNotEmpty)
                                  Text(
                                    member.mobileNumber!,
                                    style:
                                        theme.textTheme.bodyMedium?.copyWith(
                                      color:
                                          theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 16),
                      Text(
                        'Member Information',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(label: 'Name', value: member.name),
                      if (member.mobileNumber != null &&
                          member.mobileNumber!.isNotEmpty)
                        _InfoRow(
                            label: 'Mobile', value: member.mobileNumber!),
                      if (member.email != null && member.email!.isNotEmpty)
                        _InfoRow(label: 'Email', value: member.email!),
                      if (member.dateOfBirth != null)
                        _InfoRow(
                          label: 'Date of Birth',
                          value: dateFormat.format(member.dateOfBirth!),
                        ),
                      if (member.sex != null)
                        _InfoRow(label: 'Sex', value: member.sex!.displayName),
                      if (member.address != null &&
                          member.address!.isNotEmpty)
                        _InfoRow(label: 'Address', value: member.address!),
                      if (member.emergencyContact != null &&
                          member.emergencyContact!.isNotEmpty)
                        _InfoRow(
                          label: 'Emergency Contact',
                          value: member.emergencyContact!,
                        ),
                      if (member.rfidCardId != null &&
                          member.rfidCardId!.isNotEmpty)
                        _InfoRow(
                            label: 'RFID Card', value: member.rfidCardId!),
                      if (member.remarks != null &&
                          member.remarks!.isNotEmpty)
                        _InfoRow(label: 'Remarks', value: member.remarks!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ID Cards section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ID Cards',
                            style: theme.textTheme.titleMedium,
                          ),
                          FilledButton.tonalIcon(
                            onPressed: () async {
                              final result = await showAddCardSheet(
                                context,
                                memberId: memberId,
                              );
                              if (result == true) {
                                ref.invalidate(
                                  memberCardsControllerProvider(memberId),
                                );
                              }
                            },
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add Card'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _MemberCardsSection(memberId: memberId),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Memberships section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Memberships',
                            style: theme.textTheme.titleMedium,
                          ),
                          FilledButton.tonalIcon(
                            onPressed: () async {
                              final result =
                                  await showPurchaseMembershipDialog(
                                context,
                                memberId: memberId,
                                memberName: member.name,
                              );
                              if (result != null) {
                                ref.invalidate(
                                  memberMembershipsControllerProvider(
                                      memberId),
                                );
                                if (context.mounted) {
                                  await showRecordPaymentSheet(
                                    context,
                                    sale: result.sale,
                                    balanceDue: result.totalPrice,
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Purchase'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _MemberMembershipsSection(memberId: memberId),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Check-in history section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Check-In History',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      _MemberCheckInsSection(memberId: memberId),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Sales history section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sales History',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      _MemberSalesHistory(memberId: memberId),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(automaticallyImplyLeading: !isTablet),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(automaticallyImplyLeading: !isTablet),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildAvatar(
    BuildContext context,
    ThemeData theme,
    WidgetRef ref,
    ValueNotifier<bool> isUploading, {
    String? photoUrl,
    double radius = 40,
  }) {
    return Stack(
      children: [
        CachedAvatar(
          imageUrl: photoUrl,
          radius: radius,
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: isUploading.value
                ? null
                : () => _pickAndUploadImage(context, ref, isUploading),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.surface,
                  width: 2,
                ),
              ),
              child: isUploading.value
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: theme.colorScheme.onPrimary,
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickAndUploadImage(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<bool> isUploading,
  ) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (image == null) return;

    isUploading.value = true;

    try {
      final bytes = await image.readAsBytes();
      final file = http.MultipartFile.fromBytes(
        'photo',
        bytes,
        filename: image.name,
      );

      final repository = ref.read(memberRepositoryProvider);
      final result = await repository.updatePhoto(memberId, file);

      result.fold(
        (failure) {
          if (context.mounted) {
            showErrorSnackBar(context, message: failure.message);
          }
        },
        (updatedMember) {
          ref.invalidate(memberProvider(memberId));
          ref.read(membersControllerProvider.notifier).refresh();
          ref.read(paginatedMembersControllerProvider.notifier).refresh();
          if (context.mounted) {
            showSuccessSnackBar(context, message: 'Photo updated successfully');
          }
        },
      );
    } catch (e) {
      if (context.mounted) {
        showErrorSnackBar(context, message: 'Failed to upload photo');
      }
    } finally {
      isUploading.value = false;
    }
  }

  void _showEditSheet(BuildContext context, WidgetRef ref) async {
    final member = ref.read(memberProvider(memberId)).value;
    if (member == null) return;

    final result = await showMemberFormDialog(
      context,
      member: member,
    );

    if (result != null) {
      ref.invalidate(memberProvider(memberId));
      ref.read(membersControllerProvider.notifier).refresh();
      ref.read(paginatedMembersControllerProvider.notifier).refresh();
    }
  }

  void _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    String action,
    String id,
  ) async {
    if (action == 'delete') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Member'),
          content:
              const Text('Are you sure you want to delete this member?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed == true && context.mounted) {
        final success = await ref
            .read(paginatedMembersControllerProvider.notifier)
            .deleteMember(id);
        ref.read(membersControllerProvider.notifier).refresh();
        if (success && context.mounted) {
          showSuccessSnackBar(context, message: 'Member deleted');
          context.pop();
        } else if (context.mounted) {
          showErrorSnackBar(context, message: 'Failed to delete member');
        }
      }
    }
  }
}

/// Widget that displays a member's memberships.
class _MemberMembershipsSection extends ConsumerWidget {
  const _MemberMembershipsSection({required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membershipsAsync =
        ref.watch(memberMembershipsControllerProvider(memberId));
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return membershipsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => Center(
        child: Text('Error loading memberships: $error'),
      ),
      data: (memberships) {
        if (memberships.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.card_membership_outlined,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No memberships yet',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: memberships.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final mm = memberships[index];
            final effectiveExpired = mm.isExpired &&
                mm.status == MemberMembershipStatus.active;
            final statusColor = effectiveExpired
                ? Colors.orange
                : _statusColor(mm.status);

            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: statusColor.withValues(alpha: 0.15),
                child: Icon(
                  Icons.card_membership,
                  color: statusColor,
                  size: 20,
                ),
              ),
              title: Text(mm.membershipName ?? 'Membership'),
              subtitle: Text(
                '${dateFormat.format(mm.startDate)} - ${dateFormat.format(mm.endDate)}',
                style: theme.textTheme.bodySmall,
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      effectiveExpired
                          ? 'Expired'
                          : mm.status.displayName,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (mm.isCurrentlyActive) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${mm.daysRemaining} days left',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _statusColor(MemberMembershipStatus status) {
    switch (status) {
      case MemberMembershipStatus.active:
        return Colors.green;
      case MemberMembershipStatus.expired:
        return Colors.orange;
      case MemberMembershipStatus.cancelled:
        return Colors.red;
      case MemberMembershipStatus.voided:
        return Colors.grey;
    }
  }
}

/// Widget that displays a member's check-in history.
class _MemberCheckInsSection extends ConsumerWidget {
  const _MemberCheckInsSection({required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkInsAsync = ref.watch(memberCheckInsProvider(memberId));
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy hh:mm a');

    return checkInsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => Center(
        child: Text('Error loading check-ins: $error'),
      ),
      data: (checkIns) {
        if (checkIns.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.how_to_reg_outlined,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No check-ins yet',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Show last 10 check-ins
        final displayCheckIns = checkIns.take(10).toList();

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayCheckIns.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final ci = displayCheckIns[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Colors.green.withValues(alpha: 0.15),
                child: const Icon(
                  Icons.how_to_reg,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              title: Text(dateFormat.format(ci.checkInTime)),
              subtitle: Text(
                ci.method.displayName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Widget that fetches and displays sales history for a member.
class _MemberSalesHistory extends ConsumerWidget {
  const _MemberSalesHistory({required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesRepo = ref.watch(salesRepositoryProvider);
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy hh:mm a');

    return FutureBuilder<List<Sale>>(
      future: _fetchMemberSales(salesRepo),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final sales = snapshot.data ?? [];

        if (sales.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 48,
                    color:
                        theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No sales yet',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sales.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final sale = sales[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.receipt,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
              title: Text('#${sale.receiptNumber}'),
              subtitle: Text(
                sale.created != null
                    ? dateFormat.format(sale.created!)
                    : 'Unknown date',
                style: theme.textTheme.bodySmall,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        sale.totalAmount.toCurrency(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            sale.isPaid ? Icons.check_circle : Icons.pending,
                            size: 12,
                            color: sale.isPaid ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            sale.isPaid ? 'Paid' : 'Unpaid',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: sale.isPaid ? Colors.green : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              onTap: () => SaleDetailRoute(id: sale.id).go(context),
            );
          },
        );
      },
    );
  }

  Future<List<Sale>> _fetchMemberSales(SalesRepository salesRepo) async {
    final result = await salesRepo.getSalesByCustomer(memberId);
    return result.fold(
      (failure) => [],
      (sales) => sales,
    );
  }
}

/// Widget that displays a member's ID cards.
class _MemberCardsSection extends ConsumerWidget {
  const _MemberCardsSection({required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(memberCardsControllerProvider(memberId));
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return cardsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => Center(
        child: Text('Error loading cards: $error'),
      ),
      data: (cards) {
        if (cards.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.credit_card_outlined,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No cards assigned',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final card = cards[index];
            final statusColor = _cardStatusColor(card.status);

            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: statusColor.withValues(alpha: 0.15),
                child: Icon(
                  Icons.credit_card,
                  color: statusColor,
                  size: 20,
                ),
              ),
              title: Text(card.label ?? card.cardValue),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (card.label != null)
                    Text(
                      card.cardValue,
                      style: theme.textTheme.bodySmall,
                    ),
                  if (card.created != null)
                    Text(
                      'Issued ${dateFormat.format(card.created!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      card.status.displayName,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (card.isActive)
                    PopupMenuButton<String>(
                      onSelected: (value) =>
                          _handleCardAction(context, ref, value, card),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'deactivate',
                          child: ListTile(
                            leading: Icon(Icons.block),
                            title: Text('Deactivate'),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'lost',
                          child: ListTile(
                            leading:
                                Icon(Icons.report_problem, color: Colors.orange),
                            title: Text('Report Lost'),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title: Text('Delete'),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _cardStatusColor(MemberCardStatus status) {
    switch (status) {
      case MemberCardStatus.active:
        return Colors.green;
      case MemberCardStatus.lost:
        return Colors.orange;
      case MemberCardStatus.deactivated:
        return Colors.grey;
    }
  }

  void _handleCardAction(
    BuildContext context,
    WidgetRef ref,
    String action,
    MemberCard card,
  ) async {
    final controller =
        ref.read(memberCardsControllerProvider(memberId).notifier);

    switch (action) {
      case 'deactivate':
        final success = await controller.deactivateCard(card.id);
        if (context.mounted) {
          if (success) {
            showSuccessSnackBar(context, message: 'Card deactivated');
          } else {
            showErrorSnackBar(context, message: 'Failed to deactivate card');
          }
        }
      case 'lost':
        final success = await controller.reportLost(card.id);
        if (context.mounted) {
          if (success) {
            showSuccessSnackBar(context, message: 'Card reported as lost');
          } else {
            showErrorSnackBar(context, message: 'Failed to report card as lost');
          }
        }
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Card'),
            content: const Text(
                'Are you sure you want to delete this card? This cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          final success = await controller.deleteCard(card.id);
          if (context.mounted) {
            if (success) {
              showSuccessSnackBar(context, message: 'Card deleted');
            } else {
              showErrorSnackBar(context, message: 'Failed to delete card');
            }
          }
        }
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
