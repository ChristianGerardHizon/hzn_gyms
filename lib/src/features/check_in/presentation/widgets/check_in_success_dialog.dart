import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Shows a success dialog after a check-in that auto-closes after 3 seconds.
Future<void> showCheckInSuccessDialog(
  BuildContext context, {
  required String memberName,
  required bool hasActiveMembership,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => _CheckInSuccessDialog(
      memberName: memberName,
      hasActiveMembership: hasActiveMembership,
    ),
  );
}

class _CheckInSuccessDialog extends HookWidget {
  const _CheckInSuccessDialog({
    required this.memberName,
    required this.hasActiveMembership,
  });

  final String memberName;
  final bool hasActiveMembership;

  static const _autoCloseDuration = 3;

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

    return AlertDialog(
      icon: const Icon(
        Icons.check_circle,
        color: Colors.green,
        size: 48,
      ),
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
          const SizedBox(height: 8),
          if (!hasActiveMembership)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
