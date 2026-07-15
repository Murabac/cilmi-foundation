import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../utils/branch_filter.dart';

/// Branch + father dropdown filters used across tree, registration, and admin flows.
class BranchFatherFilters extends StatelessWidget {
  const BranchFatherFilters({
    super.key,
    required this.index,
    required this.l10n,
    required this.branchId,
    required this.fatherFilterId,
    required this.onBranchChanged,
    required this.onFatherChanged,
    this.enabled = true,
    this.lineageById,
    this.fatherOptions,
    this.showFatherFilter = true,
  });

  final BranchFilterIndex index;
  final AppLocalizations l10n;
  final String? branchId;
  final String? fatherFilterId;
  final ValueChanged<String?> onBranchChanged;
  final ValueChanged<String?> onFatherChanged;
  final bool enabled;
  final Map<String, String>? lineageById;
  final List<Profile>? fatherOptions;
  final bool showFatherFilter;

  String _fatherLabel(Profile profile) {
    if (branchId != null) return profile.fullName;
    return lineageById?[profile.id] ?? profile.fullName;
  }

  List<Profile> get _fatherItems =>
      fatherOptions ?? index.fathersWithChildren(branchId: branchId);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (index.branches.isNotEmpty)
          DropdownButtonFormField<String?>(
            value: branchId,
            decoration: InputDecoration(
              labelText: l10n.t('filter_by_branch'),
            ),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(l10n.t('all_branches')),
              ),
              ...index.branches.map(
                (b) => DropdownMenuItem<String?>(
                  value: b.id,
                  child: Text(
                    l10n.t('branch_of_name').replaceAll('{name}', b.fullName),
                  ),
                ),
              ),
            ],
            onChanged: enabled ? onBranchChanged : null,
          ),
        if (showFatherFilter && _fatherItems.isNotEmpty) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            value: fatherFilterId,
            decoration: InputDecoration(
              labelText: l10n.t('filter_by_father'),
            ),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(l10n.t('all_fathers')),
              ),
              ..._fatherItems.map(
                (f) => DropdownMenuItem<String?>(
                  value: f.id,
                  child: Text(
                    l10n
                        .t('father_lineage_label')
                        .replaceAll('{name}', _fatherLabel(f)),
                    maxLines: 2,
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
