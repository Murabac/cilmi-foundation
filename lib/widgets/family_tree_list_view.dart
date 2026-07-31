import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/lineage_tree.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../theme/member_status_theme.dart';
import '../utils/patriarch_resolver.dart';
import '../utils/tree_list_display.dart';
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
    this.subBranchFilterId,
  });

  final TreeNode root;
  final AppLocalizations l10n;
  final ValueChanged<Profile> onMemberTap;
  final String? branchFilterId;
  final String? subBranchFilterId;

  @override
  State<FamilyTreeListView> createState() => _FamilyTreeListViewState();
}

class _FamilyTreeListViewState extends State<FamilyTreeListView> {
  final _searchCtrl = TextEditingController();
  final _expandedIds = <String>{};
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<TreeNode> get _sonBranches {
    var sons = widget.branchFilterId == null
        ? foundationBranchNodes(widget.root)
        : foundationBranchNodes(widget.root)
            .where((son) => son.profile.id == widget.branchFilterId)
            .toList();

    final subId = widget.subBranchFilterId;
    if (subId != null) {
      final narrowed = <TreeNode>[];
      for (final branch in sons) {
        final match = findNodeInTree(branch, subId);
        if (match != null) narrowed.add(match);
      }
      sons = narrowed;
    }

    return filterSonBranches(sons, _searchQuery);
  }

  List<TreeNode> get _daughterBranches {
    if (widget.branchFilterId != null) return const [];
    final split = splitFoundationBranches(widget.root);
    return filterSonBranches(split.daughters, _searchQuery);
  }

  Iterable<TreeNode> get _allBranchesForSearch sync* {
    final split = splitFoundationBranches(widget.root);
    yield* foundationBranchNodes(widget.root);
    yield* split.daughters;
  }

  /// Expand every ancestor of a name match so deep descendants are visible.
  void _expandAncestorsOfMatches(TreeNode node, String query, Set<String> out) {
    bool walk(TreeNode n) {
      var matched = profileNameMatchesSearch(n.profile, query);
      for (final child in n.children) {
        if (walk(child)) {
          out.add(n.profile.id);
          matched = true;
        }
      }
      return matched;
    }

    walk(node);
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      if (value.trim().isEmpty) return;
      for (final branch in _allBranchesForSearch) {
        if (treeNodeMatchesSearch(branch, value)) {
          _expandedIds.add(branch.profile.id);
          _expandAncestorsOfMatches(branch, value, _expandedIds);
        }
      }
    });
  }

  void _clearSearch() {
    _searchCtrl.clear();
    setState(() => _searchQuery = '');
  }

  void _toggleExpanded(String id) {
    setState(() {
      if (_expandedIds.contains(id)) {
        _expandedIds.remove(id);
      } else {
        _expandedIds.add(id);
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
              expanded: _expandedIds.contains(branch.profile.id),
              expandedIds: _expandedIds,
              onToggle: () => _toggleExpanded(branch.profile.id),
              onToggleDescendant: _toggleExpanded,
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
                expanded: _expandedIds.contains(branch.profile.id),
                expandedIds: _expandedIds,
                onToggle: () => _toggleExpanded(branch.profile.id),
                onToggleDescendant: _toggleExpanded,
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
    required this.expandedIds,
    required this.onToggle,
    required this.onToggleDescendant,
    required this.onMemberTap,
  });

  final TreeNode node;
  final AppLocalizations l10n;
  final String branchLabel;
  final String searchQuery;
  final bool expanded;
  final Set<String> expandedIds;
  final VoidCallback onToggle;
  final ValueChanged<String> onToggleDescendant;
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
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    ..._descendantChildren(
                      context: context,
                      children: node.children,
                      parent: node.profile,
                      l10n: l10n,
                      searchQuery: searchQuery,
                      depth: 0,
                      expandedIds: expandedIds,
                      onToggle: onToggleDescendant,
                      onMemberTap: onMemberTap,
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

List<Widget> _descendantChildren({
  required BuildContext context,
  required List<TreeNode> children,
  required Profile parent,
  required AppLocalizations l10n,
  required String searchQuery,
  required int depth,
  required Set<String> expandedIds,
  required ValueChanged<String> onToggle,
  required ValueChanged<Profile> onMemberTap,
}) {
  final widgets = <Widget>[];
  var leafBatch = <TreeNode>[];

  void flushLeaves() {
    if (leafBatch.isEmpty) return;
    widgets.add(
      Padding(
        padding: EdgeInsets.fromLTRB(depth == 0 ? 4 : 8, 8, 4, 12),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final leaf in leafBatch)
              _LeafChip(
                node: leaf,
                l10n: l10n,
                highlighted: profileNameMatchesSearch(
                  leaf.profile,
                  searchQuery,
                ),
                onTap: () => onMemberTap(leaf.profile),
              ),
          ],
        ),
      ),
    );
    leafBatch = [];
  }

  for (final child in children) {
    if (showsAsLeafChip(child, depth, parent: parent)) {
      leafBatch.add(child);
    } else {
      flushLeaves();
      widgets.add(
        _ExpandableDescendant(
          node: child,
          l10n: l10n,
          searchQuery: searchQuery,
          depth: depth,
          expandedIds: expandedIds,
          onToggle: onToggle,
          onMemberTap: onMemberTap,
        ),
      );
    }
  }
  flushLeaves();
  return widgets;
}

