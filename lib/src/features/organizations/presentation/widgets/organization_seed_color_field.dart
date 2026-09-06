import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'
    hide colorFromHex, colorToHex;
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/packages/theme/app_themes.dart';
import '../../../../core/utils/color_utils.dart';

/// Seed color field with a color picker dialog and optional hex input.
class OrganizationSeedColorField extends HookWidget {
  const OrganizationSeedColorField({
    super.key,
    required this.name,
    this.initialValue,
    this.enabled = true,
  });

  final String name;
  final String? initialValue;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final normalizedInitial = normalizeHexColor(initialValue);

    return FormBuilderField<String?>(
      name: name,
      initialValue: normalizedInitial,
      validator: (value) {
        final trimmed = value?.trim() ?? '';
        if (trimmed.isEmpty) return null;
        if (normalizeHexColor(trimmed) == null) {
          return t.organizations.seedColorValidationError;
        }
        return null;
      },
      builder: (field) {
        final selectedHex = normalizeHexColor(field.value);
        final selectedColor = colorFromHex(selectedHex);

        return InputDecorator(
          decoration: InputDecoration(
            labelText: t.organizations.seedColor,
            helperText: t.organizations.seedColorHelper,
            border: const OutlineInputBorder(),
            errorText: field.errorText,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  _ColorPickerButton(
                    color: selectedColor,
                    enabled: enabled,
                    tooltip: t.organizations.seedColorPick,
                    onPressed: () async {
                      final picked = await _showSeedColorPickerDialog(
                        context,
                        initialColor:
                            selectedColor ?? AppThemes.defaultSeedColor,
                      );
                      if (picked != null) {
                        field.didChange(colorToHex(picked));
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      key: ValueKey(selectedHex),
                      initialValue: selectedHex ?? '',
                      enabled: enabled,
                      decoration: InputDecoration(
                        hintText: '#1E88E5',
                        border: const OutlineInputBorder(),
                        isDense: true,
                        suffixIcon: selectedHex != null
                            ? IconButton(
                                tooltip: t.organizations.seedColorClear,
                                icon: const Icon(Icons.clear),
                                onPressed: enabled
                                    ? () => field.didChange(null)
                                    : null,
                              )
                            : null,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[#0-9A-Fa-f]'),
                        ),
                      ],
                      onChanged: (value) {
                        final trimmed = value.trim();
                        field.didChange(trimmed.isEmpty ? null : trimmed);
                      },
                    ),
                  ),
                ],
              ),
              if (selectedHex != null) ...[
                const SizedBox(height: 12),
                _SeedColorPreview(hex: selectedHex),
              ],
            ],
          ),
        );
      },
    );
  }
}

Future<Color?> _showSeedColorPickerDialog(
  BuildContext context, {
  required Color initialColor,
}) {
  final t = Translations.of(context);
  final localizations = MaterialLocalizations.of(context);
  var pickerColor = initialColor;

  return showDialog<Color>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(t.organizations.seedColor),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: pickerColor,
                onColorChanged: (color) {
                  setState(() => pickerColor = color);
                },
                enableAlpha: false,
                displayThumbColor: true,
                hexInputBar: true,
                labelTypes: const [],
                pickerAreaHeightPercent: 0.7,
                portraitOnly: true,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(localizations.cancelButtonLabel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, pickerColor),
                child: Text(localizations.okButtonLabel),
              ),
            ],
          );
        },
      );
    },
  );
}

class _ColorPickerButton extends StatelessWidget {
  const _ColorPickerButton({
    required this.color,
    required this.enabled,
    required this.tooltip,
    required this.onPressed,
  });

  final Color? color;
  final bool enabled;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: color ?? theme.colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: theme.colorScheme.outline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          child: SizedBox(
            width: 48,
            height: 48,
            child: color == null
                ? Icon(
                    Icons.palette_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class _SeedColorPreview extends StatelessWidget {
  const _SeedColorPreview({required this.hex});

  final String hex;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final seedColor = colorFromHex(hex)!;
    final previewTheme = ThemeData(
      colorScheme: colorSchemeFromSeed(
        seedColor: seedColor,
        brightness: Theme.of(context).brightness,
      ),
      useMaterial3: true,
    );

    return Theme(
      data: previewTheme,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                key: const Key('seed_color_preview_swatch'),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: seedColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${t.organizations.seedColorPreview}: $hex',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              FilledButton(
                onPressed: null,
                child: Text(t.organizations.seedColorPreviewButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
