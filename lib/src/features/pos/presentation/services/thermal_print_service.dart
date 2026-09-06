import 'dart:typed_data';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_network/flutter_esc_pos_network.dart';
import 'package:intl/intl.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/utils/permission_service.dart';
import '../../../settings/domain/printer_config.dart';
import '../../../settings/domain/printer_paper_width.dart';
import '../../domain/sale.dart';
import '../../domain/sale_item.dart';

part 'thermal_print_service.g.dart';

/// Result of a print operation.
sealed class PrintResult {
  const PrintResult();
}

/// Print operation succeeded.
class PrintSuccess extends PrintResult {
  const PrintSuccess();
}

/// Print operation failed.
class PrintFailure extends PrintResult {
  const PrintFailure(this.message);
  final String message;
}

/// Service for thermal printing operations.
@riverpod
class ThermalPrintService extends _$ThermalPrintService {
  @override
  FutureOr<void> build() {}

  /// Prints a sale receipt to the specified printer.
  ///
  /// The [printer] config must be passed from the caller to avoid
  /// async ref access issues.
  Future<PrintResult> printReceipt({
    required PrinterConfig printer,
    required Sale sale,
    required List<SaleItem> items,
    String? businessName,
    String? branchAddress,
    String? contactNumber,
    String? cashierName,
  }) async {
    if (!printer.hasAddress) {
      return const PrintFailure('Printer address not configured');
    }

    // Generate receipt bytes
    final bytes = await _generateReceiptBytes(
      sale: sale,
      items: items,
      paperWidth: printer.paperWidth,
      businessName: businessName ?? '',
      branchAddress: branchAddress ?? '',
      contactNumber: contactNumber ?? '',
      cashierName: cashierName,
    );

    // Print based on connection type
    return _printBytes(printer, bytes);
  }

  /// Prints a test page to verify printer connection.
  Future<PrintResult> printTestPage(PrinterConfig config) async {
    if (!config.hasAddress) {
      return const PrintFailure('Printer address not configured');
    }

    final bytes = await _generateTestPageBytes(config.paperWidth);
    return _printBytes(config, bytes);
  }

  /// Discovers available Bluetooth printers.
  ///
  /// Requests Bluetooth permissions if not yet granted.
  /// Throws [PermissionDeniedException] if permissions are permanently denied.
  Future<List<BluetoothInfo>> discoverBluetoothPrinters() async {
    // Ensure Bluetooth permissions are granted before scanning
    await PermissionService.ensureBluetoothPermissions();

    try {
      final isEnabled = await PrintBluetoothThermal.bluetoothEnabled;
      if (!isEnabled) {
        return [];
      }

      final devices = await PrintBluetoothThermal.pairedBluetooths;
      return devices;
    } catch (e) {
      debugPrint('Error discovering Bluetooth printers: $e');
      return [];
    }
  }

  /// Checks if Bluetooth is available and enabled.
  ///
  /// Requests Bluetooth permissions if not yet granted.
  /// Throws [PermissionDeniedException] if permissions are permanently denied.
  Future<bool> isBluetoothEnabled() async {
    try {
      await PermissionService.ensureBluetoothPermissions();
      return await PrintBluetoothThermal.bluetoothEnabled;
    } catch (e) {
      if (e is PermissionDeniedException) rethrow;
      return false;
    }
  }

  /// Prints bytes to the configured printer.
  Future<PrintResult> _printBytes(PrinterConfig config, List<int> bytes) async {
    try {
      if (config.isBluetooth) {
        return await _printViaBluetooth(config.address!, bytes);
      } else {
        return await _printViaNetwork(config.address!, config.port, bytes);
      }
    } catch (e) {
      return PrintFailure('Print error: $e');
    }
  }

  /// Prints via Bluetooth connection.
  Future<PrintResult> _printViaBluetooth(
    String macAddress,
    List<int> bytes,
  ) async {
    try {
      // Ensure Bluetooth permissions are granted before printing
      try {
        await PermissionService.ensureBluetoothPermissions();
      } on PermissionDeniedException catch (e) {
        return PrintFailure(e.message);
      }

      // Check if Bluetooth is enabled
      final isEnabled = await PrintBluetoothThermal.bluetoothEnabled;
      if (!isEnabled) {
        return const PrintFailure('Bluetooth is not enabled');
      }

      // Connect to the printer
      final connected = await PrintBluetoothThermal.connect(
        macPrinterAddress: macAddress,
      );
      if (!connected) {
        return const PrintFailure('Failed to connect to Bluetooth printer');
      }

      // Print the data
      final result = await PrintBluetoothThermal.writeBytes(
        Uint8List.fromList(bytes),
      );

      // Disconnect
      await PrintBluetoothThermal.disconnect;

      if (result) {
        return const PrintSuccess();
      } else {
        return const PrintFailure('Failed to send data to printer');
      }
    } catch (e) {
      return PrintFailure('Bluetooth print error: $e');
    }
  }

