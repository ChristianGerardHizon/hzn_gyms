import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/utils/breakpoints.dart';
import '../domain/pos_group.dart';
import 'components/cashier_body.dart';
import 'components/cashier_cart_bar.dart';
import 'controllers/pos_groups_controller.dart';
import 'cart_controller.dart';

class PosScreen extends HookConsumerWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldKey = useMemoized(() => GlobalKey<ScaffoldState>());

    final posGroupsAsync = ref.watch(posGroupsControllerProvider);
    final groups = posGroupsAsync.value ?? [];
    final hasGroups = groups.isNotEmpty;

    final isMobile = Breakpoints.isMobile(context);

    return isMobile
        ? _MobileLayout(
            scaffoldKey: scaffoldKey,
            hasGroups: hasGroups,
            groups: groups,
          )
        : _DesktopLayout(
            hasGroups: hasGroups,
            groups: groups,
          );
  }
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({
    required this.hasGroups,
    required this.groups,
  });

  final bool hasGroups;
  final List<PosGroup> groups;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cashier'),
      ),
      body: CashierBody(
        hasGroups: hasGroups,
        groups: groups,
      ),
    );
  }
}

class _MobileLayout extends ConsumerWidget {
  const _MobileLayout({
    required this.scaffoldKey,
    required this.hasGroups,
    required this.groups,
  });

  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool hasGroups;
  final List<PosGroup> groups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemCount =
        ref.watch(cartControllerProvider).value?.totalItemCount ?? 0;

    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Cashier'),
        actions: [
          IconButton(
            tooltip: 'Open cart',
            onPressed: () => CashierCartBar.showCartSheet(context),
            icon: Badge(
              isLabelVisible: itemCount > 0,
              label: Text('$itemCount'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
          ),
        ],
      ),
      body: CashierBody(
        hasGroups: hasGroups,
        groups: groups,
        isMobile: true,
        compactSearch: true,
        bottomPaddingForNav: true,
      ),
    );
  }
}
