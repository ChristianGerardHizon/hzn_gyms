import 'package:flutter/material.dart';

/// UI-only create/edit product setup presets (not persisted).
enum ProductFormPreset {
  fixedPrice,
  withStock,
  variablePrice,
  custom,
}

extension ProductFormPresetX on ProductFormPreset {
  String get label => switch (this) {
        ProductFormPreset.fixedPrice => 'Fixed price',
        ProductFormPreset.withStock => 'With stock',
        ProductFormPreset.variablePrice => 'Variable price',
        ProductFormPreset.custom => 'Custom',
      };

  IconData get icon => switch (this) {
        ProductFormPreset.fixedPrice => Icons.sell_outlined,
        ProductFormPreset.withStock => Icons.inventory_2_outlined,
        ProductFormPreset.variablePrice => Icons.edit_note_outlined,
        ProductFormPreset.custom => Icons.tune,
      };
}

/// Price/stock flags implied by a non-custom preset.
({bool priceEnabled, bool stockEnabled}) flagsForPreset(
  ProductFormPreset preset,
) {
  return switch (preset) {
    ProductFormPreset.fixedPrice => (
        priceEnabled: true,
        stockEnabled: false,
      ),
    ProductFormPreset.withStock => (
        priceEnabled: true,
        stockEnabled: true,
      ),
    ProductFormPreset.variablePrice => (
        priceEnabled: false,
        stockEnabled: false,
      ),
    // Custom keeps the caller's current flags; defaults unused.
    ProductFormPreset.custom => (
        priceEnabled: true,
        stockEnabled: false,
      ),
  };
}

/// Seeds the edit form preset from existing product flags.
ProductFormPreset presetFromFlags({
  required bool isVariablePrice,
  required bool trackStock,
}) {
  if (isVariablePrice && trackStock) return ProductFormPreset.custom;
  if (isVariablePrice) return ProductFormPreset.variablePrice;
  if (trackStock) return ProductFormPreset.withStock;
  return ProductFormPreset.fixedPrice;
}

/// Choice chips for [ProductFormPreset].
class ProductFormPresetPicker extends StatelessWidget {
  const ProductFormPresetPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final ProductFormPreset value;
  final ValueChanged<ProductFormPreset> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Product type',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ProductFormPreset.values.map((preset) {
            final selected = value == preset;
            return ChoiceChip(
              avatar: Icon(preset.icon, size: 18),
              label: Text(preset.label),
              selected: selected,
              showCheckmark: false,
              onSelected: !enabled
                  ? null
                  : (isSelected) {
                      if (isSelected) onChanged(preset);
                    },
            );
          }).toList(),
        ),
      ],
    );
  }
}
