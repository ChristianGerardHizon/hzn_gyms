import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_gyms/src/features/products/presentation/widgets/dialogs/product_form_preset.dart';

void main() {
  group('flagsForPreset', () {
    test('fixedPrice enables price only', () {
      final flags = flagsForPreset(ProductFormPreset.fixedPrice);
      expect(flags.priceEnabled, isTrue);
      expect(flags.stockEnabled, isFalse);
    });

    test('withStock enables price and stock', () {
      final flags = flagsForPreset(ProductFormPreset.withStock);
      expect(flags.priceEnabled, isTrue);
      expect(flags.stockEnabled, isTrue);
    });

    test('variablePrice disables price and stock', () {
      final flags = flagsForPreset(ProductFormPreset.variablePrice);
      expect(flags.priceEnabled, isFalse);
      expect(flags.stockEnabled, isFalse);
    });
  });

  group('presetFromFlags', () {
    test('fixed only', () {
      expect(
        presetFromFlags(isVariablePrice: false, trackStock: false),
        ProductFormPreset.fixedPrice,
      );
    });

    test('with stock', () {
      expect(
        presetFromFlags(isVariablePrice: false, trackStock: true),
        ProductFormPreset.withStock,
      );
    });

    test('variable only', () {
      expect(
        presetFromFlags(isVariablePrice: true, trackStock: false),
        ProductFormPreset.variablePrice,
      );
    });

    test('variable with stock is custom', () {
      expect(
        presetFromFlags(isVariablePrice: true, trackStock: true),
        ProductFormPreset.custom,
      );
    });
  });
}
