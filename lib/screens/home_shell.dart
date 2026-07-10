import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../screens/contributions/contribution_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
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
      error: (_, __) => const Scaffold(body: Center(child: Text('Error'))),
      data: (l10n) {
        final profile = profileAsync.valueOrNull;
        final isAdmin = profile?.role.isAdminOrManager ?? false;
        final isAdult = profile?.demographic == Demographic.adult;

        final tabs = <Widget>[
          const DashboardScreen(),
          const FamilyTreeScreen(),
          if (isAdult) const ContributionScreen(),
          if (profile?.role == UserRole.superAdmin) const AdminSettingsScreen(),
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
          if (isAdult)
            NavigationDestination(
              icon: const Icon(Icons.payments_outlined),
              selectedIcon: const Icon(Icons.payments),
              label: l10n.t('contributions'),
            ),
          if (profile?.role == UserRole.superAdmin)
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: l10n.t('settings'),
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
              if (isAdmin)
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
              if (isAdmin)
                IconButton(
                  icon: const Icon(Icons.receipt_long_outlined),
                  tooltip: l10n.t('payment_report'),
                  onPressed: () => Navigator.pushNamed(context, '/payments-report'),
                ),
              if (isAdmin)
                IconButton(
                  icon: const Icon(Icons.verified_user_outlined),
                  tooltip: l10n.t('verification_queue'),
                  onPressed: () => Navigator.pushNamed(context, '/verification'),
                ),
              if (isAdmin)
                IconButton(
                  icon: const Icon(Icons.account_balance_wallet_outlined),
                  tooltip: l10n.t('treasury'),
                  onPressed: () => Navigator.pushNamed(context, '/treasury'),
                ),
              IconButton(
                icon: CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    profile?.fullName.isNotEmpty == true
                        ? profile!.fullName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                tooltip: l10n.t('my_profile'),
                onPressed: () => Navigator.pushNamed(context, '/profile'),
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
            destinations: destinations,
          ),
        );
      },
    );
  }
}
