import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/lineage_registration.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/profile_sort.dart';
import 'widgets.dart';

class LineageSelectionForm extends ConsumerStatefulWidget {
  const LineageSelectionForm({
    super.key,
    required this.selection,
    required this.l10n,
    required this.onChanged,
    this.nameController,
    this.phoneController,
    this.showNameAndPhone = true,
  });

  final LineageSelection selection;
  final AppLocalizations l10n;
  final VoidCallback onChanged;
  final TextEditingController? nameController;
  final TextEditingController? phoneController;
  final bool showNameAndPhone;

  @override
  ConsumerState<LineageSelectionForm> createState() =>
      _LineageSelectionFormState();
}

class _LineageSelectionFormState extends ConsumerState<LineageSelectionForm> {
  void _update(VoidCallback fn) {
    setState(fn);
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final selection = widget.selection;
    final sonsAsync = ref.watch(sonsOfPatriarchProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.t('how_are_you_related'),
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        _TypeTile(
          title: l10n.t('claim_existing'),
          subtitle: l10n.t('claim_existing_desc'),
          selected: selection.type == LineageRegistrationType.claimExisting,
          onTap: () => _update(
            () => selection.type = LineageRegistrationType.claimExisting,
          ),
        ),
        _TypeTile(
          title: l10n.t('new_son_of_sheekh'),
          subtitle: l10n.t('new_son_of_sheekh_desc'),
          selected: selection.type == LineageRegistrationType.sonOfSheekh,
          onTap: () => _update(
            () => selection.type = LineageRegistrationType.sonOfSheekh,
          ),
        ),
        _TypeTile(
          title: l10n.t('new_child_of_son'),
          subtitle: l10n.t('new_child_of_son_desc'),
          selected: selection.type == LineageRegistrationType.childOfSon,
          onTap: () => _update(
            () => selection.type = LineageRegistrationType.childOfSon,
          ),
        ),
        _TypeTile(
          title: l10n.t('new_grandchild'),
          subtitle: l10n.t('new_grandchild_desc'),
          selected: selection.type == LineageRegistrationType.grandchild,
          onTap: () => _update(
            () => selection.type = LineageRegistrationType.grandchild,
          ),
        ),
        const SizedBox(height: 16),
        if (selection.type == LineageRegistrationType.claimExisting)
          _ClaimExistingPicker(
            selection: selection,
            l10n: l10n,
            onChanged: () => _update(() {}),
          )
        else ...[
          if (widget.showNameAndPhone) ...[
            TextField(
              controller: widget.nameController,
              onChanged: (_) => widget.onChanged(),
              decoration: InputDecoration(labelText: l10n.t('full_name')),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: widget.phoneController,
              onChanged: (_) => widget.onChanged(),
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: l10n.t('phone')),
            ),
            const SizedBox(height: 16),
          ],
          if (selection.type == LineageRegistrationType.childOfSon ||
              selection.type == LineageRegistrationType.grandchild)
            sonsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
              data: (sons) => DropdownButtonFormField<Profile>(
                decoration: InputDecoration(
                  labelText: l10n.t('select_sheekh_son'),
                ),
                initialValue: selection.selectedSon,
                items: sons
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.fullName),
                      ),
                    )
                    .toList(),
                onChanged: (v) => _update(() {
                  selection.selectedSon = v;
                  selection.selectedChild = null;
                }),
              ),
            ),
          if (selection.type == LineageRegistrationType.grandchild &&
              selection.selectedSon != null) ...[
            const SizedBox(height: 12),
            _GrandchildFatherPicker(
              sonId: selection.selectedSon!.id,
              selected: selection.selectedChild,
              l10n: l10n,
              onChanged: (p) => _update(() => selection.selectedChild = p),
            ),
          ],
        ],
      ],
    );
  }
}

class _ClaimExistingPicker extends ConsumerStatefulWidget {
  const _ClaimExistingPicker({
    required this.selection,
    required this.l10n,
    required this.onChanged,
  });

  final LineageSelection selection;
  final AppLocalizations l10n;
  final VoidCallback onChanged;

  @override
  ConsumerState<_ClaimExistingPicker> createState() =>
      _ClaimExistingPickerState();
}

