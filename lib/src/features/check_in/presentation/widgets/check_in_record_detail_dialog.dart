import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/permissions/current_user_permissions.dart';
import '../../../../core/routing/routes/members.routes.dart';
import '../../../../core/widgets/cached_avatar.dart';
import '../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../../core/widgets/dialog_close_handler.dart';
import '../../../members/presentation/controllers/member_provider.dart';
import '../../domain/check_in.dart';
import 'last_check_in_panel.dart';
import 'void_check_in_dialog.dart';

/// Shows a dialog with check-in details and a link to the member profile.
Future<void> showCheckInRecordDetailDialog(
  BuildContext context, {
  required CheckIn checkIn,
}) {
  return showConstrainedDialog<void>(
    context: context,
    maxWidth: DialogConstraints.compactMaxWidth,
    barrierDismissible: true,
    builder: (context) => CheckInRecordDetailDialog(checkIn: checkIn),
  );
}

/// Compact check-in details with navigation to the member profile.
class CheckInRecordDetailDialog extends ConsumerWidget {
  const CheckInRecordDetailDialog({super.key, required this.checkIn});

  final CheckIn checkIn;

  static final _dateFormat = DateFormat('EEE, MMM d, yyyy');
  static final _timeFormat = DateFormat('hh:mm a');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final memberAsync = ref.watch(memberProvider(checkIn.memberId));
    final membershipAsync = ref.watch(
      memberActiveMembershipProvider(checkIn.memberId),
    );

    return DialogCloseHandler(
      child: ConstrainedDialogContent(
        maxWidth: DialogConstraints.compactMaxWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(
                      'Check-In Details',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: memberAsync.when(
                        loading: () => const CachedAvatar(radius: 36),
                        error: (_, __) => const CachedAvatar(radius: 36),
                        data: (member) =>
                            CachedAvatar(imageUrl: member?.photo, radius: 36),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      checkIn.memberName ??
                          memberAsync.value?.name ??
                          'Unknown Member',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (memberAsync.value?.mobileNumber != null &&
                        memberAsync.value!.mobileNumber!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        memberAsync.value!.mobileNumber!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 20),
                    _DetailRow(
                      icon: Icons.schedule,
                      label: 'Date',
                      value: _dateFormat.format(checkIn.checkInTime),
                    ),
                    _DetailRow(
                      icon: Icons.access_time,
                      label: 'Time',
                      value: _timeFormat.format(checkIn.checkInTime),
                    ),
                    _DetailRow(
                      icon: checkIn.method == CheckInMethod.rfid
                          ? Icons.contactless
                          : Icons.touch_app,
                      label: 'Method',
                      value: checkIn.method.displayName,
                    ),
                    membershipAsync.when(
                      loading: () => const _DetailRow(
                        icon: Icons.card_membership,
                        label: 'Membership',
                        value: 'Loading...',
                      ),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (membership) => _DetailRow(
                        icon: Icons.card_membership,
                        label: 'Membership',
                        value: membership != null
                            ? (membership.membershipName ?? 'Active')
                            : 'No active membership',
                        valueColor: membership == null ? Colors.red : null,
                      ),
                    ),
                    if (checkIn.isVoided) ...[
                      _DetailRow(
                        icon: Icons.block,
                        label: 'Status',
                        value: 'Voided',
                        valueColor: theme.colorScheme.error,
                      ),
                      if (checkIn.voidReason != null &&
                          checkIn.voidReason!.isNotEmpty)
                        _DetailRow(
                          icon: Icons.notes,
                          label: 'Void reason',
                          value: checkIn.voidReason!,
                        ),
                    ],
                    if (checkIn.notes != null && checkIn.notes!.isNotEmpty)
                      _DetailRow(
                        icon: Icons.notes,
                        label: 'Notes',
                        value: checkIn.notes!,
                      ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        MemberDetailRoute(id: checkIn.memberId).go(context);
                      },
                      icon: const Icon(Icons.person_outline),
                      label: const Text('View Member Details'),
                    ),
                    if (!checkIn.isVoided &&
                        (ref
                                .watch(currentUserPermissionsProvider)
                                .value
                                ?.canVoidCheckIns ??
                            false)) ...[
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final ok = await showVoidCheckInDialog(
                            context,
                            ref,
                            checkIn: checkIn,
                          );
                          if (ok && context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        icon: const Icon(Icons.undo),
                        label: const Text('Void Check-In'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
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
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
