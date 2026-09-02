import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/hooks/use_form_dirty_guard.dart';
import '../../../../core/utils/idempotency.dart';
import '../../../../core/utils/photo_capture_support.dart';
import '../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../../core/widgets/form/form_dialog_scaffold.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../../core/widgets/live_camera_capture_dialog.dart';
import '../../../dashboard/presentation/controllers/dashboard_refresh.dart';
import '../../../pos/domain/payment_method.dart';
import '../../../pos/domain/sale.dart';
import '../../../pos/presentation/payments_controller.dart';
import '../../domain/payment_amount_validation.dart';
import '../controllers/sale_provider.dart';

/// Shows the record payment dialog and returns true if a payment was recorded.
Future<bool?> showRecordPaymentDialog(
  BuildContext context, {
  required Sale sale,
  required num balanceDue,
}) {
  return showConstrainedDialog<bool>(
    context: context,
    builder: (context) => RecordPaymentDialog(
      sale: sale,
      balanceDue: balanceDue,
    ),
  );
}

/// Dialog for recording a payment against a sale.
class RecordPaymentDialog extends HookConsumerWidget {
  const RecordPaymentDialog({
    super.key,
    required this.sale,
    required this.balanceDue,
  });

  final Sale sale;
  final num balanceDue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final isSaving = useState(false);
    final selectedPaymentMethod = useState(PaymentMethod.cash);
    final proofImage = useState<XFile?>(null);
    final proofImageBytes = useState<Uint8List?>(null);
    // One key for this dialog session so retries reuse the same payment row.
    final paymentIdempotencyKey = useMemoized(generateIdempotencyKey);
    final currencyFormat =
        NumberFormat.currency(symbol: '\u20B1', decimalDigits: 2);
    final imagePicker = useMemoized(() => ImagePicker());

    final initialValues = <String, dynamic>{
      'amount': balanceDue.toString(),
      'paymentType': PaymentMethod.cash,
      'paymentRef': null,
      'notes': null,
    };

    final dirtyGuard = useFormDirtyGuard(
      formKey: formKey,
      initialValues: initialValues,
    );

    void clearProofImage() {
      proofImage.value = null;
      proofImageBytes.value = null;
    }

    Future<void> setProofImage(XFile file, {Uint8List? bytes}) async {
      proofImage.value = file;
      proofImageBytes.value = bytes ?? await file.readAsBytes();
    }

    Future<void> pickImage() async {
      final picked = await imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (picked != null) {
        await setProofImage(picked);
      }
    }

    Future<void> takePhoto() async {
      // Web (and mobile) get a real live preview; ImagePicker.camera on web is
      // just another file picker.
      if (isLiveCameraSupported()) {
        final captured = await showLiveCameraCaptureDialog(
          context,
          title: 'Capture payment proof',
          filename: paymentProofFilename(),
        );
        if (captured != null) {
          await setProofImage(captured.file, bytes: captured.bytes);
        }
        return;
      }

      if (!isImagePickerCameraSupported()) {
        // Desktop without live camera: fall back to gallery picker.
        await pickImage();
        return;
      }

      final picked = await imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (picked != null) {
        await setProofImage(picked);
      }
    }

