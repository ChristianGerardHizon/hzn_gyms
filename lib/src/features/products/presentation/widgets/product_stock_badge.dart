import 'package:flutter/material.dart';

import '../../domain/product_status.dart';

/// Badge widget displaying the product's stock status.
class ProductStockBadge extends StatelessWidget {
  const ProductStockBadge({
    super.key,
    required this.status,
    this.showLabel = true,
  });

  final ProductStatus status;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _getStatusStyle(context);

    if (!showLabel) {
      return Tooltip(
        message: status.displayName,
        child: Icon(icon, color: color, size: 16),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  (Color, IconData) _getStatusStyle(BuildContext context) {
    final theme = Theme.of(context);

    switch (status) {
      case ProductStatus.inStock:
        return (Colors.green, Icons.check_circle_outline);
      case ProductStatus.outOfStock:
        return (theme.colorScheme.error, Icons.cancel_outlined);
      case ProductStatus.lowStock:
        return (Colors.orange, Icons.warning_amber_outlined);
      case ProductStatus.noThreshold:
        return (theme.colorScheme.outline, Icons.help_outline);
    }
  }
}
