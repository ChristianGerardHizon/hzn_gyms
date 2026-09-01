import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/hooks/use_form_dirty_guard.dart';
import '../../../../core/permissions/current_user_permissions.dart';
import '../../../../core/utils/photo_capture_support.dart';
import '../../../../core/utils/currency_format.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/idempotency.dart';
import '../../../../core/utils/search_tokens.dart';
import '../../../../core/widgets/cached_avatar.dart';
import '../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../../core/widgets/dialog_close_handler.dart';
import '../../../../core/widgets/form/form_dialog_scaffold.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../../core/widgets/member_photo_capture_panel.dart';
import '../../../../core/widgets/step_indicator.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../dashboard/presentation/controllers/dashboard_refresh.dart';
import '../../../memberships/data/membership_sale_helper.dart';
import '../../../memberships/data/repositories/member_membership_add_on_repository.dart';
import '../../../memberships/data/repositories/member_membership_repository.dart';
import '../../../pos/domain/sale.dart';
import '../../../memberships/domain/membership.dart';
import '../../../memberships/domain/membership_add_on.dart';
import '../../../member_cards/presentation/controllers/member_cards_controller.dart';
import '../../../member_cards/presentation/widgets/member_card_entry_form.dart';
import '../../../memberships/presentation/widgets/membership_purchase_content.dart';
import '../../../memberships/presentation/widgets/purchase_membership_dialog.dart';
import '../../../sales/presentation/widgets/record_payment_dialog.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../data/local/member_local_data_source.dart';
import '../../data/repositories/member_repository.dart';
import '../../domain/member.dart';
import '../../domain/member_duplicate_match.dart';
import '../controllers/members_controller.dart';
import '../controllers/member_provider.dart';
import '../controllers/paginated_members_controller.dart';

/// Result from the member form dialog.
class MemberFormResult {
  const MemberFormResult({
    this.sale,
    this.totalPrice,
    this.renewExistingMember,
  });

  /// The sale created during membership purchase (null if no membership
  /// or sales were excluded).
  final Sale? sale;

  /// Total price of the membership + add-ons.
  final num? totalPrice;

  /// When set, the create wizard selected an existing member match and should
  /// continue into renew for that member (form was pre-filled from them).
  final Member? renewExistingMember;
}

/// Whether the new-member wizard should create a sale for the selected plan.
///
/// Default is to create a sale (and open record payment). Checking
/// "Exclude from sales" skips the sale while still creating the membership.
/// Requires [canExcludeFromSales] so the opt-out only applies with permission.
bool shouldCreateNewMemberSale({
  required bool hasSelectedMembership,
  required bool excludeFromSales,
  required bool canExcludeFromSales,
}) =>
    hasSelectedMembership && !(excludeFromSales && canExcludeFromSales);

/// Choice from the existing-member match gate shown after Details → Next.
enum ExistingMemberMatchGateAction {
  /// Stay on the details step (dialog dismissed).
  stay,

  /// No match / user confirms this is a new person — continue the wizard.
  continueAsNew,

  /// User picked an existing member — renew with their profile.
  selectExisting,
}

/// Result of [showExistingMemberMatchGate].
class ExistingMemberMatchGateResult {
  const ExistingMemberMatchGateResult._(this.action, [this.member]);

  const ExistingMemberMatchGateResult.stay()
      : this._(ExistingMemberMatchGateAction.stay);

  const ExistingMemberMatchGateResult.continueAsNew()
      : this._(ExistingMemberMatchGateAction.continueAsNew);

  const ExistingMemberMatchGateResult.selectExisting(Member member)
      : this._(ExistingMemberMatchGateAction.selectExisting, member);

  final ExistingMemberMatchGateAction action;
  final Member? member;
}

/// Handles post-create wizard results: renew an existing match, or record payment.
Future<void> handleMemberFormPaymentResult(
  BuildContext context,
  MemberFormResult? result,
) async {
  final renewMember = result?.renewExistingMember;
  if (renewMember != null) {
    if (!context.mounted) return;
    await purchaseMembershipAndRecordPayment(
      context,
      memberId: renewMember.id,
      memberName: renewMember.name,
      isRenewal: true,
    );
    return;
  }

  if (result?.sale != null &&
      result?.totalPrice != null &&
      context.mounted) {
    await showRecordPaymentDialog(
      context,
      sale: result!.sale!,
      balanceDue: result.totalPrice!,
    );
  }
}

