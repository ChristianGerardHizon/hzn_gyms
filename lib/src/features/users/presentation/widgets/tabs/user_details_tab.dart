import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../../../core/widgets/form_feedback.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../domain/user.dart';
import '../../controllers/user_provider.dart';
import '../dialogs/edit_user_dialog.dart';
import '../user_avatar.dart';

/// Details tab content showing comprehensive user information.
class UserDetailsTab extends HookConsumerWidget {
  const UserDetailsTab({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isUploading = useState(false);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main user card with avatar and key info
          _buildUserCard(context, theme, ref, isUploading),
          const SizedBox(height: 16),

          // User details section
          _buildUserDetailsSection(theme),
          const SizedBox(height: 24),

          // Quick actions
          _buildQuickActions(context, theme),
        ],
      ),
    );
  }

  Widget _buildUserCard(
    BuildContext context,
    ThemeData theme,
    WidgetRef ref,
    ValueNotifier<bool> isUploading,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Avatar with camera overlay
            _buildAvatar(context, theme, ref, isUploading, radius: 48),
            const SizedBox(width: 20),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${user.username}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.displayRole,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(
    BuildContext context,
    ThemeData theme,
    WidgetRef ref,
    ValueNotifier<bool> isUploading, {
    double radius = 36,
  }) {
    return Stack(
      children: [
        UserAvatar(
          user: user,
          radius: radius,
        ),
        // Camera overlay button
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: isUploading.value
                ? null
                : () => _pickAndUploadImage(context, ref, isUploading),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.surface,
                  width: 2,
                ),
              ),
              child: isUploading.value
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: theme.colorScheme.onPrimary,
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickAndUploadImage(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<bool> isUploading,
  ) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (image == null) return;

    isUploading.value = true;

    try {
      final bytes = await image.readAsBytes();
      final file = http.MultipartFile.fromBytes(
        'avatar',
        bytes,
        filename: image.name,
      );

      final repository = ref.read(userRepositoryProvider);
      final result = await repository.updateAvatar(user.id, file);

      result.fold(
        (failure) {
          if (context.mounted) {
            showErrorSnackBar(context, message: failure.message);
          }
        },
        (updatedUser) {
          // Invalidate the user provider to refresh data
          ref.invalidate(userProvider(user.id));
          if (context.mounted) {
            showSuccessSnackBar(context, message: 'Photo updated successfully');
          }
        },
      );
    } catch (e) {
      if (context.mounted) {
        showErrorSnackBar(context, message: 'Failed to upload photo');
      }
    } finally {
      isUploading.value = false;
    }
  }

  Widget _buildUserDetailsSection(ThemeData theme) {
    final items = <_DetailItem>[
      _DetailItem(
        icon: Icons.person,
        label: 'Name',
        value: user.name,
      ),
      _DetailItem(
        icon: Icons.alternate_email,
        label: 'Username',
        value: user.username,
      ),
      _DetailItem(
        icon: Icons.admin_panel_settings,
        label: 'Role',
        value: user.displayRole,
      ),
      _DetailItem(
        icon: Icons.business,
        label: 'Branch',
        value: user.displayBranch,
      ),
      _DetailItem(
        icon: Icons.verified_user,
        label: 'Account Status',
        value: user.verificationStatus,
      ),
      _DetailItem(
        icon: Icons.toggle_on,
        label: 'Account Status',
        value: user.isDeleted ? 'Deleted' : 'Active',
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'User Details',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...items.map((item) => _buildDetailRow(item, theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(_DetailItem item, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            item.icon,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: () => _showEditUserDialog(context),
              icon: const Icon(Icons.edit),
              label: const Text('Edit Details'),
            ),
            FilledButton.tonalIcon(
              onPressed: () {
                showWarningSnackBar(context, message: 'Reset password coming soon');
              },
              icon: const Icon(Icons.lock_reset),
              label: const Text('Reset Password'),
            ),
          ],
        ),
      ],
    );
  }

  void _showEditUserDialog(BuildContext context) {
    showEditUserDialog(context, user);
  }
}

class _DetailItem {
  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}
