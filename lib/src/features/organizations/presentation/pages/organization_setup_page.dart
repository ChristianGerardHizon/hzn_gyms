import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/routing/routes/platform.routes.dart';
import '../../domain/organization.dart';
import '../controllers/organization_setup_controller.dart';
import '../widgets/organization_dns_retry_button.dart';
import '../widgets/organization_form_dialog.dart';
import '../widgets/organization_setup_admin_user_form.dart';
import '../widgets/organization_setup_branch_form.dart';
import '../widgets/organization_setup_optional_product_step.dart';
import '../widgets/organization_setup_optional_membership_step.dart';

/// Multi-step onboarding wizard for a new tenant organization.
class OrganizationSetupPage extends HookConsumerWidget {
  const OrganizationSetupPage({super.key, required this.organizationId});

  final String organizationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final setupAsync =
        ref.watch(organizationSetupControllerProvider(organizationId));
    final currentStep = useState(0);

    return setupAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: Text(t.organizations.setupTitle)),
        body: Center(child: Text(error.toString())),
      ),
      data: (setupState) {
        final steps = [
          t.organizations.setupStepBranding,
          t.organizations.setupStepDns,
          t.organizations.setupStepBranch,
          t.organizations.setupStepAdminUser,
          t.organizations.setupStepMembership,
          t.organizations.setupStepProduct,
          t.organizations.setupStepReview,
        ];

        return Scaffold(
          appBar: AppBar(
            title: Text(
              '${t.organizations.setupTitle}: ${setupState.organization.effectiveDisplayName}',
            ),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => const PlatformOrganizationsRoute().go(context),
            ),
          ),
          body: Stepper(
            currentStep: currentStep.value,
            onStepContinue: currentStep.value < steps.length - 1
                ? () => currentStep.value++
                : null,
            onStepCancel: currentStep.value > 0
                ? () => currentStep.value--
                : null,
            controlsBuilder: (context, details) {
              return const SizedBox.shrink();
            },
            steps: [
              Step(
                title: Text(steps[0]),
                isActive: currentStep.value >= 0,
                state: currentStep.value > 0
                    ? StepState.complete
                    : StepState.editing,
                content: _BrandingStep(
                  organization: setupState.organization,
                  onSaved: () async {
                    await ref
                        .read(
                          organizationSetupControllerProvider(organizationId)
                              .notifier,
                        )
                        .refreshOrganization();
                    currentStep.value = 1;
                  },
                ),
              ),
              Step(
                title: Text(steps[1]),
                isActive: currentStep.value >= 1,
                state: currentStep.value > 1
                    ? StepState.complete
                    : StepState.editing,
                content: _DnsStep(
                  organization: setupState.organization,
                  onContinue: () => currentStep.value = 2,
                ),
              ),
              Step(
                title: Text(steps[2]),
                isActive: currentStep.value >= 2,
                state: setupState.hasBranch || currentStep.value > 2
                    ? StepState.complete
                    : StepState.editing,
                content: OrganizationSetupBranchForm(
                  organizationId: organizationId,
                  onCreated: (branchId) async {
                    await ref
                        .read(
                          organizationSetupControllerProvider(organizationId)
                              .notifier,
                        )
                        .refreshProgress();
                    currentStep.value = 3;
                  },
                ),
              ),
              Step(
                title: Text(steps[3]),
                isActive: currentStep.value >= 3,
                state: setupState.hasAdminUser || currentStep.value > 3
                    ? StepState.complete
                    : StepState.editing,
                content: OrganizationSetupAdminUserForm(
                  organizationId: organizationId,
                  defaultBranchId: setupState.createdBranchId,
                  onCreated: () async {
                    await ref
                        .read(
                          organizationSetupControllerProvider(organizationId)
                              .notifier,
                        )
                        .refreshProgress();
                    currentStep.value = 4;
                  },
                ),
              ),
              Step(
                title: Text(steps[4]),
                isActive: currentStep.value >= 4,
                state:
                    setupState.membershipCreated ||
                        setupState.skippedMembership ||
                        currentStep.value > 4
                    ? StepState.complete
                    : StepState.editing,
                content: OrganizationSetupOptionalMembershipStep(
                  onCreated: () {
                    ref
                        .read(
                          organizationSetupControllerProvider(organizationId)
                              .notifier,
                        )
                        .markMembershipCreated();
                    currentStep.value = 5;
                  },
                  onSkip: () {
                    ref
                        .read(
                          organizationSetupControllerProvider(organizationId)
                              .notifier,
                        )
                        .markMembershipSkipped();
                    currentStep.value = 5;
                  },
                ),
              ),
              Step(
                title: Text(steps[5]),
                isActive: currentStep.value >= 5,
                state:
                    setupState.productCreated ||
                        setupState.skippedProduct ||
                        currentStep.value > 5
                    ? StepState.complete
                    : StepState.editing,
                content: OrganizationSetupOptionalProductStep(
                  onCreated: () {
                    ref
                        .read(
                          organizationSetupControllerProvider(organizationId)
                              .notifier,
                        )
                        .markProductCreated();
                    currentStep.value = 6;
                  },
                  onSkip: () {
                    ref
                        .read(
                          organizationSetupControllerProvider(organizationId)
                              .notifier,
                        )
                        .markProductSkipped();
                    currentStep.value = 6;
                  },
                ),
              ),
              Step(
                title: Text(steps[6]),
                isActive: currentStep.value >= 6,
                state: setupState.organization.setupStatus.isReady
                    ? StepState.complete
                    : StepState.editing,
                content: _ReviewStep(
                  setupState: setupState,
                  organizationId: organizationId,
                  onComplete: () {
                    const PlatformOrganizationsRoute().go(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BrandingStep extends ConsumerWidget {
  const _BrandingStep({
    required this.organization,
    required this.onSaved,
  });

  final Organization organization;
  final VoidCallback onSaved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.organizations.setupBrandingHint),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            showOrganizationFormDialog(
              context,
              organization: organization,
            ).then((saved) {
              if (saved == true) onSaved();
            });
          },
          icon: const Icon(Icons.edit),
          label: Text(t.organizations.edit),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: onSaved,
          child: Text(t.organizations.setupContinue),
        ),
      ],
    );
  }
}

class _DnsStep extends ConsumerWidget {
  const _DnsStep({
    required this.organization,
    required this.onContinue,
  });

  final Organization organization;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final dnsStatus = organization.dnsStatus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (organization.subdomain != null)
          SelectableText(organization.subdomain!),
        const SizedBox(height: 8),
        Text('${t.organizations.dnsStatus}: ${dnsStatus.label}'),
        if (organization.dnsError != null && organization.dnsError!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              organization.dnsError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        const SizedBox(height: 12),
        OrganizationDnsRetryButton(organization: organization),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: onContinue,
          child: Text(t.organizations.setupContinue),
        ),
      ],
    );
  }
}