/// Name is always required on create/edit member forms.
FormFieldValidator<String> memberNameValidator() =>
    FormBuilderValidators.required();

/// Mobile number is required on create/edit member forms.
FormFieldValidator<String> memberMobileNumberValidator() =>
    FormBuilderValidators.required();

/// Shows a dialog form for creating or editing a member.
///
/// - **Create mode** (`member == null`): 5-step wizard
///   (Details → Photo → Card → Membership → Review). All data saved at the end.
/// - **Edit mode** (`member != null`): Single-step form (unchanged).
///
/// Returns a [MemberFormResult] if the member was saved successfully,
/// or `null` if the dialog was dismissed.
Future<MemberFormResult?> showMemberFormDialog(
  BuildContext context, {
  Member? member,
  String? initialName,
}) {
  return showConstrainedDialog<MemberFormResult>(
    context: context,
    // The edit form is a plain form that shrink-wraps on desktop/tablet, while
    // the create flow is a full-screen 5-step wizard.
    fullScreen: member == null,
    builder: (context) => MemberFormDialog(
      member: member,
      initialName: initialName,
    ),
  );
}

class MemberFormDialog extends HookConsumerWidget {
  const MemberFormDialog({super.key, this.member, this.initialName});

  final Member? member;
  final String? initialName;

  bool get isEditing => member != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isEditing) {
      return _MemberEditForm(member: member!);
    }
    return _MemberCreateWizard(initialName: initialName);
  }
}

// =============================================================================
// Edit Form (single-step, unchanged behavior)
// =============================================================================

class _MemberEditForm extends HookConsumerWidget {
  const _MemberEditForm({required this.member});

  final Member member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final isSaving = useState(false);
    final photoBytes = useState<Uint8List?>(null);
    final selectedPhoto = useState<XFile?>(null);

    final initialValues = <String, dynamic>{
      'name': member.name,
      'mobileNumber': member.mobileNumber,
      'email': member.email,
      'dateOfBirth': member.dateOfBirth,
      'sex': member.sex,
      'address': member.address,
      'emergencyContact': member.emergencyContact,
      'remarks': member.remarks,
    };

    final dirtyGuard = useFormDirtyGuard(
      formKey: formKey,
      initialValues: initialValues,
    );

    Future<void> handleSave(BuildContext dialogContext) async {
      if (!formKey.currentState!.saveAndValidate()) return;

      isSaving.value = true;
      final values = formKey.currentState!.value;

      final memberData = Member(
        id: member.id,
        name: formatPersonName(values['name'] as String),
        mobileNumber: values['mobileNumber'] as String?,
        email: values['email'] as String?,
        dateOfBirth: values['dateOfBirth'] as DateTime?,
        sex: values['sex'] as MemberSex?,
        address: values['address'] as String?,
        emergencyContact: values['emergencyContact'] as String?,
        remarks: values['remarks'] as String?,
        rfidCardId: member.rfidCardId,
        addedBy: member.addedBy,
        branch: member.branch,
      );

      http.MultipartFile? photoFile;
      if (photoBytes.value != null && selectedPhoto.value != null) {
        photoFile = http.MultipartFile.fromBytes(
          'photo',
          photoBytes.value!,
          filename: selectedPhoto.value!.name.isNotEmpty
              ? selectedPhoto.value!.name
              : memberPhotoFilename(),
        );
      }

      final success = await ref
          .read(membersControllerProvider.notifier)
          .updateMemberWithPhoto(memberData, photo: photoFile);

      ref.read(paginatedMembersControllerProvider.notifier).refresh();
      ref.invalidate(memberProvider(member.id));

      isSaving.value = false;

      if (success && dialogContext.mounted) {
        showSuccessSnackBar(
          dialogContext,
          message: 'Member updated',
          useRootMessenger: false,
        );
        Navigator.of(dialogContext).pop(const MemberFormResult());
      } else if (dialogContext.mounted) {
        showErrorSnackBar(
          dialogContext,
          message: 'Failed to update member',
          useRootMessenger: false,
        );
      }
    }