    Future<void> handleSave(BuildContext dialogContext) async {
      if (!formKey.currentState!.saveAndValidate()) return;

      final values = formKey.currentState!.value;
      final amount = num.tryParse(values['amount']?.toString() ?? '') ?? 0;
      final paymentMethod = values['paymentType'] as PaymentMethod;
      final paymentType = paymentMethod.recordingPaymentType;
      final paymentRef = values['paymentRef'] as String?;
      final notes = values['notes'] as String?;

      isSaving.value = true;

      // Prepare file if selected (cash never shows the proof picker).
      http.MultipartFile? proofFile;
      if (paymentMethod.showsPaymentProof && proofImage.value != null) {
        final bytes = proofImageBytes.value ??
            await proofImage.value!.readAsBytes();
        proofFile = http.MultipartFile.fromBytes(
          'paymentProof',
          bytes,
          filename: proofImage.value!.name.isNotEmpty
              ? proofImage.value!.name
              : paymentProofFilename(),
        );
      }

      final controller = ref.read(paymentsControllerProvider.notifier);
      final payment = await controller.recordPayment(
        saleId: sale.id,
        amount: amount,
        paymentMethod: paymentMethod,
        type: paymentType,
        paymentRef: paymentMethod.showsPaymentReference ? paymentRef : null,
        notes: notes,
        idempotencyKey: paymentIdempotencyKey,
        paymentProofFile: proofFile,
      );

      isSaving.value = false;

      if (!dialogContext.mounted) return;

      if (payment != null) {
        // Refresh the sale, dashboard KPIs, and paginated sales list
        ref.invalidate(saleProvider(sale.id));
        refreshSalesData(ref);
        Navigator.of(dialogContext).pop(true);
        showSuccessSnackBar(dialogContext,
            message: 'Payment recorded successfully',
            useRootMessenger: false);
      } else {
        showErrorSnackBar(dialogContext,
            message: 'Failed to record payment', useRootMessenger: false);
      }
    }

    final showReferenceField =
        selectedPaymentMethod.value.showsPaymentReference;
    final showProofSection = selectedPaymentMethod.value.showsPaymentProof;
    final proofBytes = proofImageBytes.value;

    return FormDialogScaffold(
          title: 'Record Payment',
          formKey: formKey,
          dirtyGuard: dirtyGuard,
          isSaving: isSaving.value,
          onSave: handleSave,
          saveLabel: 'Record Payment',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Balance due info
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Balance Due:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        currencyFormat.format(balanceDue),
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Amount field
              FormBuilderTextField(
                name: 'amount',
                initialValue: balanceDue.toString(),
                decoration: InputDecoration(
                  labelText: 'Amount *',
                  prefixText: '\u20B1 ',
                  helperText:
                      'Enter an amount between \u20B10 and '
                      '${currencyFormat.format(balanceDue)}',
                  border: const OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => validatePaymentAmount(value, balanceDue),
              ),
              const SizedBox(height: 16),

              // Payment type (backed by PaymentMethod; method dropdown is hidden)
              FormBuilderChoiceChips<PaymentMethod>(
                name: 'paymentType',
                initialValue: PaymentMethod.cash,
                decoration: const InputDecoration(
                  labelText: 'Payment Type',
                  border: InputBorder.none,
                ),
                spacing: 8,
                options: PaymentMethod.forRecording
                    .map((method) => FormBuilderChipOption(
                          value: method,
                          child: Text(method.displayName),
                        ))
                    .toList(),
                validator: FormBuilderValidators.required(),
                onChanged: (value) {
                  if (value != null) {
                    selectedPaymentMethod.value = value;
                    if (!value.showsPaymentProof) {
                      clearProofImage();
                    }
                  }
                },
              ),
              const SizedBox(height: 16),

              // Payment reference - only shown for non-cash methods
              if (showReferenceField) ...[
                FormBuilderTextField(
                  name: 'paymentRef',
                  decoration: const InputDecoration(
                    labelText: 'Reference Number',
                    hintText: 'Transaction / check reference',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Proof of payment - hidden for cash
              if (showProofSection) ...[
                Text(
                  'Proof of Payment',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                if (proofBytes != null && proofBytes.isNotEmpty) ...[
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          // Web-safe preview (Image.file is unavailable on web).
                          proofBytes,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton.filled(
                          onPressed: clearProofImage,
                          icon: const Icon(Icons.close),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: pickImage,
                        icon: const Icon(Icons.photo_library),
                        label: Text(kIsWeb ? 'Upload' : 'Gallery'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: takePhoto,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Notes
              FormBuilderTextField(
                name: 'notes',
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Optional notes about this payment',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
    );
  }
}
