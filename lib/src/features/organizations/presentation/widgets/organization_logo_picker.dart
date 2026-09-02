import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/assets/assets.gen.dart';
import '../../../../core/i18n/strings.g.dart';
import '../../domain/organization_logo_draft.dart';

/// Picks and previews an organization logo before save.
class OrganizationLogoPicker extends HookWidget {
  const OrganizationLogoPicker({
    super.key,
    this.existingLogoUrl,
    this.enabled = true,
    required this.onChanged,
  });

  final String? existingLogoUrl;
  final bool enabled;
  final ValueChanged<OrganizationLogoDraft?> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final previewBytes = useState<Uint8List?>(null);
    final previewFilename = useState<String?>(null);
    final removedExisting = useState(false);

    void notifyChanged() {
      if (previewBytes.value != null) {
        onChanged(
          OrganizationLogoDraft.upload(
            bytes: previewBytes.value!,
            filename: previewFilename.value ?? 'logo.png',
          ),
        );
        return;
      }
      if (removedExisting.value) {
        onChanged(const OrganizationLogoDraft.remove());
        return;
      }
      onChanged(null);
    }

    Future<void> pickLogo() async {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90,
      );
      if (image == null) return;

      previewBytes.value = await image.readAsBytes();
      previewFilename.value = image.name;
      removedExisting.value = false;
      notifyChanged();
    }

    void clearLogo() {
      previewBytes.value = null;
      previewFilename.value = null;
      removedExisting.value =
          existingLogoUrl != null && existingLogoUrl!.isNotEmpty;
      notifyChanged();
    }

    final showExisting =
        !removedExisting.value &&
        previewBytes.value == null &&
        existingLogoUrl != null &&
        existingLogoUrl!.isNotEmpty;

    final fallback = Assets.icons.appIconTransparent.image(
      width: 96,
      height: 96,
      fit: BoxFit.contain,
    );

    Widget preview;
    if (previewBytes.value != null) {
      preview = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          previewBytes.value!,
          width: 96,
          height: 96,
          fit: BoxFit.contain,
        ),
      );
    } else if (showExisting) {
      preview = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: existingLogoUrl!,
          width: 96,
          height: 96,
          fit: BoxFit.contain,
          placeholder: (_, __) => fallback,
          errorWidget: (_, __, ___) => fallback,
        ),
      );
    } else {
      preview = DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: SizedBox(
          width: 96,
          height: 96,
          child: Icon(
            Icons.apartment_outlined,
            size: 40,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final hasLogo = previewBytes.value != null || showExisting;

    return InputDecorator(
      decoration: InputDecoration(
        labelText: t.organizations.logo,
        helperText: t.organizations.logoHelper,
        border: const OutlineInputBorder(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              preview,
              const SizedBox(width: 16),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: enabled ? pickLogo : null,
                      icon: const Icon(Icons.upload_file),
                      label: Text(
                        hasLogo
                            ? t.organizations.logoReplace
                            : t.organizations.logoUpload,
                      ),
                    ),
                    if (hasLogo)
                      TextButton.icon(
                        onPressed: enabled ? clearLogo : null,
                        icon: const Icon(Icons.delete_outline),
                        label: Text(t.organizations.logoRemove),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
