import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../domain/organization.dart';
import '../../domain/organization_dns_status.dart';
import '../controllers/organizations_controller.dart';

/// Retries Porkbun DNS provisioning for an organization.
class OrganizationDnsRetryButton extends HookConsumerWidget {
  const OrganizationDnsRetryButton({super.key, required this.organization});

  final Organization organization;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final isRetrying = useState(false);

    if (organization.dnsStatus == OrganizationDnsStatus.created) {
      return const SizedBox.shrink();
    }

    Future<void> handleRetry() async {
      isRetrying.value = true;
      final success = await ref
          .read(organizationsControllerProvider.notifier)
          .retryDnsProvisioning(organization.id);
      isRetrying.value = false;

      if (!context.mounted) return;

      if (success) {
        showSuccessSnackBar(context, message: t.organizations.retryDnsSuccess);
      } else {
        showErrorSnackBar(context, message: t.organizations.retryDnsFailed);
      }
    }

    return TextButton.icon(
      onPressed: isRetrying.value ? null : handleRetry,
      icon: isRetrying.value
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.refresh, size: 18),
      label: Text(t.organizations.retryDns),
    );
  }
}
