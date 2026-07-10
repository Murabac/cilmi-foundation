import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/lineage_name.dart';
import '../utils/profile_sort.dart';

/// Opens a dialog for admins to add an unclaimed family tree member.
Future<bool> showAddFamilyMemberDialog(
  BuildContext context,
  WidgetRef ref, {
  Profile? suggestedFather,
}) async {
  final l10n = ref.read(localizationsProvider).value;
  if (l10n == null) return false;

  final profiles = await ref.read(allProfilesProvider.future);
  if (!context.mounted) return false;

  final created = await showDialog<bool>(
    context: context,
    builder: (ctx) => _AddFamilyMemberDialog(
      l10n: l10n,
      profiles: profiles,
      suggestedFather: suggestedFather,
      onSave: (fullName, fatherId, demographic, phone) async {
        await ref.read(profileServiceProvider).createFamilyMember(
              fullName: fullName,
              fatherId: fatherId,
              demographic: demographic,
              phoneNumber: phone,
            );
      },
    ),
  );

  if (created == true) {
    ref.invalidate(allProfilesProvider);
    ref.invalidate(unclaimedProfilesProvider);
    ref.invalidate(fullLineageTreeProvider);
    ref.invalidate(memberCountProvider);
  }

  return created ?? false;
}

class _FatherPickerIndex {
  _FatherPickerIndex({
    required this.profiles,
    required this.byId,
    required this.lineageById,
    required this.branches,
    required this.patriarchId,
  });

  final List<Profile> profiles;
  final Map<String, Profile> byId;
  final Map<String, String> lineageById;
  final List<Profile> branches;
  final String? patriarchId;

  static _FatherPickerIndex fromProfiles(List<Profile> profiles) {
    final byId = {for (final p in profiles) p.id: p};
    final lineageById = {
      for (final p in profiles)
        p.id: buildPatrilinealDisplayName(p, byId),
    };

    Profile? patriarch;
    for (final p in profiles) {
      if (p.fullName.toUpperCase().contains('SHEEKH YONIS')) {
        patriarch = p;
        break;
      }
    }
    patriarch ??= profiles.where((p) => p.fatherId == null).cast<Profile?>().firstOrNull;

    final branches = patriarch == null
        ? <Profile>[]
        : profiles.where((p) => p.fatherId == patriarch!.id).toList();
    sortProfilesByAge(branches);

    return _FatherPickerIndex(
      profiles: profiles,
      byId: byId,
      lineageById: lineageById,
      branches: branches,
      patriarchId: patriarch?.id,
    );
  }

  bool isInBranch(String profileId, String branchId) {
    if (profileId == branchId) return true;
    var current = byId[profileId];
    final visited = <String>{};
    while (current != null) {
      if (current.id == branchId) return true;
      if (current.fatherId == null) return false;
      if (!visited.add(current.fatherId!)) return false;
      current = byId[current.fatherId!];
    }
    return false;
  }

  List<Profile> candidates({
    required String query,
    String? branchId,
  }) {
    final q = query.trim().toLowerCase();
    final sorted = profiles.toList();
    sortProfilesByAge(sorted);
    return sorted.where((p) {
      if (!canSelectAsFatherForNewMember(p, byId, patriarchId)) return false;
      if (branchId != null && !isInBranch(p.id, branchId)) return false;
      if (q.isEmpty) return true;
      final lineage = (lineageById[p.id] ?? p.fullName).toLowerCase();
      return p.fullName.toLowerCase().contains(q) || lineage.contains(q);
    }).toList();
  }
}

class _AddFamilyMemberDialog extends StatefulWidget {
  const _AddFamilyMemberDialog({
    required this.l10n,
    required this.profiles,
    required this.onSave,
    this.suggestedFather,
  });

  final AppLocalizations l10n;
  final List<Profile> profiles;
  final Profile? suggestedFather;
  final Future<void> Function(
    String fullName,
    String fatherId,
    Demographic demographic,
    String? phone,
  ) onSave;

  @override
  State<_AddFamilyMemberDialog> createState() => _AddFamilyMemberDialogState();
}

