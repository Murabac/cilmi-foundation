import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/father_picker_index.dart';
import 'father_picker_section.dart';

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

  late final FatherPickerIndex _index;

  Profile? _selectedFather;
  String? _branchFilterId;
  String? _subBranchFilterId;
  String? _fatherFilterId;
  Demographic _demographic = Demographic.adult;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _index = FatherPickerIndex.fromProfiles(widget.profiles);
    _selectedFather = widget.suggestedFather;
    if (_selectedFather != null) {
      _index.applyInitialBranchForFather(
        _selectedFather!,
        (id) => _branchFilterId = id,
        setSubBranchId: (id) => _subBranchFilterId = id,
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  List<Profile> get _fatherOptions => _index.candidates(
        branchId: _branchFilterId,
        subBranchId: _subBranchFilterId,
        fatherFilterId: _fatherFilterId,
      );

  void _onBranchChanged(String? branchId) {
    setState(() {
      _branchFilterId = branchId;
      _subBranchFilterId = null;
      _fatherFilterId = null;
      if (_selectedFather != null &&
          branchId != null &&
          !_index.branchIndex.isInBranch(_selectedFather!.id, branchId)) {
        _selectedFather = null;
      }
    });
  }

  void _onSubBranchChanged(String? subBranchId) {
    setState(() {
      _subBranchFilterId = subBranchId;
      _fatherFilterId = null;
      if (_selectedFather != null &&
          subBranchId != null &&
          !_index.branchIndex.isInBranch(_selectedFather!.id, subBranchId)) {
        _selectedFather = null;
      }
    });
  }

  void _onFatherFilterChanged(String? fatherId) {
    setState(() {
      _fatherFilterId = fatherId;
      if (_selectedFather != null &&
          fatherId != null &&
          !_index.branchIndex.isDescendantOf(_selectedFather!.id, fatherId) &&
          _selectedFather!.id != fatherId) {
        _selectedFather = null;
      }
    });
  }

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
                    FatherPickerSection(
                      index: _index,
                      l10n: l10n,
                      branchFilterId: _branchFilterId,
                      subBranchFilterId: _subBranchFilterId,
                      fatherFilterId: _fatherFilterId,
                      selectedFather: _selectedFather,
                      onBranchChanged: _onBranchChanged,
                      onSubBranchChanged: _onSubBranchChanged,
                      onFatherFilterChanged: _onFatherFilterChanged,
                      onFatherSelected: (father) =>
                          setState(() => _selectedFather = father),
                      fatherOptions: fathers,
                      enabled: !_saving,
                    ),
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
