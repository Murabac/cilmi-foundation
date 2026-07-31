import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../utils/branch_filter.dart';

/// Branch → sub-branch (kids) → parent filters used across tree and admin flows.
class BranchFatherFilters extends StatelessWidget {
  const BranchFatherFilters({
    super.key,
    required this.index,
    required this.l10n,
    required this.branchId,
    required this.fatherFilterId,
    required this.onBranchChanged,
    required this.onFatherChanged,
    this.subBranchId,
    this.onSubBranchChanged,
    this.enabled = true,
    this.lineageById,
    this.fatherOptions,
    this.showFatherFilter = true,
    this.showSubBranchFilter = true,
  });

  final BranchFilterIndex index;
  final AppLocalizations l10n;
  final String? branchId;
  final String? subBranchId;
  final String? fatherFilterId;
  final ValueChanged<String?> onBranchChanged;
  final ValueChanged<String?>? onSubBranchChanged;
  final ValueChanged<String?> onFatherChanged;
  final bool enabled;
  final Map<String, String>? lineageById;
  final List<Profile>? fatherOptions;
  final bool showFatherFilter;
  final bool showSubBranchFilter;

  String _fatherLabel(Profile profile) {
    if (branchId != null) return profile.fullName;
    return lineageById?[profile.id] ?? profile.fullName;
  }

  List<Profile> get _subBranches =>
      branchId == null ? const [] : index.subBranchesOf(branchId!);

  List<Profile> get _fatherItems {
    if (fatherOptions != null) return fatherOptions!;
    final scopeId = subBranchId ?? branchId;
    return index.fathersWithChildren(branchId: scopeId);
  }

  @override
  Widget build(BuildContext context) {
    final subBranches = _subBranches;
    final showSub = showSubBranchFilter &&
        onSubBranchChanged != null &&
        branchId != null &&
        subBranches.isNotEmpty;
    final fatherItems = _fatherItems;
    final menuMaxHeight = MediaQuery.sizeOf(context).height * 0.4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (index.branches.isNotEmpty)
          DropdownButtonFormField<String?>(
            // Stable key — recreating on selection can crash the menu overlay.
            key: const ValueKey('branch_filter'),
            initialValue: branchId,
            isExpanded: true,
            menuMaxHeight: menuMaxHeight,
            decoration: InputDecoration(
              labelText: l10n.t('filter_by_branch'),
              isDense: true,
            ),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(
                  l10n.t('all_branches'),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ...index.branches.map(
                (b) => DropdownMenuItem<String?>(
                  value: b.id,
                  child: Text(
                    l10n.t('branch_of_name').replaceAll('{name}', b.fullName),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
            onChanged: enabled ? onBranchChanged : null,
          ),
        if (showSub) ...[
          const SizedBox(height: 10),
          DropdownButtonFormField<String?>(
            // Recreate only when the parent branch changes (resets selection).
            key: ValueKey('sub_filter_$branchId'),
            initialValue: subBranchId,
            isExpanded: true,
            menuMaxHeight: menuMaxHeight,
            decoration: InputDecoration(
              labelText: l10n.t('filter_by_sub_branch'),
              isDense: true,
            ),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(
                  l10n.t('all_sub_branches'),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ...subBranches.map(
                (s) => DropdownMenuItem<String?>(
                  value: s.id,
                  child: Text(
                    l10n
                        .t('sub_branch_of_name')
                        .replaceAll('{name}', s.fullName),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
            onChanged: enabled ? onSubBranchChanged : null,
          ),
        ],
        if (showFatherFilter && fatherItems.isNotEmpty) ...[
          const SizedBox(height: 10),
          DropdownButtonFormField<String?>(
            // Recreate only when the scope / options change, not on selection.
            key: ValueKey(
              'father_filter_${branchId}_${subBranchId}_${fatherItems.length}',
            ),
            initialValue: fatherFilterId,
            isExpanded: true,
            menuMaxHeight: menuMaxHeight,
            decoration: InputDecoration(
              labelText: l10n.t('filter_by_father'),
              isDense: true,
            ),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(
                  l10n.t('all_fathers'),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ...fatherItems.map(
                (f) => DropdownMenuItem<String?>(
                  value: f.id,
                  child: Text(
                    l10n
                        .t('father_lineage_label')
                        .replaceAll('{name}', _fatherLabel(f)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
            onChanged: enabled ? onFatherChanged : null,
          ),
        ],
      ],
    );
  }
}
