import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/lineage_registration.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/branch_filter.dart';
import '../utils/lineage_name.dart';
import '../utils/profile_sort.dart';
import 'branch_father_filters.dart';
import 'widgets.dart';

/// Branch / father filters + name list for claiming an existing tree profile.
class ClaimProfilePicker extends ConsumerStatefulWidget {
  const ClaimProfilePicker({
    super.key,
    required this.selection,
    required this.l10n,
    required this.onChanged,
  });

  final LineageSelection selection;
  final AppLocalizations l10n;
  final VoidCallback onChanged;

  @override
  ConsumerState<ClaimProfilePicker> createState() => _ClaimProfilePickerState();
}

class _ClaimProfilePickerState extends ConsumerState<ClaimProfilePicker> {
  String? _branchFilterId;
  String? _fatherFilterId;

  void _selectBranch(String? branchId) {
    setState(() {
      _branchFilterId = branchId;
      _fatherFilterId = null;
      widget.selection.claimProfile = null;
    });
    widget.onChanged();
  }

  void _selectFatherFilter(String? fatherId) {
    setState(() {
      _fatherFilterId = fatherId;
      widget.selection.claimProfile = null;
    });
    widget.onChanged();
  }

  void _selectProfile(Profile profile) {
    setState(() => widget.selection.claimProfile = profile);
    widget.onChanged();
  }

  List<Profile> _fathersWithUnclaimedChildren(
    List<Profile> unclaimed,
    List<Profile> all,
    BranchFilterIndex branchIndex,
    String? branchId,
  ) {
    final unclaimedByFather = <String, List<Profile>>{};
    for (final p in unclaimed) {
      if (p.fatherId != null) {
        unclaimedByFather.putIfAbsent(p.fatherId!, () => []).add(p);
      }
    }

    final fathers = <Profile>[];
    final seen = <String>{};
    for (final f in all) {
      if (!unclaimedByFather.containsKey(f.id)) continue;
      if (branchId != null && !branchIndex.isInBranch(f.id, branchId)) continue;
      if (branchId != null && f.id == branchId) continue;
      if (seen.add(f.id)) fathers.add(f);
    }

    fathers.sort(compareProfilesByAge);
    return fathers;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final selection = widget.selection;
    final unclaimedAsync = ref.watch(unclaimedProfilesProvider);
    final allAsync = ref.watch(allProfilesProvider);

    return unclaimedAsync.when(
      loading: () => _PickerShell(
        l10n: l10n,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: LoadingView(message: l10n.t('loading_family_tree')),
        ),
      ),
      error: (e, _) => _PickerShell(
        l10n: l10n,
        child: ErrorView(
          message: e.toString(),
          onRetry: () {
            ref.invalidate(unclaimedProfilesProvider);
            ref.invalidate(allProfilesProvider);
          },
        ),
      ),
      data: (unclaimed) {
        return allAsync.when(
          loading: () => _PickerShell(
            l10n: l10n,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: LoadingView(message: l10n.t('loading_family_tree')),
            ),
          ),
          error: (e, _) => _PickerShell(
            l10n: l10n,
            child: ErrorView(
              message: e.toString(),
              onRetry: () {
                ref.invalidate(unclaimedProfilesProvider);
                ref.invalidate(allProfilesProvider);
              },
            ),
          ),
          data: (allProfiles) {
            if (allProfiles.isEmpty || unclaimed.isEmpty) {
              return _PickerShell(
                l10n: l10n,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    l10n.t('no_family_tree_data'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              );
            }

            final branchIndex = BranchFilterIndex.fromProfiles(allProfiles);
            final lineageById = {
              for (final p in allProfiles)
                p.id: buildPatrilinealDisplayName(p, branchIndex.byId),
            };
            final fathersWithUnclaimed = _fathersWithUnclaimedChildren(
              unclaimed,
              allProfiles,
              branchIndex,
              _branchFilterId,
            );

            final List<Profile> claimCandidates;
            if (_fatherFilterId != null) {
              claimCandidates = unclaimed
                  .where((p) => p.fatherId == _fatherFilterId)
                  .toList();
            } else if (_branchFilterId != null) {
              claimCandidates = unclaimed
                  .where(
                    (p) => branchIndex.isInBranch(p.id, _branchFilterId!),
                  )
                  .toList();
            } else {
              claimCandidates = unclaimed.toList();
            }
            sortProfilesByAge(claimCandidates);

            final mustPickBranch =
                _branchFilterId == null && unclaimed.length > 20;

            return _PickerShell(
              l10n: l10n,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (branchIndex.branches.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        l10n.t('patriarch_not_found'),
                        style: TextStyle(color: Colors.orange.shade800),
                      ),
                    )
                  else
                    BranchFatherFilters(
                      index: branchIndex,
                      l10n: l10n,
                      branchId: _branchFilterId,
                      fatherFilterId: _fatherFilterId,
                      onBranchChanged: _selectBranch,
                      onFatherChanged: _selectFatherFilter,
                      lineageById: lineageById,
                      fatherOptions: fathersWithUnclaimed,
                      showFatherFilter: _branchFilterId != null,
                    ),
                  const SizedBox(height: 16),
                  if (mustPickBranch)
                    Text(
                      l10n.t('select_branch_first'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.orange.shade900,
                            fontWeight: FontWeight.w600,
                          ),
                    )
                  else if (_fatherFilterId == null &&
                      _branchFilterId != null &&
                      fathersWithUnclaimed.isNotEmpty &&
                      claimCandidates.isEmpty)
                    Text(l10n.t('select_father_filter_hint'))
                  else if (claimCandidates.isEmpty)
                    Text(l10n.t('no_unclaimed_in_branch'))
                  else ...[
                    Text(
                      _fatherFilterId == null && _branchFilterId == null
                          ? l10n.t('all_unclaimed_members')
                          : l10n.t('select_your_name'),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    ...claimCandidates.take(40).map(
                          (p) => RadioListTile<Profile>(
                            title: Text(p.fullName),
                            subtitle: p.fatherName != null
                                ? Text(
                                    l10n
                                        .t('profile_father_label')
                                        .replaceAll('{name}', p.fatherName!),
                                  )
                                : Text(
                                    lineageById[p.id] ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                            value: p,
                            groupValue: selection.claimProfile,
                            onChanged: (v) {
                              if (v != null) _selectProfile(v);
                            },
                          ),
                        ),
                    if (claimCandidates.length > 40)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          l10n
                              .t('claim_picker_more_names')
                              .replaceAll(
                                '{count}',
                                '${claimCandidates.length - 40}',
                              ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _PickerShell extends StatelessWidget {
  const _PickerShell({required this.l10n, required this.child});

  final AppLocalizations l10n;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.t('find_your_name_in_tree'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.t('claim_branch_hint'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade700,
                  ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