  /// Prints via network connection.
  Future<PrintResult> _printViaNetwork(
    String ipAddress,
    int port,
    List<int> bytes,
  ) async {
    try {
      final printer = PrinterNetworkManager(ipAddress, port: port);
      final result = await printer.connect();

      if (result != PosPrintResult.success) {
        return PrintFailure('Failed to connect to network printer: $result');
      }

      await printer.printTicket(bytes);
      await printer.disconnect();

      return const PrintSuccess();
    } catch (e) {
      return PrintFailure('Network print error: $e');
    }
  }

  /// Generates receipt bytes for the given sale.
  Future<List<int>> _generateReceiptBytes({
    required Sale sale,
    required List<SaleItem> items,
    required PrinterPaperWidth paperWidth,
    required String businessName,
    String? branchAddress,
    String? contactNumber,
    String? cashierName,
  }) async {
    // Use 'default' profile for better compatibility
    final profile = await CapabilityProfile.load(name: 'default');
    final generator = Generator(
      paperWidth == PrinterPaperWidth.mm58 ? PaperSize.mm58 : PaperSize.mm80,
      profile,
    );

    List<int> bytes = [];

    // Reset printer to clear any previous state
    bytes += generator.reset();

    // Header - Business Name
    bytes += generator.text(
      businessName,
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );

    // Address
    if (branchAddress != null && branchAddress.isNotEmpty) {
      bytes += generator.text(
        branchAddress,
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    // Contact Number
    if (contactNumber != null && contactNumber.isNotEmpty) {
      bytes += generator.text(
        'Tel: $contactNumber',
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    bytes += generator.hr(ch: '=');

    // Receipt info
    bytes += generator.text('Receipt: ${sale.receiptNumber}');

    final dateFormat = DateFormat('MMM dd, yyyy hh:mm a');
    final dateStr = sale.created != null
        ? dateFormat.format(sale.created!)
        : dateFormat.format(DateTime.now());
    bytes += generator.text('Date: $dateStr');

    // Cashier name
    if (cashierName != null && cashierName.isNotEmpty) {
      bytes += generator.text('Cashier: $cashierName');
    }

    bytes += generator.hr();

    // Column headers
    bytes += generator.row([
      PosColumn(text: 'ITEM', width: 6, styles: const PosStyles(bold: true)),
      PosColumn(
        text: 'QTY',
        width: 2,
        styles: const PosStyles(bold: true, align: PosAlign.center),
      ),
      PosColumn(
        text: 'AMOUNT',
        width: 4,
        styles: const PosStyles(bold: true, align: PosAlign.right),
      ),
    ]);

    bytes += generator.hr();

    // Items - Use 'P' instead of '₱' for thermal printer ASCII compatibility
    final currencyFormat = NumberFormat.currency(symbol: 'P', decimalDigits: 2);
    for (final item in items) {
      // Truncate long product names
      String productName = item.productName;
      if (productName.length > 16) {
        productName = '${productName.substring(0, 14)}..';
      }

      bytes += generator.row([
        PosColumn(text: productName, width: 6),
        PosColumn(
          text: '${item.quantity.toInt()}',
          width: 2,
          styles: const PosStyles(align: PosAlign.center),
        ),
        PosColumn(
          text: currencyFormat.format(item.subtotal),
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.hr();

    // Total
    bytes += generator.row([
      PosColumn(text: 'TOTAL:', width: 6, styles: const PosStyles(bold: true)),
      PosColumn(text: '', width: 2),
      PosColumn(
        text: currencyFormat.format(sale.totalAmount),
        width: 4,
        styles: const PosStyles(bold: true, align: PosAlign.right),
      ),
    ]);

    bytes += generator.hr();

    // Payment info
    bytes += generator.text('Status: ${sale.isPaid ? 'PAID' : 'UNPAID'}');

    if (sale.customerName != null && sale.customerName!.isNotEmpty) {
      bytes += generator.text('Customer: ${sale.customerName}');
    }

    if (sale.notes != null && sale.notes!.isNotEmpty) {
      bytes += generator.hr();
      bytes += generator.text('Notes: ${sale.notes}');
    }

    bytes += generator.hr();

    // Footer
    bytes += generator.text(
      'Thank you!',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );

    bytes += generator.hr(ch: '=');

    // Feed and cut
    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }

  /// Generates test page bytes.
  Future<List<int>> _generateTestPageBytes(PrinterPaperWidth paperWidth) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(
      paperWidth == PrinterPaperWidth.mm58 ? PaperSize.mm58 : PaperSize.mm80,
      profile,
    );

    List<int> bytes = [];

    bytes += generator.hr(ch: '=');
    bytes += generator.text(
      'PRINTER TEST',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.hr(ch: '=');

    bytes += generator.text('If you can read this,');
    bytes += generator.text('the printer is working correctly.');
    bytes += generator.emptyLines(1);

    bytes += generator.text(
      'Paper Width: ${paperWidth.displayName}',
      styles: const PosStyles(align: PosAlign.center),
    );

    final dateFormat = DateFormat('MMM dd, yyyy hh:mm a');
    bytes += generator.text(
      'Printed: ${dateFormat.format(DateTime.now())}',
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.hr(ch: '=');
    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }
}