class _ClaimExistingPickerState extends ConsumerState<_ClaimExistingPicker> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  Profile? _selectedFather;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _query = value;
      _selectedFather = null;
      widget.selection.claimProfile = null;
    });
    widget.onChanged();
  }

  void _selectFather(Profile father) {
    setState(() {
      _selectedFather = father;
      widget.selection.claimProfile = null;
    });
    widget.onChanged();
  }

  void _selectProfile(Profile profile) {
    setState(() => widget.selection.claimProfile = profile);
    widget.onChanged();
  }

  List<Profile> _matchingFathers(
    String query,
    List<Profile> unclaimed,
    List<Profile> all,
  ) {
    if (query.isEmpty) return [];

    final q = query.toLowerCase();
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
      if (!f.fullName.toLowerCase().contains(q)) continue;
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
      loading: () => LoadingView(message: l10n.t('loading')),
      error: (e, _) => ErrorView(message: e.toString()),
      data: (unclaimed) {
        return allAsync.when(
          loading: () => LoadingView(message: l10n.t('loading')),
          error: (e, _) => ErrorView(message: e.toString()),
          data: (allProfiles) {
            final q = _query.trim().toLowerCase();
            final sortedUnclaimed = unclaimed.toList();
            sortProfilesByAge(sortedUnclaimed);
            final directMatches = q.isEmpty
                ? sortedUnclaimed
                : unclaimed
                    .where((p) => p.fullName.toLowerCase().contains(q))
                    .toList();
            sortProfilesByAge(directMatches);
            final matchingFathers = _matchingFathers(q, unclaimed, allProfiles);
            final childrenOfFather = _selectedFather == null
                ? <Profile>[]
                : unclaimed
                    .where((p) => p.fatherId == _selectedFather!.id)
                    .toList();
            sortProfilesByAge(childrenOfFather);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    labelText: l10n.t('find_your_name_or_father'),
                    hintText: l10n.t('claim_search_hint'),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchCtrl.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                  ),
                ),
                if (q.isEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    l10n.t('claim_search_hint'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                  ),
                ],
                if (q.isNotEmpty && directMatches.isEmpty && matchingFathers.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(l10n.t('no_search_results')),
                  ),
                if (directMatches.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    q.isEmpty
                        ? l10n.t('all_unclaimed_members')
                        : l10n.t('select_your_name'),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  ...directMatches.take(20).map(
                        (p) => RadioListTile<Profile>(
                          title: Text(p.fullName),
                          subtitle: p.fatherName != null
                              ? Text(
                                  l10n
                                      .t('profile_father_label')
                                      .replaceAll('{name}', p.fatherName!),
                                )
                              : null,
                          value: p,
                          groupValue: selection.claimProfile,
                          onChanged: (v) {
                            if (v != null) _selectProfile(v);
                          },
                        ),
                      ),
                ],
                if (matchingFathers.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    l10n.t('matching_fathers'),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  ...matchingFathers.take(10).map(
                        (father) {
                          final childCount = unclaimed
                              .where((p) => p.fatherId == father.id)
                              .length;
                          final selected = _selectedFather?.id == father.id;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            color: selected
                                ? Theme.of(context).colorScheme.primaryContainer
                                : null,
                            child: ListTile(
                              leading: Icon(
                                Icons.person_outline,
                                color: selected
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                              ),
                              title: Text(father.fullName),
                              subtitle: Text(
                                '$childCount ${l10n.t('children').toLowerCase()}',
                              ),
                              trailing: Icon(
                                selected ? Icons.expand_less : Icons.expand_more,
                              ),
                              onTap: () => _selectFather(father),
                            ),
                          );
                        },
                      ),
                ],
                if (_selectedFather != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n
                        .t('children_of_father')
                        .replaceAll('{name}', _selectedFather!.fullName),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  if (childrenOfFather.isEmpty)
                    Text(l10n.t('no_children_for_son'))
                  else
                    ...childrenOfFather.map(
                      (p) => RadioListTile<Profile>(
                        title: Text(p.fullName),
                        value: p,
                        groupValue: selection.claimProfile,
                        onChanged: (v) {
                          if (v != null) _selectProfile(v);
                        },
                      ),
                    ),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

class _TypeTile extends StatelessWidget {
  const _TypeTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: selected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: selected ? const Icon(Icons.check_circle) : null,
        onTap: onTap,
      ),
    );
  }
}

class _GrandchildFatherPicker extends ConsumerWidget {
  const _GrandchildFatherPicker({
    required this.sonId,
    required this.selected,
    required this.l10n,
    required this.onChanged,
  });

  final String sonId;
  final Profile? selected;
  final AppLocalizations l10n;
  final ValueChanged<Profile?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(profileChildrenProvider(sonId));

    return childrenAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => ErrorView(message: l10n.t('error_generic')),
      data: (children) {
        if (children.isEmpty) {
          return Text(l10n.t('no_children_for_son'));
        }
        return DropdownButtonFormField<Profile>(
          decoration: InputDecoration(
            labelText: l10n.t('select_your_father'),
          ),
          initialValue: selected,
          items: children
              .map(
                (c) => DropdownMenuItem(
                  value: c,
                  child: Text(c.fullName),
                ),
              )
              .toList(),
          onChanged: onChanged,
        );
      },
    );
  }
}
