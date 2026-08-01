import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../domain/check_in_chime.dart';
import '../../domain/membership_expiry_label.dart';
import '../utils/check_in_sound_player.dart';

/// Shows a success dialog after a check-in that auto-closes after a few seconds.
Future<void> showCheckInSuccessDialog(
  BuildContext context, {
  required String memberName,
  required bool hasActiveMembership,
  String? membershipName,
  DateTime? membershipEndDate,
  int? membershipDaysRemaining,
}) {
  CheckInSoundPlayer.play(
    hasActiveMembership
        ? resolveCheckInSuccessChime(membershipDaysRemaining)
        : CheckInChime.failure,
  );
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => _CheckInSuccessDialog(
      memberName: memberName,
      hasActiveMembership: hasActiveMembership,
      membershipName: membershipName,
      membershipEndDate: membershipEndDate,
      membershipDaysRemaining: membershipDaysRemaining,
    ),
  );
}

class _CheckInSuccessDialog extends HookWidget {
  const _CheckInSuccessDialog({
    required this.memberName,
    required this.hasActiveMembership,
    this.membershipName,
    this.membershipEndDate,
    this.membershipDaysRemaining,
  });

  final String memberName;
  final bool hasActiveMembership;
  final String? membershipName;
  final DateTime? membershipEndDate;
  final int? membershipDaysRemaining;

  static const _autoCloseDuration = 4;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondsRemaining = useState(_autoCloseDuration);

    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 1), (_) {
        secondsRemaining.value--;
        if (secondsRemaining.value <= 0) {
          Navigator.of(context).pop();
        }
      });
      return timer.cancel;
    }, []);

    final planLabel = membershipName?.trim().isNotEmpty == true
        ? membershipName!.trim()
        : 'Active membership';

    final expiryLabel = membershipEndDate == null
        ? null
        : formatMembershipExpiryLabel(
            endDate: membershipEndDate!,
            daysRemaining: membershipDaysRemaining,
          );

    return AlertDialog(
      icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
      title: const Text('Check-In Successful'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            memberName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (hasActiveMembership && membershipEndDate != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.verified, color: Colors.green, size: 18),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          planLabel,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  if (expiryLabel != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      expiryLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ] else if (!hasActiveMembership) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'No active membership',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'Closing in ${secondsRemaining.value}s...',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('OK (${secondsRemaining.value})'),
        ),
      ],
    );
  }
}
