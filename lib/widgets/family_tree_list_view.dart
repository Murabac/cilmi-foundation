import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/lineage_tree.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../theme/member_status_theme.dart';
import '../utils/patriarch_resolver.dart';
import 'widgets.dart';

Color _statusAccent(Profile profile) =>
    MemberStatusTheme.colorFor(
      demographic: profile.demographic,
      maritalStatus: profile.maritalStatus,
    ) ??
    Colors.grey.shade400;

/// Care rating + life-status dots shown together (does not replace either).
class _CareAndStatusDots extends StatelessWidget {
  const _CareAndStatusDots({
    required this.profile,
    required this.l10n,
  });

  final Profile profile;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CareRatingBadge(
          rating: profile.careRating,
          l10n: l10n,
          compact: true,
        ),
        const SizedBox(width: 6),
        MemberStatusBadge(
          profile: profile,
          l10n: l10n,
          compact: true,
        ),
      ],
    );
  }
}

/// Expandable son-branch list (legacy family tree layout).
class FamilyTreeListView extends StatefulWidget {
  const FamilyTreeListView({
    super.key,
    required this.root,
    required this.l10n,
    required this.onMemberTap,
    this.branchFilterId,
  });

  final TreeNode root;
  final AppLocalizations l10n;
  final ValueChanged<Profile> onMemberTap;
  final String? branchFilterId;

  @override
  State<FamilyTreeListView> createState() => _FamilyTreeListViewState();
}

class _FamilyTreeListViewState extends State<FamilyTreeListView> {
  final _searchCtrl = TextEditingController();
  final _expandedSonIds = <String>{};
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<TreeNode> get _sonBranches {
    final split = splitPatriarchChildren(widget.root);
    final sons = widget.branchFilterId == null
        ? split.sons
        : split.sons
            .where((son) => son.profile.id == widget.branchFilterId)
            .toList();
    return filterSonBranches(sons, _searchQuery);
  }

  List<TreeNode> get _daughterBranches {
    if (widget.branchFilterId != null) return const [];
    final split = splitPatriarchChildren(widget.root);
    return filterSonBranches(split.daughters, _searchQuery);
  }

  Iterable<TreeNode> get _allBranchesForSearch sync* {
    final split = splitPatriarchChildren(widget.root);
    yield* split.sons;
    yield* split.daughters;
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      if (value.trim().isEmpty) return;
      for (final branch in _allBranchesForSearch) {
        if (treeNodeMatchesSearch(branch, value)) {
          _expandedSonIds.add(branch.profile.id);
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

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final filteredSons = _sonBranches;
    final filteredDaughters = _daughterBranches;
    final resultCount = filteredSons.length + filteredDaughters.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.t('full_tree_hint'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
        const SizedBox(height: 20),
        _PatriarchCard(
          profile: widget.root.profile,
          l10n: l10n,
          onTap: () => widget.onMemberTap(widget.root.profile),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _searchCtrl,
          onChanged: _onSearchChanged,
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
                .replaceAll('{count}', '$resultCount'),
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
        if (filteredSons.isEmpty && filteredDaughters.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(child: Text(l10n.t('no_search_results'))),
            ),
          )
        else ...[
          ...filteredSons.map(
            (branch) => _SonBranch(
              node: branch,
              l10n: l10n,
              branchLabel: l10n.t('son_branch'),
              searchQuery: _searchQuery,
              expanded: _expandedSonIds.contains(branch.profile.id),
              onToggle: () => _toggleSon(branch.profile.id),
              onMemberTap: widget.onMemberTap,
            ),
          ),
          if (filteredDaughters.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              l10n.t('patriarch_daughters'),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 12),
            ...filteredDaughters.map(
              (branch) => _SonBranch(
                node: branch,
                l10n: l10n,
                branchLabel: l10n.t('daughter_branch'),
                searchQuery: _searchQuery,
                expanded: _expandedSonIds.contains(branch.profile.id),
                onToggle: () => _toggleSon(branch.profile.id),
                onMemberTap: widget.onMemberTap,
              ),
            ),
          ],
        ],
      ],
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
            const SizedBox(height: 6),
            MemberStatusBadge(profile: profile, l10n: l10n),
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
    required this.branchLabel,
    required this.searchQuery,
    required this.expanded,
    required this.onToggle,
    required this.onMemberTap,
  });

  final TreeNode node;
  final AppLocalizations l10n;
  final String branchLabel;
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
                    color: _statusAccent(node.profile),
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
                            branchLabel,
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
                          const SizedBox(height: 4),
                          _CareAndStatusDots(
                            profile: node.profile,
                            l10n: l10n,
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
                        const SizedBox(height: 4),
                        _CareAndStatusDots(
                          profile: node.profile,
                          l10n: l10n,
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
    final careColor = CareRatingTheme.colorFor(node.profile.careRating);
    final statusColor = _statusAccent(node.profile);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: highlighted
              ? Theme.of(context).colorScheme.primaryContainer
              : careColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: highlighted
                ? Theme.of(context).colorScheme.primary
                : careColor.withValues(alpha: 0.45),
            width: highlighted ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 3,
              height: 16,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: careColor, shape: BoxShape.circle),
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