    return FormDialogScaffold(
      title: 'Edit Member',
      formKey: formKey,
      dirtyGuard: dirtyGuard,
      isSaving: isSaving.value,
      onSave: handleSave,
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final screenHeight = MediaQuery.sizeOf(context).height;
              final previewSize = fittedMemberPhotoPreviewSize(
                maxWidth: constraints.maxWidth.isFinite
                    ? constraints.maxWidth
                    : 280,
                maxHeight: screenHeight * 0.35,
                maxSize: 280,
                chromeHeight: 100,
              );
              return Center(
                child: MemberPhotoCapturePanel(
                  photoBytes: photoBytes,
                  selectedPhoto: selectedPhoto,
                  previewSize: previewSize,
                  avatarRadius: previewSize / 5,
                  existingPhotoUrl: member.photo,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _MemberFormFields(member: member),
        ],
      ),
    );
  }
}

// =============================================================================
// Create Wizard (5 steps)
// =============================================================================

class _MemberCreateWizard extends HookConsumerWidget {
  const _MemberCreateWizard({this.initialName});

  final String? initialName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentStep = useState(0);
    final isSaving = useState(false);

    // Step 1: Form state
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final dirtyGuard = useFormDirtyGuard(formKey: formKey);

    // Step 2: Photo state
    final selectedPhoto = useState<XFile?>(null);
    final photoBytes = useState<Uint8List?>(null);

    // Step 3: Card state
    final pendingCardValue = useState<String?>(null);
    final pendingCardLabel = useState<String?>(null);
    final pendingCardNotes = useState<String?>(null);
    final cardStepHasDraftInput = useState(false);

    // Step 4: Membership state
    final selectedMembership = useState<Membership?>(null);
    final selectedAddOns = useState<Set<MembershipAddOn>>({});
    // Default: create a sale + open record payment. Opt out via Review checkbox.
    final excludeFromSales = useState(false);
    final canExcludeFromSales =
        ref.watch(currentUserPermissionsProvider).value
            ?.canExcludeMembershipFromSales ??
        false;
    // One key for this wizard session so Save retries reuse sale/membership rows.
    final membershipIdempotencyKey = useMemoized(generateIdempotencyKey);

