import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../screens/admin/payment_report_screen.dart';
import '../screens/contributions/contribution_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/settings/admin_settings_screen.dart';
import '../screens/tree/family_tree_screen.dart';
import '../widgets/add_family_member_dialog.dart';
import '../widgets/widgets.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10nAsync = ref.watch(localizationsProvider);
    final profileAsync = ref.watch(currentProfileProvider);

    return l10nAsync.when(
      loading: () => const Scaffold(body: LoadingView()),
      error: (_, _) => const Scaffold(body: Center(child: Text('Error'))),
      data: (l10n) {
        final profile = profileAsync.valueOrNull;
        final role = profile?.role;
        final canPayments = role?.canManagePayments ?? false;
        final canTreasury = role?.canManageTreasury ?? false;
        final isSuperAdmin = role?.isSuperAdmin ?? false;
        final isAdult = profile?.demographic == Demographic.adult;

        // Tree is always index 1 — used by Profile → View in tree.
        const treeTabIndex = 1;

        final tabs = <Widget>[
          const DashboardScreen(),
          const FamilyTreeScreen(),
          if (canPayments) const PaymentReportScreen(showAppBar: false),
          if (isAdult) const ContributionScreen(),
          if (isSuperAdmin) const AdminSettingsScreen(),
          ProfileScreen(
            showAppBar: false,
            onViewInTree: () => setState(() => _index = treeTabIndex),
          ),
        ];

        final destinations = <NavigationDestination>[
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: l10n.t('dashboard'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_tree_outlined),
            selectedIcon: const Icon(Icons.account_tree),
            label: l10n.t('family_tree'),
          ),
          if (canPayments)
            NavigationDestination(
              icon: const Icon(Icons.receipt_long_outlined),
              selectedIcon: const Icon(Icons.receipt_long),
              label: l10n.t('payment_report'),
            ),
          if (isAdult)
            NavigationDestination(
              icon: const Icon(Icons.payments_outlined),
              selectedIcon: const Icon(Icons.payments),
              label: l10n.t('contributions'),
            ),
          if (isSuperAdmin)
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: l10n.t('settings'),
            ),
          NavigationDestination(
            icon: _NavProfileIcon(profile: profile, selected: false),
            selectedIcon: _NavProfileIcon(profile: profile, selected: true),
            label: l10n.t('my_profile'),
          ),
        ];

        if (_index >= tabs.length) _index = 0;

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leadingWidth: 112,
            leading: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AppLogo(height: 36),
              ),
            ),
            actions: [
              if (isSuperAdmin)
                IconButton(
                  icon: const Icon(Icons.person_add_outlined),
                  tooltip: l10n.t('add_family_member'),
                  onPressed: () async {
                    final added = await showAddFamilyMemberDialog(context, ref);
                    if (added && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.t('add_member_success'))),
                      );
                    }
                  },
                ),
              if (isSuperAdmin || canPayments)
                IconButton(
                  icon: const Icon(Icons.verified_user_outlined),
                  tooltip: l10n.t('verification_queue'),
                  onPressed: () =>
                      Navigator.pushNamed(context, '/verification'),
                ),
              if (canTreasury)
                IconButton(
                  icon: const Icon(Icons.account_balance_wallet_outlined),
                  tooltip: l10n.t('treasury'),
                  onPressed: () => Navigator.pushNamed(context, '/treasury'),
                ),
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: l10n.t('sign_out'),
                onPressed: () => ref.read(authServiceProvider).signOut(),
              ),
            ],
          ),
          body: IndexedStack(index: _index, children: tabs),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            destinations: destinations,
          ),
        );
      },
    );
  }
}

/// Bottom-nav profile icon: photo when available, otherwise a person icon.
class _NavProfileIcon extends StatelessWidget {
  const _NavProfileIcon({required this.profile, required this.selected});

  final Profile? profile;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final avatarUrl = profile?.avatarUrl?.trim();
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;
    final ringColor = selected ? scheme.primary : Colors.transparent;

    if (hasAvatar) {
      return Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: ringColor, width: 2),
        ),
        child: CircleAvatar(
          radius: 12,
          backgroundColor: scheme.primaryContainer,
          backgroundImage: NetworkImage(avatarUrl),
          onBackgroundImageError: (_, _) {},
        ),
      );
    }

    return Icon(
      selected ? Icons.person : Icons.person_outline,
    );
  }
}
