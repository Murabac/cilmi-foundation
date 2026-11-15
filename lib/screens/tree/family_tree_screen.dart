import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../models/lineage_tree.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/abtirsiin_lineage_view.dart';
import '../../widgets/add_family_member_dialog.dart';
import '../../widgets/family_tree_list_view.dart';
import '../../widgets/focused_generation_chart.dart';
import '../../widgets/member_business_card.dart';
import '../../widgets/widgets.dart';

enum _TreeSegment { geed, abtirsiin, list }

class FamilyTreeScreen extends ConsumerStatefulWidget {
  const FamilyTreeScreen({super.key});

  @override
  ConsumerState<FamilyTreeScreen> createState() => _FamilyTreeScreenState();
}

class _FamilyTreeScreenState extends ConsumerState<FamilyTreeScreen> {
  _TreeSegment _segment = _TreeSegment.geed;
  String? _focusId;
  bool _searchOpen = false;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openMemberCard(Profile profile) {
    showMemberBusinessCard(
      context,
      ref,
      profile,
      onViewBranch: (id) {
        setState(() {
          _focusId = id;
          _segment = _TreeSegment.geed;
        });
      },
    );
  }

  String _resolveFocusId(TreeNode root, Profile? me) {
    if (_focusId != null && findNodeInTree(root, _focusId!) != null) {
      return _focusId!;
    }
    if (me != null && findNodeInTree(root, me.id) != null) {
      return me.id;
    }
    return root.profile.id;
  }

  List<Profile> _collectProfiles(TreeNode node) {
    final profiles = <Profile>[node.profile];
    for (final child in node.children) {
      profiles.addAll(_collectProfiles(child));
    }
    return profiles;
  }

  List<Profile> _ancestorChain(TreeNode root, String focusId) {
    final byId = {
      for (final p in _collectProfiles(root)) p.id: p,
    };
    final focus = byId[focusId];
    if (focus == null) return const [];

    final upward = <Profile>[];
    Profile? current = focus;
    final visited = <String>{};
    while (current != null && !visited.contains(current.id)) {
      visited.add(current.id);
      upward.add(current);
      final fatherId = current.fatherId;
      current = fatherId == null ? null : byId[fatherId];
    }
    return upward.reversed.toList();
  }