/// Recursive list row: parents stay expandable; leaf kids render as chips.
class _ExpandableDescendant extends StatelessWidget {
  const _ExpandableDescendant({
    required this.node,
    required this.l10n,
    required this.searchQuery,
    required this.depth,
    required this.expandedIds,
    required this.onToggle,
    required this.onMemberTap,
  });

  final TreeNode node;
  final AppLocalizations l10n;
  final String searchQuery;
  final int depth;
  final Set<String> expandedIds;
  final ValueChanged<String> onToggle;
  final ValueChanged<Profile> onMemberTap;

  @override
  Widget build(BuildContext context) {
    final hasChildren = node.children.isNotEmpty;
    final expanded = expandedIds.contains(node.profile.id);
    final nameMatches = profileNameMatchesSearch(node.profile, searchQuery);
    final childCount = node.children.length;
    final chipKids = hasChildren &&
        node.children.every(
          (c) => showsAsLeafChip(c, depth + 1, parent: node.profile),
        );
    final scheme = Theme.of(context).colorScheme;
    final nestFill = scheme.surfaceContainerHighest.withValues(
      alpha: depth == 0 ? 0.35 : 0.55,
    );

    return Padding(
      padding: EdgeInsets.only(
        left: depth == 0 ? 0 : 12.0,
        bottom: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: nameMatches && searchQuery.isNotEmpty
                ? scheme.primaryContainer.withValues(alpha: 0.55)
                : nestFill,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => onMemberTap(node.profile),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border(
                    left: BorderSide(
                      color: _statusAccent(node.profile),
                      width: 4,
                    ),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(4, 10, 10, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (hasChildren)
                      IconButton(
                        onPressed: () => onToggle(node.profile.id),
                        icon: Icon(
                          expanded
                              ? Icons.expand_less
                              : Icons.expand_more,
                          color: scheme.primary,
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(
                          Icons.subdirectory_arrow_right,
                          size: 20,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            node.profile.fullName,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: depth == 0 ? 16 : 15,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _CareAndStatusDots(
                            profile: node.profile,
                            l10n: l10n,
                          ),
                        ],
                      ),
                    ),
                    if (hasChildren)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$childCount',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: scheme.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (expanded && hasChildren)
            Container(
              margin: const EdgeInsets.only(top: 8, left: 8),
              padding: const EdgeInsets.fromLTRB(12, 12, 8, 8),
              decoration: BoxDecoration(
                color: scheme.surface.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  left: BorderSide(
                    color: scheme.outlineVariant,
                    width: 2,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    chipKids
                        ? l10n.t('grandchildren')
                        : l10n.t('children'),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                  ),
                  const SizedBox(height: 10),
                  ..._descendantChildren(
                    context: context,
                    children: node.children,
                    parent: node.profile,
                    l10n: l10n,
                    searchQuery: searchQuery,
                    depth: depth + 1,
                    expandedIds: expandedIds,
                    onToggle: onToggle,
                    onMemberTap: onMemberTap,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _LeafChip extends StatelessWidget {
  const _LeafChip({
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
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: highlighted
              ? Theme.of(context).colorScheme.primaryContainer
              : careColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: highlighted
                ? Theme.of(context).colorScheme.primary
                : careColor.withValues(alpha: 0.5),
            width: highlighted ? 2 : 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 4,
              height: 18,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              width: 9,
              height: 9,
              decoration:
                  BoxDecoration(color: careColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              node.profile.fullName,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
