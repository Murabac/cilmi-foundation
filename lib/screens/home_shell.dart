import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../screens/contributions/contribution_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/tree/family_tree_screen.dart';
import '../theme/app_theme.dart';
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
        // Keep current Bixi visibility: adult members (exempt still see the tab).
        final showGive = profile?.demographic == Demographic.adult;

        // Fixed layout: Hoyga · Qoyska · [Bixi] · Aniga.
        // Tree is always index 1 — used by Profile → View in tree.
        const treeTabIndex = 1;
        final profileTabIndex = showGive ? 3 : 2;

        final giveTabIndex = showGive ? 2 : null;

        final tabs = <Widget>[
          DashboardScreen(
            onOpenGive: giveTabIndex == null
                ? null
                : () => setState(() => _index = giveTabIndex),
            onOpenTree: () => setState(() => _index = treeTabIndex),
            onOpenPaymentHistory: giveTabIndex == null
                ? () => Navigator.pushNamed(context, '/payments-report')
                : () => setState(() => _index = giveTabIndex),
          ),
          const FamilyTreeScreen(),
          if (showGive) const ContributionScreen(),
          ProfileScreen(
            showAppBar: false,
            onViewInTree: () => setState(() => _index = treeTabIndex),
          ),
        ];

        final items = <_NavItem>[
          _NavItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
            label: l10n.t('nav_home'),
          ),
          _NavItem(
            icon: Icons.account_tree_outlined,
            selectedIcon: Icons.account_tree_rounded,
            label: l10n.t('nav_family'),
          ),
          if (showGive)
            _NavItem(
              icon: Icons.account_balance_wallet_outlined,
              selectedIcon: Icons.account_balance_wallet_rounded,
              label: l10n.t('nav_give'),
            ),
          _NavItem(
            icon: Icons.person_outline_rounded,
            selectedIcon: Icons.person_rounded,
            label: l10n.t('nav_me'),
            useAvatar: true,
          ),
        ];

        if (_index >= tabs.length) _index = 0;
        // If Bixi disappeared (role/demographic change), clamp off that index.
        if (!showGive && _index >= profileTabIndex) {
          _index = profileTabIndex;
        }

        // All four tabs draw their own headers — no shell AppBar.
        return Scaffold(
          extendBody: true,
          backgroundColor: BrandColors.linen,
          body: Padding(
            // Floating bar (72) + SafeArea inset + outer pad (16) + breathing room.
            padding: const EdgeInsets.only(bottom: 120),
            child: IndexedStack(index: _index, children: tabs),
          ),
          bottomNavigationBar: _FloatingTealNavBar(
            items: items,
            selectedIndex: _index,
            profile: profile,
            onSelect: (i) => setState(() => _index = i),
          ),
        );
      },
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.useAvatar = false,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool useAvatar;
}

/// Floating teal bar: inset 14/16, height 72, radius 26, gold active tile.
class _FloatingTealNavBar extends StatelessWidget {
  const _FloatingTealNavBar({
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
    this.profile,
  });

  final List<_NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final Profile? profile;

  // Slightly stronger than design #BFD9D4 for elder contrast on teal.
  static const _inactive = Color(0xFFD2E6E2);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: 72,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: BrandColors.teal,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              boxShadow: [
                BoxShadow(
                  color: BrandColors.teal.withValues(alpha: 0.38),
                  blurRadius: 36,
                  offset: const Offset(0, 16),
                ),
                BoxShadow(
                  color: BrandColors.teal.withValues(alpha: 0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    flex: i == selectedIndex ? 5 : 4,
                    child: _NavTile(
                      item: items[i],
                      selected: i == selectedIndex,
                      profile: profile,
                      onTap: () => onSelect(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.item,
    required this.selected,
    required this.onTap,
    this.profile,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;
  final Profile? profile;

  @override
  Widget build(BuildContext context) {
    final color =
        selected ? BrandColors.onGold : _FloatingTealNavBar._inactive;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          height: 60,
          decoration: BoxDecoration(
            color: selected ? BrandColors.gold : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: BrandColors.gold.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (item.useAvatar)
                _NavProfileIcon(
                  profile: profile,
                  selected: selected,
                  color: color,
                )
              else
                Icon(
                  selected ? item.selectedIcon : item.icon,
                  size: 23,
                  color: color,
                ),
              const SizedBox(height: 3),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                  color: color,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom-nav profile icon: photo when available, otherwise a person icon.
class _NavProfileIcon extends StatelessWidget {
  const _NavProfileIcon({
    required this.profile,
    required this.selected,
    required this.color,
  });

  final Profile? profile;
  final bool selected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = profile?.avatarUrl?.trim();
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

    if (hasAvatar) {
      return Container(
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? BrandColors.onGold : color,
            width: 1.5,
          ),
        ),
        child: CircleAvatar(
          radius: 10,
          backgroundColor: BrandColors.mint,
          backgroundImage: NetworkImage(avatarUrl),
          onBackgroundImageError: (_, _) {},
        ),
      );
    }

    return Icon(
      selected ? Icons.person_rounded : Icons.person_outline_rounded,
      size: 23,
      color: color,
    );
  }
}