    Future<void> handleFinish() async {
      // Validate form from step 1
      if (!formKey.currentState!.saveAndValidate()) {
        currentStep.value = 0;
        return;
      }

      isSaving.value = true;
      final values = formKey.currentState!.value;

      final branchId = ref.read(effectiveBranchIdForWriteProvider) ?? '';
      final memberData = Member(
        id: '',
        name: formatPersonName(values['name'] as String),
        mobileNumber: values['mobileNumber'] as String?,
        email: values['email'] as String?,
        dateOfBirth: values['dateOfBirth'] as DateTime?,
        sex: values['sex'] as MemberSex?,
        address: values['address'] as String?,
        emergencyContact: values['emergencyContact'] as String?,
        remarks: values['remarks'] as String?,
        branch: branchId.isEmpty ? null : branchId,
      );

      // 1. Create member (with photo if selected)
      http.MultipartFile? photoFile;
      if (photoBytes.value != null && selectedPhoto.value != null) {
        photoFile = http.MultipartFile.fromBytes(
          'photo',
          photoBytes.value!,
          filename: selectedPhoto.value!.name.isNotEmpty
              ? selectedPhoto.value!.name
              : memberPhotoFilename(),
        );
      }

      final created = await ref
          .read(membersControllerProvider.notifier)
          .createMemberWithPhoto(memberData, photo: photoFile);

      if (created == null) {
        isSaving.value = false;
        if (context.mounted) {
          showErrorSnackBar(
            context,
            message: 'Failed to create member',
            useRootMessenger: false,
          );
        }
        return;
      }

      // 2. Add card if provided
      if (pendingCardValue.value?.trim().isNotEmpty == true) {
        final cardOk = await ref
            .read(memberCardsControllerProvider(created.id).notifier)
            .addCard(
              cardValue: pendingCardValue.value!.trim(),
              label: pendingCardLabel.value,
              notes: pendingCardNotes.value,
            );
        if (!cardOk && context.mounted) {
          showErrorSnackBar(
            context,
            message:
                'Member created but failed to add card. '
                'The card value may already be in use.',
            useRootMessenger: false,
          );
        }
      }

      // 3. Purchase membership if selected
      Sale? createdSale;
      if (selectedMembership.value != null) {
        final plan = selectedMembership.value!;
        final auth = ref.read(currentAuthProvider);
        final startDate = DateTime.now();
        final endDate = computeMembershipEndDate(
          startDate: startDate,
          durationValue: plan.durationValue,
          durationUnit: plan.durationUnit,
          bonusDays: MembershipAddOn.totalBonusDays(selectedAddOns.value),
        );

        final operationId = membershipIdempotencyKey;
        final createSale = shouldCreateNewMemberSale(
          hasSelectedMembership: true,
          excludeFromSales: excludeFromSales.value,
          canExcludeFromSales: canExcludeFromSales,
        );

        // 2a. Create a Sale record unless excluded from sales
        if (createSale) {
          final saleResult = await createMembershipSale(
            ref: ref,
            memberId: created.id,
            customerName: created.name,
            plan: plan,
            addOns: selectedAddOns.value,
            branchId: branchId,
            idempotencyKey: operationId,
          );
          saleResult.fold((failure) {
            // Sale failed — warn but continue with membership creation
            if (context.mounted) {
              showErrorSnackBar(
                context,
                message: 'Member created but failed to record sale',
                useRootMessenger: false,
              );
            }
          }, (sale) => createdSale = sale);
        }
        final saleId = createdSale?.id;

        // 2b. Create MemberMembership record linked to the sale (if any)
        final membershipRepo = ref.read(memberMembershipRepositoryProvider);
        final result = await membershipRepo.create(
          memberId: created.id,
          membershipId: plan.id,
          startDate: startDate,
          endDate: endDate,
          branchId: branchId,
          saleId: saleId,
          soldBy: auth?.user.id,
          idempotencyKey: operationId,
        );

        final createdMembership = result.fold(
          (failure) => null,
          (membership) => membership,
        );

        if (createdMembership == null) {
          // Member created but membership failed — still a partial success
          if (context.mounted) {
            showErrorSnackBar(
              context,
              message: 'Member created but failed to purchase membership',
              useRootMessenger: false,
            );
          }
        } else {
          // 2c. Create add-on records
          if (selectedAddOns.value.isNotEmpty) {
            final addOnRepo = ref.read(memberMembershipAddOnRepositoryProvider);
            for (final addOn in selectedAddOns.value) {
              await addOnRepo.create(
                memberMembershipId: createdMembership.id,
                membershipAddOnId: addOn.id,
                addOnName: addOn.name,
                price: addOn.price,
              );
            }
          }
        }
      }

      // 4. Refresh and close
      ref.read(paginatedMembersControllerProvider.notifier).refresh();
      refreshDashboardAfterMemberChange(ref);

      isSaving.value = false;

      if (context.mounted) {
        showSuccessSnackBar(
          context,
          message: 'Member created',
          useRootMessenger: false,
        );

        if (context.mounted) {
          num? totalPrice;
          if (createdSale != null) {
            final addOnTotal = selectedAddOns.value.fold<num>(
              0,
              (sum, a) => sum + a.price,
            );
            totalPrice = (selectedMembership.value?.price ?? 0) + addOnTotal;
          }
          Navigator.of(
            context,
          ).pop(MemberFormResult(sale: createdSale, totalPrice: totalPrice));
        }
      }
    }

