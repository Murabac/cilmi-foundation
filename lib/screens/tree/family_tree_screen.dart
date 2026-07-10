import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../models/lineage_tree.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/add_family_member_dialog.dart';
import '../../widgets/member_business_card.dart';
import '../../widgets/widgets.dart';

class FamilyTreeScreen extends ConsumerStatefulWidget {
  const FamilyTreeScreen({super.key});

  @override
  ConsumerState<FamilyTreeScreen> createState() => _FamilyTreeScreenState();
}

class _FamilyTreeScreenState extends ConsumerState<FamilyTreeScreen> {
  final _searchCtrl = TextEditingController();
  final _expandedSonIds = <String>{};
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value, List<TreeNode> sons) {
    setState(() {
      _searchQuery = value;
      if (value.trim().isEmpty) return;
      for (final son in sons) {
        if (treeNodeMatchesSearch(son, value)) {
          _expandedSonIds.add(son.profile.id);
        }
      }
    });
  }

  void _clearSearch() {
    _searchCtrl.clear();
    setState(() => _searchQuery = '');
  }

  void _toggleSon(String id) {
    setState(() {
      if (_expandedSonIds.contains(id)) {
        _expandedSonIds.remove(id);
      } else {
        _expandedSonIds.add(id);
      }
    });
  }

  void _openMemberCard(Profile profile) {
    showMemberBusinessCard(context, ref, profile);
  }

  @override
  Widget build(BuildContext context) {
    final l10nAsync = ref.watch(localizationsProvider);
    final treeAsync = ref.watch(fullLineageTreeProvider);
    final countAsync = ref.watch(memberCountProvider);
    final profileAsync = ref.watch(currentProfileProvider);
    final isAdmin = profileAsync.valueOrNull?.role.isAdminOrManager ?? false;

    return l10nAsync.when(
      loading: () => const LoadingView(),
      error: (_, __) => const ErrorView(message: 'Error'),
      data: (l10n) => treeAsync.when(
        loading: () => LoadingView(message: l10n.t('loading')),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(fullLineageTreeProvider),
        ),
        data: (root) {
          if (root == null) {
            return ErrorView(
              message: l10n.t('no_data'),
              onRetry: () => ref.invalidate(fullLineageTreeProvider),
            );
          }

          final filteredSons = filterSonBranches(root.children, _searchQuery);
          final total = countTreeMembers(root);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(fullLineageTreeProvider);
              ref.invalidate(memberCountProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                countAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (count) => MetricCard(
                    title: l10n.t('total_members'),
                    value: '$count',
                    icon: Icons.account_tree,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                if (isAdmin) ...[
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
                    onPressed: () async {
                      final added = await showAddFamilyMemberDialog(context, ref);
                      if (added && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.t('add_member_success'))),
                        );
                      }
                    },
                    icon: const Icon(Icons.person_add_outlined),
                    label: Text(l10n.t('add_family_member')),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  l10n.t('full_tree_hint'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
                const SizedBox(height: 20),
                _PatriarchCard(
                  profile: root.profile,
                  l10n: l10n,
                  onTap: () => _openMemberCard(root.profile),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => _onSearchChanged(v, root.children),
                  decoration: InputDecoration(
                    hintText: l10n.t('search_family'),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearSearch,
                          )
                        : null,
                  ),
                ),
                if (_searchQuery.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n
                        .t('search_results')
                        .replaceAll('{count}', '${filteredSons.length}'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
                const SizedBox(height: 16),
                Center(
                  child: Icon(Icons.arrow_downward, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.t('tap_name_for_card'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
                const SizedBox(height: 12),
                if (filteredSons.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(child: Text(l10n.t('no_search_results'))),
                    ),
                  )
                else
                  ...filteredSons.map(
                    (branch) => _SonBranch(
                      node: branch,
                      l10n: l10n,
                      searchQuery: _searchQuery,
                      expanded: _expandedSonIds.contains(branch.profile.id),
                      onToggle: () => _toggleSon(branch.profile.id),
                      onMemberTap: _openMemberCard,
                    ),
                  ),
                const SizedBox(height: 24),
                Text(
                  '${l10n.t('total_members')}: $total',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PatriarchCard extends StatelessWidget {
  const _PatriarchCard({
    required this.profile,
    required this.l10n,
    required this.onTap,
  });

  final Profile profile;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              l10n.t('patriarch'),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            ProfileCard(
              profile: profile,
              l10n: l10n,
              highlighted: true,
              onTap: onTap,
            ),
            const SizedBox(height: 8),
            CareRatingBadge(rating: profile.careRating, l10n: l10n),
          ],
        ),
      ),
    );
  }
}

class _SonBranch extends StatelessWidget {
  const _SonBranch({
    required this.node,
    required this.l10n,
    required this.searchQuery,
    required this.expanded,
    required this.onToggle,
    required this.onMemberTap,
  });

  final TreeNode node;
  final AppLocalizations l10n;
  final String searchQuery;
  final bool expanded;
  final VoidCallback onToggle;
  final ValueChanged<Profile> onMemberTap;

  @override
  Widget build(BuildContext context) {
    final descendantTotal = node.descendantCount;
    final nameMatches = profileNameMatchesSearch(node.profile, searchQuery);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: nameMatches && searchQuery.isNotEmpty
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => onMemberTap(node.profile),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.t('son_branch'),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                          Text(
                            node.profile.fullName,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          CareRatingBadge(
                            rating: node.profile.careRating,
                            l10n: l10n,
                            compact: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (descendantTotal > 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Chip(
                      label: Text('$descendantTotal ${l10n.t('descendants')}'),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                IconButton(
                  onPressed: onToggle,
                  icon: Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          if (expanded && node.children.isNotEmpty)
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    ...node.children.map(
                      (child) => _ChildBranch(
                        node: child,
                        l10n: l10n,
                        highlightQuery: searchQuery,
                        onMemberTap: onMemberTap,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChildBranch extends StatelessWidget {
  const _ChildBranch({
    required this.node,
    required this.l10n,
    required this.highlightQuery,
    required this.onMemberTap,
  });

  final TreeNode node;
  final AppLocalizations l10n;
  final String highlightQuery;
  final ValueChanged<Profile> onMemberTap;

  @override
  Widget build(BuildContext context) {
    final hasGrandchildren = node.children.isNotEmpty;
    final nameMatches = profileNameMatchesSearch(node.profile, highlightQuery);

    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Icon(Icons.subdirectory_arrow_right,
                    size: 18, color: Colors.grey.shade500),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: InkWell(
                  onTap: () => onMemberTap(node.profile),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: nameMatches && highlightQuery.isNotEmpty
                        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
                        : const EdgeInsets.symmetric(vertical: 4),
                    decoration: nameMatches && highlightQuery.isNotEmpty
                        ? BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          )
                        : null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          node.profile.fullName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        CareRatingBadge(
                          rating: node.profile.careRating,
                          l10n: l10n,
                          compact: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (hasGrandchildren) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.t('grandchildren'),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: node.children
                        .map(
                          (grandchild) => _GrandchildChip(
                            node: grandchild,
                            l10n: l10n,
                            highlighted: profileNameMatchesSearch(
                              grandchild.profile,
                              highlightQuery,
                            ),
                            onTap: () => onMemberTap(grandchild.profile),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GrandchildChip extends StatelessWidget {
  const _GrandchildChip({
    required this.node,
    required this.l10n,
    this.highlighted = false,
    required this.onTap,
  });

  final TreeNode node;
  final AppLocalizations l10n;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = CareRatingTheme.colorFor(node.profile.careRating);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: highlighted
              ? Theme.of(context).colorScheme.primaryContainer
              : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: highlighted
                ? Theme.of(context).colorScheme.primary
                : color.withValues(alpha: 0.4),
            width: highlighted ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              node.profile.fullName,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