  List<Profile> _searchMatches(TreeNode root) {
    final q = _searchQuery.trim();
    if (q.isEmpty) return const [];
    return _collectProfiles(root)
        .where((p) => profileNameMatchesSearch(p, q))
        .take(12)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10nAsync = ref.watch(localizationsProvider);
    final treeAsync = ref.watch(fullLineageTreeProvider);
    final countAsync = ref.watch(memberCountProvider);
    final profileAsync = ref.watch(currentProfileProvider);
    final isAdmin = profileAsync.valueOrNull?.role.canManageCare ?? false;

    return l10nAsync.when(
      loading: () => const LoadingView(),
      error: (_, _) => const ErrorView(message: 'Error'),
      data: (l10n) => treeAsync.when(
        loading: () => LoadingView(message: l10n.t('loading_family_tree')),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(fullLineageTreeProvider),
        ),
        data: (root) {
          if (root == null) {
            return ErrorView(
              message: l10n.t('no_family_tree_data'),
              onRetry: () => ref.invalidate(fullLineageTreeProvider),
            );
          }

          final me = profileAsync.valueOrNull;
          final focusId = _resolveFocusId(root, me);
          final memberCount = countAsync.valueOrNull ?? countTreeMembers(root);
          final chain = _ancestorChain(root, focusId);
          final matches = _searchOpen ? _searchMatches(root) : const <Profile>[];

          return ColoredBox(
            color: BrandColors.linen,
            child: RefreshIndicator(
              color: BrandColors.teal,
              onRefresh: () async {
                ref.invalidate(fullLineageTreeProvider);
                ref.invalidate(memberCountProvider);
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _TreeHeader(
                      l10n: l10n,
                      subtitle: _segment == _TreeSegment.abtirsiin
                          ? l10n.t('abtirsiin_header_subtitle')
                          : l10n
                              .t('family_tree_subtitle')
                              .replaceAll('{count}', '$memberCount'),
                      searchOpen: _searchOpen,
                      searchCtrl: _searchCtrl,
                      onToggleSearch: () {
                        setState(() {
                          _searchOpen = !_searchOpen;
                          if (!_searchOpen) {
                            _searchCtrl.clear();
                            _searchQuery = '';
                          }
                        });
                      },
                      onSearchChanged: (v) =>
                          setState(() => _searchQuery = v),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 40),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _SegmentControl(
                          l10n: l10n,
                          selected: _segment,
                          onChanged: (s) => setState(() => _segment = s),
                        ),
                        if (_searchOpen && _searchQuery.trim().isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _SearchResults(
                            matches: matches,
                            onPick: (p) {
                              setState(() {
                                _focusId = p.id;
                                _segment = _TreeSegment.geed;
                                _searchOpen = false;
                                _searchCtrl.clear();
                                _searchQuery = '';
                              });
                              _openMemberCard(p);
                            },
                          ),
                        ],
                        if (_segment == _TreeSegment.geed) ...[
                          const SizedBox(height: 12),
                          _LineageBreadcrumb(
                            chain: chain,
                            onTap: (p) {
                              setState(() {
                                _focusId = p.id;
                                _segment = _TreeSegment.geed;
                              });
                            },
                          ),
                        ],
                        const SizedBox(height: 12),
                        if (isAdmin)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: FilledButton.tonalIcon(
                              onPressed: () async {
                                final added = await showAddFamilyMemberDialog(
                                  context,
                                  ref,
                                );
                                if (added && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text(l10n.t('add_member_success')),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.person_add_outlined),
                              label: Text(l10n.t('add_family_member')),
                            ),
                          ),
                        if (_segment == _TreeSegment.geed) ...[
                          FocusedGenerationChart(
                            root: root,
                            focusId: focusId,
                            l10n: l10n,
                            viewerId: me?.id,
                            onMemberTap: _openMemberCard,
                            onFocusChange: (id) =>
                                setState(() => _focusId = id),
                          ),
                          const SizedBox(height: 12),
                          _CareLegend(l10n: l10n),
                          const SizedBox(height: 6),
                          Text(
                            l10n.t('tree_tap_hint'),
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: BrandColors.muted,
                            ),
                          ),
                        ] else if (_segment == _TreeSegment.abtirsiin) ...[
                          AbtirsiinLineageView(
                            root: root,
                            focusId: focusId,
                            viewerId: me?.id,
                            l10n: l10n,
                            onFocusChange: (id) =>
                                setState(() => _focusId = id),
                            onViewInTree: (id) => setState(() {
                              _focusId = id;
                              _segment = _TreeSegment.geed;
                            }),
                            onMemberTap: _openMemberCard,
                          ),
                        ] else ...[
                          FamilyTreeListView(
                            root: root,
                            l10n: l10n,
                            onMemberTap: (p) {
                              setState(() => _focusId = p.id);
                              _openMemberCard(p);
                            },
                          ),
                        ],
                        const SizedBox(height: 32),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TreeHeader extends StatelessWidget {
  const _TreeHeader({
    required this.l10n,
    required this.subtitle,
    required this.searchOpen,
    required this.searchCtrl,
    required this.onToggleSearch,
    required this.onSearchChanged,
  });

  final AppLocalizations l10n;
  final String subtitle;
  final bool searchOpen;
  final TextEditingController searchCtrl;
  final VoidCallback onToggleSearch;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      width: double.infinity,
      color: BrandColors.teal,
      padding: EdgeInsets.fromLTRB(20, top + 12, 12, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.t('geedka_qoyska'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: BrandColors.linen,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        color: BrandColors.onTealMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onToggleSearch,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: BrandColors.linen.withValues(alpha: 0.28),
                      ),
                    ),
                    child: Icon(
                      searchOpen ? Icons.close_rounded : Icons.search_rounded,
                      color: BrandColors.linen,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (searchOpen) ...[
            const SizedBox(height: 12),
            TextField(
              controller: searchCtrl,
              onChanged: onSearchChanged,
              autofocus: true,
              style: const TextStyle(color: BrandColors.ink),
              decoration: InputDecoration(
                hintText: l10n.t('search_members'),
                filled: true,
                fillColor: BrandColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SegmentControl extends StatelessWidget {
  const _SegmentControl({
    required this.l10n,
    required this.selected,
    required this.onChanged,
  });

  final AppLocalizations l10n;
  final _TreeSegment selected;
  final ValueChanged<_TreeSegment> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget tab(_TreeSegment value, String label) {
      final active = selected == value;
      return Expanded(
        child: Material(
          color: active ? BrandColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          elevation: active ? 1 : 0,
          shadowColor: BrandColors.teal.withValues(alpha: 0.12),
          child: InkWell(
            onTap: () => onChanged(value),
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 42,
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: active ? BrandColors.teal : BrandColors.muted,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: BrandColors.border,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          tab(_TreeSegment.geed, l10n.t('tree_tab_geed')),
          tab(_TreeSegment.abtirsiin, l10n.t('tree_tab_abtirsiin')),
          tab(_TreeSegment.list, l10n.t('tree_tab_list')),
        ],
      ),
    );
  }
}

class _LineageBreadcrumb extends StatelessWidget {
  const _LineageBreadcrumb({
    required this.chain,
    required this.onTap,
  });

  final List<Profile> chain;
  final ValueChanged<Profile> onTap;

  String _chipLabel(Profile p) {
    final parts = p.fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].length + parts[1].length <= 16) {
      return '${parts[0]} ${parts[1]}';
    }
    return parts.first;
  }

  @override
  Widget build(BuildContext context) {
    if (chain.isEmpty) return const SizedBox.shrink();

    // Patriarch · … · recent ancestors · focus (gold).
    final chips = <Object>[];
    if (chain.length <= 5) {
      chips.addAll(chain);
    } else {
      chips.add(chain.first);
      chips.add('…');
      chips.addAll(chain.sublist(chain.length - 3));
    }

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: 12),
        itemCount: chips.length,
        separatorBuilder: (_, _) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            Icons.chevron_right_rounded,
            size: 16,
            color: BrandColors.muted,
          ),
        ),
        itemBuilder: (context, index) {
          final item = chips[index];
          if (item is String) {
            return _BreadcrumbChip(
              label: item,
              selected: false,
              onTap: null,
            );
          }
          final profile = item as Profile;
          final selected = profile.id == chain.last.id;
          return _BreadcrumbChip(
            label: _chipLabel(profile),
            selected: selected,
            onTap: () => onTap(profile),
          );
        },
      ),
    );
  }
}

class _BreadcrumbChip extends StatelessWidget {
  const _BreadcrumbChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? BrandColors.gold : BrandColors.surface,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: selected ? BrandColors.gold : BrandColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
              color: selected ? BrandColors.onGold : BrandColors.teal,
            ),
          ),
        ),
      ),
    );
  }
}

class _CareLegend extends StatelessWidget {
  const _CareLegend({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    Widget item(int level) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CareRatingTheme.colorFor(level),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            l10n.t(CareRatingTheme.labelKey(level)),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: BrandColors.muted,
            ),
          ),
        ],
      );
    }

    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        item(1),
        item(2),
        item(3),
      ],
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.matches,
    required this.onPick,
  });

  final List<Profile> matches;
  final ValueChanged<Profile> onPick;

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: BrandColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrandColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < matches.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            ListTile(
              title: Text(
                matches[i].fullName,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: matches[i].fatherName == null
                  ? null
                  : Text(matches[i].fatherName!),
              onTap: () => onPick(matches[i]),
              minVerticalPadding: 12,
            ),
          ],
        ],
      ),
    );
  }
}

