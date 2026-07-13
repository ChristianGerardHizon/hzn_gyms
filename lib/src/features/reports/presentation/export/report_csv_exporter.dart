import 'dart:convert';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/permission_service.dart';
import '../../domain/attendance_report.dart';
import '../../domain/inventory_report.dart';
import '../../domain/membership_report.dart';
import '../../domain/report_aggregations.dart';
import '../../domain/report_period.dart';
import '../../domain/sales_report.dart';

/// Builds and saves CSV exports for report tabs.
class ReportCsvExporter {
  ReportCsvExporter._();

  static final _currency = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
  static final _date = DateFormat('yyyy-MM-dd');

  static Future<void> exportSales({
    required BuildContext context,
    required SalesReport report,
    required ReportPeriodSelection period,
  }) async {
    final buffer = StringBuffer();
    buffer.writeln('Sales Report');
    buffer.writeln('Period,${period.displayName}');
    buffer.writeln('Range,${period.displayRangeLabel}');
    buffer.writeln(
      'Dates,${_date.format(period.startDate)} - ${_date.format(period.endDate)}',
    );
    buffer.writeln();
    buffer.writeln('KPI,Value');
    buffer.writeln('Total Revenue,${_currency.format(report.totalRevenue)}');
    buffer.writeln('Transactions,${report.transactionCount}');
    buffer.writeln(
      'Average Transaction,${_currency.format(report.averageTransactionValue)}',
    );
    buffer.writeln('Unpaid Sales,${report.unpaidSalesCount}');
    buffer.writeln(
      'Unpaid Balance,${_currency.format(report.unpaidBalance)}',
    );
    buffer.writeln();
    buffer.writeln('Revenue by Item Type');
    buffer.writeln('Type,Revenue');
    for (final e in report.revenueByItemType.entries) {
      buffer.writeln('${itemTypeLabel(e.key)},${_currency.format(e.value)}');
    }
    buffer.writeln();
    buffer.writeln('Top Products');
    buffer.writeln('Product,Quantity,Revenue');
    for (final p in report.topSellingProducts) {
      buffer.writeln(
        '${_csv(p.productName)},${p.quantity},${_currency.format(p.revenue)}',
      );
    }
    buffer.writeln();
    buffer.writeln('Staff Performance');
    buffer.writeln('Staff,Transactions,Revenue');
    for (final s in report.staffPerformance) {
      buffer.writeln(
        '${_csv(s.staffName)},${s.transactionCount},${_currency.format(s.revenue)}',
      );
    }
    await _save(context, buffer.toString(), 'sales_report');
  }

  static Future<void> exportInventory({
    required BuildContext context,
    required InventoryReport report,
  }) async {
    final buffer = StringBuffer();
    buffer.writeln('Inventory Report');
    buffer.writeln('KPI,Value');
    buffer.writeln('Total Products,${report.totalProducts}');
    buffer.writeln('In Stock,${report.inStockCount}');
    buffer.writeln('Low Stock,${report.lowStockCount}');
    buffer.writeln('Out of Stock,${report.outOfStockCount}');
    buffer.writeln('Expired Lots,${report.expiredCount}');
    buffer.writeln('Near Expiration,${report.nearExpirationCount}');
    buffer.writeln(
      'Inventory Value,${_currency.format(report.totalInventoryValue)}',
    );
    buffer.writeln();
    buffer.writeln('Low Stock Items');
    buffer.writeln('Product,Category,Current,Threshold');
    for (final item in report.lowStockItems) {
      buffer.writeln(
        '${_csv(item.productName)},${_csv(item.categoryName)},'
        '${item.currentStock},${item.threshold}',
      );
    }
    await _save(context, buffer.toString(), 'inventory_report');
  }

  static Future<void> exportMembership({
    required BuildContext context,
    required MembershipReport report,
    required ReportPeriodSelection period,
  }) async {
    final buffer = StringBuffer();
    buffer.writeln('Members & Memberships Report');
    buffer.writeln('Period,${period.displayName}');
    buffer.writeln('Range,${period.displayRangeLabel}');
    buffer.writeln();
    buffer.writeln('KPI,Value');
    buffer.writeln('New Members,${report.totalNewMembers}');
    buffer.writeln('Active Memberships,${report.activeMemberships}');
    buffer.writeln('New Subscriptions,${report.newSubscriptions}');
    buffer.writeln('Renewals,${report.renewals}');
    buffer.writeln('Expiring Soon (7d),${report.expiringSoonCount}');
    buffer.writeln('Lapsed,${report.lapsedCount}');
    buffer.writeln(
      'Plan Value Sold,${_currency.format(report.membershipRevenue)}',
    );
    buffer.writeln(
      'Add-on Value Sold,${_currency.format(report.addOnRevenue)}',
    );
    buffer.writeln();
    buffer.writeln('Plan Distribution');
    buffer.writeln('Plan,Count');
    for (final e in report.membershipPlanDistribution.entries) {
      buffer.writeln('${_csv(e.key)},${e.value}');
    }
    await _save(context, buffer.toString(), 'membership_report');
  }

  static Future<void> exportAttendance({
    required BuildContext context,
    required AttendanceReport report,
    required ReportPeriodSelection period,
  }) async {
    final buffer = StringBuffer();
    buffer.writeln('Attendance Report');
    buffer.writeln('Period,${period.displayName}');
    buffer.writeln('Range,${period.displayRangeLabel}');
    buffer.writeln();
    buffer.writeln('KPI,Value');
    buffer.writeln('Total Check-ins,${report.totalCheckIns}');
    buffer.writeln('Unique Members,${report.uniqueMembers}');
    buffer.writeln(
      'Without Membership Link,${report.withoutActiveMembershipCount}',
    );
    buffer.writeln();
    buffer.writeln('Check-ins Trend');
    buffer.writeln('Bucket,Count');
    for (final d in report.checkInsTrend) {
      buffer.writeln('${_csv(d.label)},${d.value}');
    }
    buffer.writeln();
    buffer.writeln('By Method');
    buffer.writeln('Method,Count');
    for (final e in report.checkInsByMethod.entries) {
      buffer.writeln('${e.key},${e.value}');
    }
    await _save(context, buffer.toString(), 'attendance_report');
  }

  static String _csv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  static Future<void> _save(
    BuildContext context,
    String csv,
    String baseName,
  ) async {
    try {
      await PermissionService.ensureStoragePermissions();
    } on PermissionDeniedException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
      return;
    }

    final stamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final bytes = Uint8List.fromList(utf8.encode(csv));
    final filename = '${baseName}_$stamp';

    if (kIsWeb) {
      await FileSaver.instance.saveFile(
        name: filename,
        bytes: bytes,
        fileExtension: 'csv',
        mimeType: MimeType.csv,
      );
    } else {
      await FileSaver.instance.saveAs(
        name: filename,
        bytes: bytes,
        fileExtension: 'csv',
        mimeType: MimeType.csv,
      );
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CSV exported')),
      );
    }
  }
}
