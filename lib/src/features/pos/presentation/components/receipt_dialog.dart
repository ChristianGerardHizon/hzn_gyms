import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../core/pdf/pdf_task_runner.dart';
import '../../../../core/routing/routes/system.routes.dart';
import '../../../../core/utils/currency_format.dart';
import '../../../../core/widgets/dialog_close_handler.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../../settings/presentation/controllers/branch_provider.dart';
import '../../../settings/presentation/controllers/printer_config_provider.dart';
import '../../domain/sale.dart';
import '../../domain/sale_item.dart';
import '../services/thermal_print_service.dart';

/// Payload for receipt PDF generation in an isolate.
class _ReceiptPdfPayload {
  _ReceiptPdfPayload({
    required this.receiptNumber,
    required this.createdDate,
    required this.totalAmount,
    required this.isPaid,
    this.notes,
  });

  final String receiptNumber;
  final DateTime createdDate;
  final double totalAmount;
  final bool isPaid;
  final String? notes;
}

/// Top-level function that builds receipt PDF bytes in an isolate.
Future<Uint8List> _buildReceiptPdfBytes(_ReceiptPdfPayload payload) async {
  final dateFormat = DateFormat('MMM dd, yyyy hh:mm a');
  // Use 'P' instead of '₱' for PDF compatibility (Helvetica doesn't support ₱)
  final currencyFormat = NumberFormat.currency(symbol: 'P', decimalDigits: 2);

  final pdf = pw.Document();
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Center(
            child: pw.Text(
              'Receipt',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Text(
              '#${payload.receiptNumber}',
              style: const pw.TextStyle(fontSize: 12),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.SizedBox(height: 10),
          pw.Text(
            'Date: ${dateFormat.format(payload.createdDate)}',
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Status: ${payload.isPaid ? 'Paid' : 'Unpaid'}',
          ),
          pw.SizedBox(height: 10),
          pw.Divider(),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Total:',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                currencyFormat.format(payload.totalAmount),
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          if (payload.notes != null && payload.notes!.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Text(
              'Notes:',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(payload.notes!),
          ],
          pw.SizedBox(height: 20),
          pw.Center(
            child: pw.Text(
              'Thank you!',
              style: const pw.TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    ),
  );
  return await pdf.save();
}

/// Shows the receipt dialog after successful checkout.
Future<void> showReceiptDialog(
  BuildContext context, {
  required Sale sale,
  List<SaleItem> saleItems = const [],
}) {
  return showDialog(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.all(8),
      clipBehavior: Clip.antiAlias,
      child: ScaffoldMessenger(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: ReceiptDialog(
            sale: sale,
            saleItems: saleItems,
          ),
        ),
      ),
    ),
  );
}

/// Receipt dialog displaying sale details.
class ReceiptDialog extends HookConsumerWidget {
  const ReceiptDialog({
    super.key,
    required this.sale,
    this.saleItems = const [],
  });

  final Sale sale;
  final List<SaleItem> saleItems;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final dateFormat = DateFormat('MMM dd, yyyy hh:mm a');
    final isPrinting = useState(false);
    final hasAutoPrinted = useState(false);
    final printCashierCopy = useState(true);
    final defaultPrinterAsync = ref.watch(defaultPrinterProvider);
    final currentAuth = ref.watch(currentAuthProvider);

    // Watch branch for business info on receipts
    final branchId = ref.watch(currentBranchIdProvider);
    final branchAsync = ref.watch(branchProvider(branchId ?? ''));

    Future<void> handleThermalPrint({bool showSuccessMessage = true}) async {
      // Get printer before async operations to avoid ref disposal issues
      final printer = defaultPrinterAsync.value;
      if (printer == null) {
        showErrorSnackBar(context,
            message: 'No default printer configured', useRootMessenger: false);
        return;
      }

      isPrinting.value = true;

      final printService = ref.read(thermalPrintServiceProvider.notifier);

      // Get branch info for receipt header
      final currentBranch = branchAsync.value;

      // Print customer copy
      final result = await printService.printReceipt(
        printer: printer,
        sale: sale,
        items: saleItems,
        businessName: currentBranch?.name,
        branchAddress: currentBranch?.address,
        contactNumber: currentBranch?.contactNumber,
        cashierName: currentAuth?.user.name,
      );

      if (result is PrintFailure) {
        isPrinting.value = false;
        if (context.mounted) {
          showErrorSnackBar(context,
              message: result.message, useRootMessenger: false);
        }
        return;
      }

      // Print cashier copy if enabled
      if (printCashierCopy.value) {
        // Small delay between prints to ensure printer is ready
        await Future.delayed(const Duration(milliseconds: 500));

        final cashierResult = await printService.printReceipt(
          printer: printer,
          sale: sale,
          items: saleItems,
          businessName: currentBranch?.name,
          branchAddress: currentBranch?.address,
          contactNumber: currentBranch?.contactNumber,
          cashierName: currentAuth?.user.name,
        );

        if (cashierResult is PrintFailure) {
          isPrinting.value = false;
          if (context.mounted) {
            showErrorSnackBar(
              context,
              message: 'Customer copy printed, but cashier copy failed',
              useRootMessenger: false,
            );
          }
          return;
        }
      }

      isPrinting.value = false;

      if (!context.mounted) return;

      if (showSuccessMessage) {
        final copies = printCashierCopy.value ? '2 copies' : '1 copy';
        showSuccessSnackBar(context,
            message: 'Receipt printed ($copies)', useRootMessenger: false);
      }
    }

    // Auto-print when dialog opens if default printer is configured
    useEffect(() {
      final defaultPrinter = defaultPrinterAsync.value;
      if (defaultPrinter != null &&
          !hasAutoPrinted.value &&
          !isPrinting.value) {
        hasAutoPrinted.value = true;
        // Slight delay to ensure UI is ready
        Future.delayed(const Duration(milliseconds: 300), () {
          handleThermalPrint(showSuccessMessage: true);
        });
      }
      return null;
    }, [defaultPrinterAsync.value]);

    Future<void> handlePdfPrint() async {
      final result = await runPdfTask<_ReceiptPdfPayload>(
        context: context,
        message: 'Generating receipt...',
        preload: () async => _ReceiptPdfPayload(
          receiptNumber: sale.receiptNumber,
          createdDate: sale.created ?? DateTime.now(),
          totalAmount: sale.totalAmount.toDouble(),
          isPaid: sale.isPaid,
          notes: sale.notes,
        ),
        generate: _buildReceiptPdfBytes,
      );
      if (result is! PdfTaskSuccess) return;

      await Printing.layoutPdf(
        onLayout: (_) async => result.bytes,
      );
    }

    final hasDefaultPrinter = defaultPrinterAsync.value != null;

    return DialogCloseHandler(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Text(
                      'Receipt',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  if (hasDefaultPrinter) ...[
                    IconButton.outlined(
                      onPressed: handlePdfPrint,
                      icon: const Icon(Icons.picture_as_pdf),
                      tooltip: 'Print as PDF',
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: isPrinting.value ? null : handleThermalPrint,
                      icon: isPrinting.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.print),
                      label: Text(isPrinting.value ? 'Printing...' : 'Print'),
                    ),
                  ] else ...[
                    OutlinedButton.icon(
                      onPressed: handlePdfPrint,
                      icon: const Icon(Icons.print_outlined),
                      label: const Text('Print PDF'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        context.pop();
                        const PrinterSettingsRoute().go(context);
                      },
                      child: const Text('Setup Printer'),
                    ),
                  ],
                  const SizedBox(width: 8),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Success icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                size: 40,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Sale Complete!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              'Receipt #${sale.receiptNumber}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Receipt details
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        context,
                        'Date',
                        sale.created != null
                            ? dateFormat.format(sale.created!)
                            : dateFormat.format(DateTime.now()),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        context,
                        'Payment Status',
                        sale.isPaid ? 'Paid' : 'Unpaid',
                      ),
                      const SizedBox(height: 16),
                      // Prominent total display
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Amount',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              sale.totalAmount.toCurrency(),
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (sale.notes != null && sale.notes!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Notes',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sale.notes!,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Cashier copy option (only show if printer configured)
            if (hasDefaultPrinter)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: CheckboxListTile(
                  value: printCashierCopy.value,
                  onChanged: (value) => printCashierCopy.value = value ?? true,
                  title: const Text('Print cashier copy'),
                  subtitle: const Text('Prints 2 copies: customer + business'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),

            // Done button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: hasDefaultPrinter
                    ? OutlinedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Done'),
                      )
                    : FilledButton(
                        onPressed: () => context.pop(),
                        child: const Text('Done'),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    bool isTotal = false,
  }) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                )
              : theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
        ),
        Text(
          value,
          style: isTotal
              ? theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                )
              : theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
        ),
      ],
    );
  }
}
