import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../models/lineage_tree.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../utils/branch_filter.dart';
import '../../utils/patriarch_resolver.dart';
import '../../widgets/add_family_member_dialog.dart';
import '../../widgets/branch_father_filters.dart';
import '../../widgets/family_tree_list_view.dart';
import '../../widgets/member_business_card.dart';
import '../../widgets/pedigree_tree_chart.dart';
import '../../widgets/widgets.dart';

class FamilyTreeScreen extends ConsumerStatefulWidget {
  const FamilyTreeScreen({super.key});

  @override
  ConsumerState<FamilyTreeScreen> createState() => _FamilyTreeScreenState();
}

class _FamilyTreeScreenState extends ConsumerState<FamilyTreeScreen> {
  String? _branchFilterId;
  String? _fatherFilterId;

  void _onBranchChanged(String? branchId) {
    setState(() {
      _branchFilterId = branchId;
      _fatherFilterId = null;
    });
  }

  void _onFatherFilterChanged(String? fatherId) {
    setState(() => _fatherFilterId = fatherId);
  }

  void _openMemberCard(Profile profile) {
    showMemberBusinessCard(context, ref, profile);
  }

  @override
  Widget build(BuildContext context) {
    final l10nAsync = ref.watch(localizationsProvider);
    final treeAsync = ref.watch(fullLineageTreeProvider);
    final countAsync = ref.watch(memberCountProvider);
    final settingsAsync = ref.watch(globalSettingsProvider);
    final profileAsync = ref.watch(currentProfileProvider);
    final isAdmin = profileAsync.valueOrNull?.role.isAdminOrManager ?? false;
    final showListView =
        settingsAsync.valueOrNull?.familyTreeView == FamilyTreeViewMode.list;

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

          final split = splitPatriarchChildren(root);
          final filteredSons = _branchFilterId == null
              ? split.sons
              : split.sons
                  .where((son) => son.profile.id == _branchFilterId)
                  .toList();
          final branchIndex = BranchFilterIndex.fromProfiles(
            _collectProfiles(root),
          );
          final total = countTreeMembers(root);

          var chartRoot = root;
          if (_fatherFilterId != null) {
            chartRoot =
                findNodeInTree(root, _fatherFilterId!) ?? chartRoot;
          } else if (_branchFilterId != null && filteredSons.isNotEmpty) {
            chartRoot = filteredSons.first;
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(fullLineageTreeProvider);
              ref.invalidate(memberCountProvider);
              ref.invalidate(globalSettingsProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                countAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (count) {
                    final cards = <Widget>[
                      MetricCard(
                        title: l10n.t('total_members'),
                        value: '$count',
                        icon: Icons.account_tree,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ];
                    if (count != total) {
                      cards.add(
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: MaterialBanner(
                            content: Text(
                              l10n
                                  .t('tree_data_mismatch')
                                  .replaceAll('{dbCount}', '$count')
                                  .replaceAll('{treeCount}', '$total'),
                            ),
                            leading: const Icon(Icons.warning_amber),
                            backgroundColor: Colors.orange.shade50,
                            actions: const [SizedBox.shrink()],
                          ),
                        ),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: cards,
                    );
                  },
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
                if (!showListView)
                  Text(
                    l10n.t('tree_chart_hint'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                const SizedBox(height: 16),
                if (root.children.isNotEmpty)
                  BranchFatherFilters(
                    index: branchIndex,
                    l10n: l10n,
                    branchId: _branchFilterId,
                    fatherFilterId: _fatherFilterId,
                    onBranchChanged: _onBranchChanged,
                    onFatherChanged: _onFatherFilterChanged,
                    showFatherFilter: !showListView && _branchFilterId != null,
                    fatherOptions: branchIndex.fathersWithChildren(
                      branchId: _branchFilterId,
                    ),
                  ),
                if (root.children.isNotEmpty) const SizedBox(height: 16),
                if (showListView)
                  FamilyTreeListView(
                    root: root,
                    l10n: l10n,
                    branchFilterId: _branchFilterId,
                    onMemberTap: _openMemberCard,
                  )
                else
                  PedigreeTreeChart(
                    root: chartRoot,
                    onMemberTap: _openMemberCard,
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

  List<Profile> _collectProfiles(TreeNode node) {
    final profiles = <Profile>[node.profile];
    for (final child in node.children) {
      profiles.addAll(_collectProfiles(child));
    }
    return profiles;
  }
}