class _ReviewStep extends ConsumerStatefulWidget {
  const _ReviewStep({
    required this.setupState,
    required this.organizationId,
    required this.onComplete,
  });

  final OrganizationSetupState setupState;
  final String organizationId;
  final VoidCallback onComplete;

  @override
  ConsumerState<_ReviewStep> createState() => _ReviewStepState();
}

class _ReviewStepState extends ConsumerState<_ReviewStep> {
  var _isCompleting = false;

  Future<void> _complete() async {
    setState(() => _isCompleting = true);
    final success = await ref
        .read(organizationSetupControllerProvider(widget.organizationId).notifier)
        .completeSetup();
    if (!mounted) return;
    setState(() => _isCompleting = false);
    if (success) {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final checks = widget.setupState.checks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.setupState.organization.subdomain != null)
          Text(
            t.organizations.setupLoginUrl(
              url: 'https://${widget.setupState.organization.subdomain}',
            ),
          ),
        const SizedBox(height: 16),
        for (final check in checks)
          ListTile(
            leading: Icon(
              check.passed ? Icons.check_circle : Icons.cancel,
              color: check.passed ? Colors.green : Colors.red,
            ),
            title: Text(check.label),
            subtitle: check.detail != null ? Text(check.detail!) : null,
          ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed:
              widget.setupState.canComplete && !_isCompleting ? _complete : null,
          child: _isCompleting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(t.organizations.setupMarkComplete),
        ),
      ],
    );
  }
}