class _AddFamilyMemberDialogState extends State<_AddFamilyMemberDialog> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _fatherSearchCtrl = TextEditingController();

  late final _FatherPickerIndex _index;

  Profile? _selectedFather;
  String? _branchFilterId;
  Demographic _demographic = Demographic.adult;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _index = _FatherPickerIndex.fromProfiles(widget.profiles);
    _selectedFather = widget.suggestedFather;
    if (_selectedFather != null) {
      for (final branch in _index.branches) {
        if (_index.isInBranch(_selectedFather!.id, branch.id)) {
          _branchFilterId = branch.id;
          break;
        }
      }
    }
    _fatherSearchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _fatherSearchCtrl.dispose();
    super.dispose();
  }

  List<Profile> get _fatherOptions => _index.candidates(
        query: _fatherSearchCtrl.text,
        branchId: _branchFilterId,
      );

  String _lineageLabel(Profile profile) =>
      _index.lineageById[profile.id] ?? profile.fullName;

  Future<void> _submit() async {
    final l10n = widget.l10n;
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = l10n.t('add_member_name_required'));
      return;
    }
    if (_selectedFather == null) {
      setState(() => _error = l10n.t('add_member_father_required'));
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final phone = _phoneCtrl.text.trim();
      await widget.onSave(
        name,
        _selectedFather!.id,
        _demographic,
        phone.isEmpty ? null : phone,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final fathers = _fatherOptions;
    final visible = fathers.take(40).toList();

    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.t('add_family_member'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: _saving ? null : () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.t('add_family_member_hint'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameCtrl,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: l10n.t('full_name'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.t('select_father'),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.t('add_member_father_search_hint'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                    ),
                    if (_index.branches.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String?>(
                        value: _branchFilterId,
                        decoration: InputDecoration(
                          labelText: l10n.t('filter_by_branch'),
                        ),
                        items: [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text(l10n.t('all_branches')),
                          ),
                          ..._index.branches.map(
                            (b) => DropdownMenuItem<String?>(
                              value: b.id,
                              child: Text(
                                l10n
                                    .t('branch_of_name')
                                    .replaceAll('{name}', b.fullName),
                              ),
                            ),
                          ),
                        ],
                        onChanged: _saving
                            ? null
                            : (v) => setState(() => _branchFilterId = v),
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextField(
                      controller: _fatherSearchCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.t('search_father_lineage'),
                        hintText: l10n.t('add_member_father_search_example'),
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _fatherSearchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _fatherSearchCtrl.clear();
                                },
                              )
                            : null,
                      ),
                    ),
                    if (_selectedFather != null) ...[
                      const SizedBox(height: 12),
                      Card(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: ListTile(
                          leading: const Icon(Icons.check_circle),
                          title: Text(
                            _selectedFather!.fullName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(_lineageLabel(_selectedFather!)),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () =>
                                setState(() => _selectedFather = null),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    if (visible.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(l10n.t('no_search_results')),
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
                        final selected = _selectedFather?.id == father.id;
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
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              _lineageLabel(father),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            isThreeLine: true,
                            onTap: () =>
                                setState(() => _selectedFather = father),
                          ),
                        );
                      }),
                      if (fathers.length > visible.length)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            l10n
                                .t('father_picker_narrow_search')
                                .replaceAll(
                                  '{count}',
                                  '${fathers.length - visible.length}',
                                ),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                    ],
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Demographic>(
                      value: _demographic,
                      decoration: InputDecoration(
                        labelText: l10n.t('demographic'),
                      ),
                      items: Demographic.values
                          .map(
                            (d) => DropdownMenuItem(
                              value: d,
                              child: Text(
                                switch (d) {
                                  Demographic.adult =>
                                    l10n.t('demographic_adult'),
                                  Demographic.student =>
                                    l10n.t('demographic_student'),
                                  Demographic.child =>
                                    l10n.t('demographic_child'),
                                },
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: _saving
                          ? null
                          : (v) {
                              if (v != null) setState(() => _demographic = v);
                            },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: l10n.t('phone'),
                        hintText: l10n.t('phone_hint'),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _saving ? null : () => Navigator.pop(context, false),
                    child: Text(l10n.t('cancel')),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _saving ? null : _submit,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.t('add_family_member')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
