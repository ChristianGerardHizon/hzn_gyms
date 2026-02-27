import 'package:dart_mappable/dart_mappable.dart';

part 'order_status.mapper.dart';

/// Status of an order in the fulfillment workflow.
@MappableEnum()
enum OrderStatus {
  pending,
  ready;

  String get displayName => switch (this) {
        OrderStatus.pending => 'Pending',
        OrderStatus.ready => 'Ready',
      };

  /// Returns the icon for this order status.
  String get iconName => switch (this) {
        OrderStatus.pending => 'schedule',
        OrderStatus.ready => 'check_circle',
      };
}