    return ScaffoldMessenger(
      child: Builder(
        builder: (context) => DialogCloseHandler(
          onClose: (ctx) async {
            if (currentStep.value == 0) {
              return dirtyGuard.confirmDiscard(ctx);
            }
            // On steps 1-4, check if user has made selections
            if (selectedPhoto.value != null ||
                pendingCardValue.value != null ||
                cardStepHasDraftInput.value ||
                selectedMembership.value != null) {
              return await showDialog<bool>(
                    context: ctx,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Discard changes?'),
                      content: const Text(
                        'You have unsaved changes. Are you sure you want to discard them?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('Discard'),
                        ),
                      ],
                    ),
                  ) ??
                  false;
            }
            return true;
          },
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;
              if (currentStep.value == 0) {
                dirtyGuard.onPopInvokedWithResult(didPop, result);
              } else {
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
            child: ConstrainedDialogContent(
              fullScreen: true,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: isSaving.value
                                ? null
                                : () async {
                                    if (currentStep.value == 0) {
                                      if (await dirtyGuard.confirmDiscard(
                                        context,
                                      )) {
                                        if (context.mounted) {
                                          Navigator.of(context).pop();
                                        }
                                      }
                                    } else {
                                      Navigator.of(context).pop();
                                    }
                                  },
                          ),
                          Expanded(
                            child: Text(
                              'New Member',
                              style: theme.textTheme.titleLarge,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Step indicator
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: StepIndicator(
                        currentStep: currentStep.value,
                        steps: const [
                          'Details',
                          'Photo',
                          'Card',
                          'Membership',
                          'Review',
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Step content
                    Expanded(
                      child: IndexedStack(
                        index: currentStep.value,
                        children: [
                          // Step 0: Member Details
                          _MemberDetailsStep(
                            formKey: formKey,
                            initialName: initialName,
                            onNext: () => currentStep.value = 1,
                            onSelectExisting: (member) {
                              formKey.currentState?.patchValue(
                                memberFormValuesFromMember(member),
                              );
                              Navigator.of(context).pop(
                                MemberFormResult(renewExistingMember: member),
                              );
                            },
                          ),

                          // Step 1: Photo
                          _PhotoStep(
                            isActive: currentStep.value == 1,
                            selectedPhoto: selectedPhoto,
                            photoBytes: photoBytes,
                            onNext: () => currentStep.value = 2,
                            onBack: () => currentStep.value = 0,
                          ),

                          // Step 2: Card
                          _CardStep(
                            isActive: currentStep.value == 2,
                            pendingCardValue: pendingCardValue,
                            pendingCardLabel: pendingCardLabel,
                            pendingCardNotes: pendingCardNotes,
                            cardStepHasDraftInput: cardStepHasDraftInput,
                            onNext: () => currentStep.value = 3,
                            onSkip: () => currentStep.value = 3,
                            onBack: () => currentStep.value = 1,
                          ),

                          // Step 3: Membership
                          _MembershipStep(
                            selectedMembership: selectedMembership,
                            selectedAddOns: selectedAddOns,
                            onNext: () => currentStep.value = 4,
                            onSkip: () => currentStep.value = 4,
                            onBack: () => currentStep.value = 2,
                          ),

                          // Step 4: Review
                          _ReviewStep(
                            formKey: formKey,
                            photoBytes: photoBytes,
                            pendingCardValue: pendingCardValue,
                            pendingCardLabel: pendingCardLabel,
                            selectedMembership: selectedMembership,
                            selectedAddOns: selectedAddOns,
                            excludeFromSales: excludeFromSales,
                            canExcludeFromSales: canExcludeFromSales,
                            isSaving: isSaving.value,
                            onSave: handleFinish,
                            onBack: () => currentStep.value = 3,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Step 0: Member Details
// =============================================================================

class _MemberDetailsStep extends HookConsumerWidget {
  const _MemberDetailsStep({
    required this.formKey,
    required this.onNext,
    required this.onSelectExisting,
    this.initialName,
  });

  final GlobalKey<FormBuilderState> formKey;
  final VoidCallback onNext;
  final ValueChanged<Member> onSelectExisting;
  final String? initialName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isChecking = useState(false);

    Future<List<Member>> searchMembers(String query) async {
      const searchFields = ['name', 'mobileNumber'];
      final local = ref.read(memberLocalDataSourceProvider);
      final cached = await local.searchQuick(
        query,
        fields: searchFields,
        limit: Pagination.memberPickerSearchLimit,
      );
      final remote = await ref.read(memberRepositoryProvider).searchQuick(
            query,
            fields: searchFields,
            limit: Pagination.memberPickerSearchLimit,
          );
      return remote.fold((_) => cached, (members) => members);
    }

    Future<void> handleNext() async {
      if (!formKey.currentState!.saveAndValidate()) return;

      final values = formKey.currentState!.value;
      final name = (values['name'] as String?)?.trim() ?? '';
      final phone = (values['mobileNumber'] as String?)?.trim() ?? '';

      isChecking.value = true;
      List<Member> matches;
      try {
        matches = await lookupLikelyDuplicateMembers(
          name: name,
          phone: phone,
          search: searchMembers,
        );
      } finally {
        isChecking.value = false;
      }

      if (!context.mounted) return;

      // Empty on no match or lookup timeout — continue as new.
      if (matches.isEmpty) {
        onNext();
        return;
      }

      final gate = await showExistingMemberMatchGate(
        context,
        matches: matches,
      );
      if (!context.mounted) return;

      switch (gate.action) {
        case ExistingMemberMatchGateAction.stay:
          return;
        case ExistingMemberMatchGateAction.continueAsNew:
          onNext();
          return;
        case ExistingMemberMatchGateAction.selectExisting:
          final member = gate.member;
          if (member != null) onSelectExisting(member);
      }
    }

    return Column(
      children: [
        Expanded(
          child: FormBuilder(
            key: formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  _MemberFormFields(initialName: initialName),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
        if (isChecking.value) const LinearProgressIndicator(minHeight: 2),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isChecking.value ? null : handleNext,
              child: isChecking.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Next'),
            ),
          ),
        ),
      ],
    );
  }
}

/// Asks the user to pick a likely existing member or continue as new.
Future<ExistingMemberMatchGateResult> showExistingMemberMatchGate(
  BuildContext context, {
  required List<Member> matches,
}) async {
  final result = await showDialog<ExistingMemberMatchGateResult>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      return AlertDialog(
        title: const Text('Existing member found'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Name and phone look similar to an existing member. '
                'Select them to renew with their profile, or continue as new.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ...matches.map((member) {
                final phone = member.mobileNumber?.trim();
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    child: Text(
                      member.name.isNotEmpty
                          ? member.name[0].toUpperCase()
                          : '?',
                    ),
                  ),
                  title: Text(member.name),
                  subtitle: phone == null || phone.isEmpty ? null : Text(phone),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).pop(
                    ExistingMemberMatchGateResult.selectExisting(member),
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(
              const ExistingMemberMatchGateResult.stay(),
            ),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(
              const ExistingMemberMatchGateResult.continueAsNew(),
            ),
            child: const Text('Continue as new'),
          ),
        ],
      );
    },
  );
  return result ?? const ExistingMemberMatchGateResult.stay();
}

// =============================================================================
// Step 1: Photo
// =============================================================================

class _PhotoStep extends HookWidget {
  const _PhotoStep({
    required this.isActive,
    required this.selectedPhoto,
    required this.photoBytes,
    required this.onNext,
    required this.onBack,
  });

  final bool isActive;
  final ValueNotifier<XFile?> selectedPhoto;
  final ValueNotifier<Uint8List?> photoBytes;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    useListenable(selectedPhoto);

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Text(
                  'Add a Photo',
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'This step is optional. You can always add a photo later.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final previewSize = fittedMemberPhotoPreviewSize(
                        maxWidth: constraints.maxWidth,
                        maxHeight: constraints.maxHeight,
                        maxSize: 160,
                        chromeHeight: 180,
                      );
                      return Center(
                        child: SingleChildScrollView(
                          child: MemberPhotoCapturePanel(
                            isActive: isActive,
                            photoBytes: photoBytes,
                            selectedPhoto: selectedPhoto,
                            previewSize: previewSize,
                            avatarRadius: previewSize / 5,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        // Bottom nav
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              OutlinedButton(onPressed: onBack, child: const Text('Back')),
              const Spacer(),
              if (selectedPhoto.value == null)
                TextButton(onPressed: onNext, child: const Text('Skip'))
              else
                FilledButton(onPressed: onNext, child: const Text('Next')),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Step 2: Card
// =============================================================================

class _CardStep extends HookWidget {
  const _CardStep({
    required this.isActive,
    required this.pendingCardValue,
    required this.pendingCardLabel,
    required this.pendingCardNotes,
    required this.cardStepHasDraftInput,
    required this.onNext,
    required this.onSkip,
    required this.onBack,
  });

  final bool isActive;
  final ValueNotifier<String?> pendingCardValue;
  final ValueNotifier<String?> pendingCardLabel;
  final ValueNotifier<String?> pendingCardNotes;
  final ValueNotifier<bool> cardStepHasDraftInput;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback onBack;

  void _handleSkip() {
    pendingCardValue.value = null;
    pendingCardLabel.value = null;
    pendingCardNotes.value = null;
    cardStepHasDraftInput.value = false;
    onSkip();
  }

  void _handleNext(GlobalKey<FormBuilderState> formKey) {
    if (!formKey.currentState!.saveAndValidate()) return;

    final values = formKey.currentState!.value;
    pendingCardValue.value = (values['cardValue'] as String).trim();
    pendingCardLabel.value = values['label'] as String?;
    pendingCardNotes.value = values['notes'] as String?;
    cardStepHasDraftInput.value = false;
    onNext();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final entryMode = useState(MemberCardEntryMode.waitingForScan);
    useListenable(entryMode);

    useEffect(() {
      if (!isActive) {
        cardStepHasDraftInput.value = false;
      }
      return null;
    }, [isActive]);

    final hasCard = memberCardEntryCanSubmit(entryMode.value);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 32),
                Text(
                  'Add a Card',
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'This step is optional. Scan or enter an ID card for check-in.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FormBuilder(
                  key: formKey,
                  child: MemberCardEntryForm(
                    formKey: formKey,
                    entryMode: entryMode,
                    scanEnabled: isActive,
                    onDraftChanged: isActive
                        ? (hasDraft) => cardStepHasDraftInput.value = hasDraft
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              OutlinedButton(onPressed: onBack, child: const Text('Back')),
              const Spacer(),
              if (!hasCard)
                TextButton(
                  onPressed: _handleSkip,
                  child: const Text('Skip'),
                )
              else
                FilledButton(
                  onPressed: () => _handleNext(formKey),
                  child: const Text('Next'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Step 3: Membership
// =============================================================================

class _MembershipStep extends StatelessWidget {
  const _MembershipStep({
    required this.selectedMembership,
    required this.selectedAddOns,
    required this.onNext,
    required this.onSkip,
    required this.onBack,
  });

  final ValueNotifier<Membership?> selectedMembership;
  final ValueNotifier<Set<MembershipAddOn>> selectedAddOns;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback onBack;

  Future<void> _confirmSkip(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('No membership selected'),
        content: const Text(
          'This member will be created without a membership plan. '
          'You can always add one later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Go Back'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      onSkip();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: MembershipPurchaseContent(
            memberId: '',
            memberName: '',
            collectOnly: true,
            selectedMembership: selectedMembership,
            selectedAddOns: selectedAddOns,
          ),
        ),
        // Bottom nav
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              OutlinedButton(onPressed: onBack, child: const Text('Back')),
              const Spacer(),
              if (selectedMembership.value == null)
                TextButton(
                  onPressed: () => _confirmSkip(context),
                  child: const Text('Skip'),
                )
              else
                FilledButton(onPressed: onNext, child: const Text('Next')),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Step 4: Review
// =============================================================================

class _ReviewStep extends HookWidget {
  const _ReviewStep({
    required this.formKey,
    required this.photoBytes,
    required this.pendingCardValue,
    required this.pendingCardLabel,
    required this.selectedMembership,
    required this.selectedAddOns,
    required this.excludeFromSales,
    required this.canExcludeFromSales,
    required this.isSaving,
    required this.onSave,
    required this.onBack,
  });

  final GlobalKey<FormBuilderState> formKey;
  final ValueNotifier<Uint8List?> photoBytes;
  final ValueNotifier<String?> pendingCardValue;
  final ValueNotifier<String?> pendingCardLabel;
  final ValueNotifier<Membership?> selectedMembership;
  final ValueNotifier<Set<MembershipAddOn>> selectedAddOns;
  final ValueNotifier<bool> excludeFromSales;
  final bool canExcludeFromSales;
  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    useListenable(excludeFromSales);
    useListenable(selectedMembership);
    useListenable(selectedAddOns);

    final theme = Theme.of(context);
    final values = formKey.currentState?.value ?? {};
    final name = formatPersonName(values['name'] as String? ?? '');
    final mobile = values['mobileNumber'] as String?;
    final email = values['email'] as String?;
    final dob = values['dateOfBirth'] as DateTime?;
    final sex = values['sex'] as MemberSex?;
    final address = values['address'] as String?;
    final emergencyContact = values['emergencyContact'] as String?;
    final remarks = values['remarks'] as String?;
    final plan = selectedMembership.value;
    final addOns = selectedAddOns.value;
    final cardValue = pendingCardValue.value;
    final cardLabel = pendingCardLabel.value;

    final dateFormat = DateFormat.yMMMd();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Photo + Name header
                Center(
                  child: Column(
                    children: [
                      if (photoBytes.value != null)
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: MemoryImage(photoBytes.value!),
                        )
                      else
                        const CachedAvatar(radius: 40),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style: theme.textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Personal details
                Text(
                  'Personal Details',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Divider(),
                if (mobile != null && mobile.isNotEmpty)
                  _ReviewRow(label: 'Mobile', value: mobile),
                if (email != null && email.isNotEmpty)
                  _ReviewRow(label: 'Email', value: email),
                if (dob != null)
                  _ReviewRow(
                    label: 'Date of Birth',
                    value: dateFormat.format(dob),
                  ),
                if (sex != null)
                  _ReviewRow(label: 'Sex', value: sex.displayName),
                if (address != null && address.isNotEmpty)
                  _ReviewRow(label: 'Address', value: address),
                if (emergencyContact != null && emergencyContact.isNotEmpty)
                  _ReviewRow(
                    label: 'Emergency Contact',
                    value: emergencyContact,
                  ),
                if (remarks != null && remarks.isNotEmpty)
                  _ReviewRow(label: 'Remarks', value: remarks),
                if ([
                      mobile,
                      email,
                      address,
                      emergencyContact,
                      remarks,
                    ].every((v) => v == null || v.isEmpty) &&
                    dob == null &&
                    sex == null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No additional details provided',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // ID Card
                Text(
                  'ID Card',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Divider(),
                if (cardValue != null && cardValue.isNotEmpty) ...[
                  _ReviewRow(label: 'Card ID', value: cardValue),
                  if (cardLabel != null && cardLabel.isNotEmpty)
                    _ReviewRow(label: 'Label', value: cardLabel),
                ] else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'No card added',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Membership
                Text(
                  'Membership',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Divider(),
                if (plan != null) ...[
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(
                          Icons.card_membership,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      title: Text(plan.name),
                      subtitle: Text(plan.durationDisplay),
                      trailing: Text(
                        plan.price.toCurrency(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (addOns.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...addOns.map(
                      (addOn) => ListTile(
                        dense: true,
                        leading: Icon(
                          addOn.extendsDuration
                              ? Icons.event_available
                              : Icons.extension,
                          size: 20,
                        ),
                        title: Text(addOn.name),
                        subtitle: addOn.extendsDuration
                            ? Text(addOn.durationDisplay)
                            : null,
                        trailing: Text(addOn.price.toCurrency()),
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            (plan.price +
                                    addOns.fold<num>(
                                      0,
                                      (sum, a) => sum + a.price,
                                    ))
                                .toCurrency(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  if (canExcludeFromSales)
                    CheckboxListTile(
                      value: excludeFromSales.value,
                      onChanged: isSaving
                          ? null
                          : (checked) {
                              excludeFromSales.value = checked ?? false;
                            },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: const Text('Exclude from sales'),
                      subtitle: Text(
                        'Create membership without a sale or payment',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ] else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'No membership selected',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        // Bottom nav
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              OutlinedButton(
                onPressed: isSaving ? null : onBack,
                child: const Text('Back'),
              ),
              const Spacer(),
              FilledButton(
                onPressed: isSaving ? null : onSave,
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        plan != null &&
                                excludeFromSales.value &&
                                canExcludeFromSales
                            ? 'Save (no sale)'
                            : 'Save',
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// =============================================================================
// Shared Form Fields
// =============================================================================

class _MemberFormFields extends StatelessWidget {
  const _MemberFormFields({this.member, this.initialName});

  final Member? member;
  final String? initialName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FormBuilderTextField(
          name: 'name',
          initialValue: member?.name ?? initialName,
          decoration: const InputDecoration(labelText: 'Name *'),
          validator: memberNameValidator(),
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),
        FormBuilderTextField(
          name: 'mobileNumber',
          initialValue: member?.mobileNumber,
          decoration: const InputDecoration(labelText: 'Mobile Number *'),
          validator: memberMobileNumberValidator(),
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        FormBuilderTextField(
          name: 'email',
          initialValue: member?.email,
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        FormBuilderDateTimePicker(
          name: 'dateOfBirth',
          initialValue: member?.dateOfBirth,
          decoration: const InputDecoration(labelText: 'Date of Birth'),
          inputType: InputType.date,
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        ),
        const SizedBox(height: 16),
        FormBuilderDropdown<MemberSex>(
          name: 'sex',
          initialValue: member?.sex,
          decoration: const InputDecoration(labelText: 'Sex'),
          items: MemberSex.values
              .map(
                (s) => DropdownMenuItem(value: s, child: Text(s.displayName)),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
        FormBuilderTextField(
          name: 'address',
          initialValue: member?.address,
          decoration: const InputDecoration(labelText: 'Address'),
          maxLines: 2,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 16),
        FormBuilderTextField(
          name: 'emergencyContact',
          initialValue: member?.emergencyContact,
          decoration: const InputDecoration(labelText: 'Emergency Contact'),
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),
        FormBuilderTextField(
          name: 'remarks',
          initialValue: member?.remarks,
          decoration: const InputDecoration(labelText: 'Remarks'),
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }
}
