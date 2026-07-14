import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/widgets/state/error_state.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../users/presentation/controllers/user_provider.dart';
import '../../../users/presentation/widgets/tabs/user_overview_tab.dart';
import '../widgets/edit_profile_dialog.dart';

/// Shows the signed-in user's profile with a restricted self-edit action.
class ProfilePage extends HookConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final auth = ref.watch(currentAuthProvider);
    final userId = auth?.user.id;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Not signed in')),
      );
    }

    final userAsync = ref.watch(userProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: Text(t.navigation.profile),
        actions: [
          userAsync.maybeWhen(
            data: (user) {
              if (user == null) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit profile',
                onPressed: () => showEditProfileDialog(context, user: user),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorState.fromError(
          error,
          onRetry: () => ref.invalidate(userProvider(userId)),
        ),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User not found'));
          }
          return Column(
            children: [
              Expanded(child: UserOverviewTab(user: user)),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () =>
                          showEditProfileDialog(context, user: user),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Profile'),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
