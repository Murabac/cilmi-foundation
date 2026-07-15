import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../utils/father_picker_index.dart';
import 'branch_father_filters.dart';

/// Branch + father filters and selectable father list (shared by add/edit flows).
class FatherPickerSection extends StatelessWidget {
  const FatherPickerSection({
    super.key,
    required this.index,
    required this.l10n,
    required this.branchFilterId,
    required this.fatherFilterId,
    required this.selectedFather,
    required this.onBranchChanged,
    required this.onFatherFilterChanged,
    required this.onFatherSelected,
    required this.fatherOptions,
    this.enabled = true,
    this.hintKey = 'add_member_father_branch_hint',
  });

  final FatherPickerIndex index;
  final AppLocalizations l10n;
  final String? branchFilterId;
  final String? fatherFilterId;
  final Profile? selectedFather;
  final ValueChanged<String?> onBranchChanged;
  final ValueChanged<String?> onFatherFilterChanged;
  final ValueChanged<Profile?> onFatherSelected;
  final List<Profile> fatherOptions;
  final bool enabled;
  final String hintKey;

  String _lineageLabel(Profile profile) =>
      index.lineageById[profile.id] ?? profile.fullName;

  @override
  Widget build(BuildContext context) {
    final visible = fatherOptions.take(40).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.t('select_father'),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        Text(
          l10n.t(hintKey),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade700,
              ),
        ),
        if (index.branchIndex.branches.isNotEmpty) ...[
          const SizedBox(height: 12),
          BranchFatherFilters(
            index: index.branchIndex,
            l10n: l10n,
            branchId: branchFilterId,
            fatherFilterId: fatherFilterId,
            onBranchChanged: onBranchChanged,
            onFatherChanged: onFatherFilterChanged,
            enabled: enabled,
            lineageById: index.lineageById,
            fatherOptions: index.branchIndex.fathersWithChildren(
              branchId: branchFilterId,
            ),
          ),
        ],
        if (selectedFather != null) ...[
          const SizedBox(height: 12),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: ListTile(
              leading: const Icon(Icons.check_circle),
              title: Text(
                selectedFather!.fullName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(_lineageLabel(selectedFather!)),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: enabled ? () => onFatherSelected(null) : null,
              ),
            ),
          ),
        ],
        const SizedBox(height: 8),
        if (visible.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(l10n.t('no_fathers_in_branch')),
          )
        else ...[
          Text(
            l10n
                .t('father_picker_results')
                .replaceAll('{count}', '${visible.length}'),
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 4),
          ...visible.map((father) {
            final selected = selectedFather?.id == father.id;
            return Card(
              margin: const EdgeInsets.only(bottom: 6),
              color: selected
                  ? Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: 0.5)
                  : null,
              child: ListTile(
                title: Text(
                  father.fullName,
                  style: TextStyle(
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  _lineageLabel(father),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                isThreeLine: true,
                onTap: enabled ? () => onFatherSelected(father) : null,
              ),
            );
          }),
          if (fatherOptions.length > visible.length)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l10n
                    .t('father_picker_more_in_branch')
                    .replaceAll(
                      '{count}',
                      '${fatherOptions.length - visible.length}',
                    ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ],
    );
  }
}
