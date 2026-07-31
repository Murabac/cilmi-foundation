import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../theme/member_status_theme.dart';
import '../utils/branch_filter.dart';
import '../utils/father_picker_index.dart';
import '../utils/lineage_name.dart';
import '../utils/phone_utils.dart';
import 'father_picker_section.dart';
import 'widgets.dart';

Future<void> showMemberBusinessCard(
  BuildContext context,
  WidgetRef ref,
  Profile profile,
) async {
  final l10n = await ref.read(localizationsProvider.future);
  if (!context.mounted) return;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _MemberBusinessCardSheet(
      profileId: profile.id,
      l10n: l10n,
    ),
  );
}

class _MemberBusinessCardSheet extends ConsumerStatefulWidget {
  const _MemberBusinessCardSheet({
    required this.profileId,
    required this.l10n,
  });

  final String profileId;
  final AppLocalizations l10n;

  @override
  ConsumerState<_MemberBusinessCardSheet> createState() =>
      _MemberBusinessCardSheetState();
}

class _MemberBusinessCardSheetState
    extends ConsumerState<_MemberBusinessCardSheet> {
  bool _editing = false;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(_profileProvider(widget.profileId));
    final currentAsync = ref.watch(currentProfileProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (_, scrollCtrl) {
        return profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(24),
            child: ErrorView(message: e.toString()),
          ),
          data: (profile) {
            final current = currentAsync.valueOrNull;
            final canEdit = current?.role.canManageCare ?? false;

            return ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_editing && canEdit)
                  _AdminProfileEditForm(
                    profile: profile,
                    l10n: widget.l10n,
                    onCancel: () => setState(() => _editing = false),
                    onSaved: () {
                      ref.invalidate(_profileProvider(widget.profileId));
                      ref.invalidate(profileLineageNameProvider(widget.profileId));
                      ref.invalidate(profileLineageDisplayProvider(widget.profileId));
                      ref.invalidate(allProfilesProvider);
                      ref.invalidate(fullLineageTreeProvider);
                      setState(() => _editing = false);
                    },
                  )
                else ...[
                  MemberBusinessCardContent(profile: profile, l10n: widget.l10n),
                  if (canEdit) ...[
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () => setState(() => _editing = true),
                      icon: const Icon(Icons.edit),
                      label: Text(widget.l10n.t('edit_member')),
                    ),
                  ],
                ],
              ],
            );
          },
        );
      },
    );
  }
}

final _profileProvider =
    FutureProvider.family<Profile, String>((ref, id) async {
  return ref.read(profileServiceProvider).getProfileById(id).then(
        (p) => p ?? (throw Exception('Profile not found')),
      );
});

class MemberBusinessCardContent extends ConsumerWidget {
  const MemberBusinessCardContent({
    super.key,
    required this.profile,
    required this.l10n,
  });

  final Profile profile;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratingColor = CareRatingTheme.colorFor(profile.careRating);
    final careLevel = CareRatingTheme.normalize(profile.careRating);
    final dash = l10n.t('not_set');
    final lineageAsync = ref.watch(profileLineageDisplayProvider(profile.id));

    return Card(
      elevation: 4,
      shadowColor: ratingColor.withValues(alpha: 0.25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: ratingColor.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _Avatar(profile: profile, size: 88),
            const SizedBox(height: 16),
            lineageAsync.when(
              loading: () => Text(
                profile.fullName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              error: (_, __) => Text(
                profile.fullName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              data: (info) => Column(
                children: [
                  Text(
                    info.displayName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (info.subtitleKind != null && info.subtitleText != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      info.subtitleKind == LineageSubtitleKind.bornToMother
                          ? l10n
                              .t('born_to_mother')
                              .replaceAll('{name}', info.subtitleText!)
                          : l10n
                              .t('son_of_lineage')
                              .replaceAll('{lineage}', info.subtitleText!),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.grey.shade600,
                            fontSize: 10,
                            height: 1.2,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            _PhoneCardRow(
              profile: profile,
              l10n: l10n,
              dash: dash,
            ),
            _CardRow(
              icon: Icons.favorite_border,
              label: l10n.t('marital_status'),
              valueWidget: Align(
                alignment: Alignment.centerLeft,
                child: MemberStatusBadge(profile: profile, l10n: l10n),
              ),
              value: MemberStatusTheme.labelKey(
                        demographic: profile.demographic,
                        maritalStatus: profile.maritalStatus,
                      ) !=
                      null
                  ? l10n.t(
                      MemberStatusTheme.labelKey(
                        demographic: profile.demographic,
                        maritalStatus: profile.maritalStatus,
                      )!,
                    )
                  : dash,
              valueColor: MemberStatusTheme.colorFor(
                demographic: profile.demographic,
                maritalStatus: profile.maritalStatus,
              ),
            ),
            _CardRow(
              icon: Icons.health_and_safety_outlined,
              label: l10n.t('care_rating'),
              value:
                  '$careLevel · ${l10n.t(CareRatingTheme.labelKey(careLevel))}',
              valueColor: ratingColor,
            ),
            _CardRow(
              icon: Icons.work_outline,
              label: l10n.t('occupation'),
              value: profile.occupation?.isNotEmpty == true
                  ? profile.occupation!
                  : dash,
            ),
            _CardRow(
              icon: Icons.location_city_outlined,
              label: l10n.t('city'),
              value:
                  profile.city?.isNotEmpty == true ? profile.city! : dash,
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.profile, this.size = 64});

  final Profile profile;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = CareRatingTheme.colorFor(profile.careRating);
    final initial =
        profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : '?';

    if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(profile.avatarUrl!),
        onBackgroundImageError: (_, __) {},
      );
    }

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: color.withValues(alpha: 0.15),
      child: Text(
        initial,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _PhoneCardRow extends StatelessWidget {
  const _PhoneCardRow({
    required this.profile,
    required this.l10n,
    required this.dash,
  });

  final Profile profile;
  final AppLocalizations l10n;
  final String dash;

  Future<void> _openUri(
    BuildContext context,
    Uri uri,
    String failKey,
  ) async {
    final launched =
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t(failKey))),
      );
    }
  }

  Future<void> _call(BuildContext context) async {
    final phone = profile.phoneNumber?.trim();
    if (phone == null || phone.isEmpty) return;
    final digits = normalizePhoneDigits(phone);
    if (digits.isEmpty) return;
    await _openUri(context, Uri.parse('tel:+$digits'), 'call_failed');
  }

  Future<void> _whatsApp(BuildContext context) async {
    final phone = profile.phoneNumber?.trim();
    if (phone == null || phone.isEmpty) return;
    final digits = normalizePhoneDigits(phone);
    if (digits.isEmpty) return;
    await _openUri(
      context,
      Uri.parse('https://wa.me/$digits'),
      'whatsapp_failed',
    );
  }

  @override
  Widget build(BuildContext context) {
    final phone = profile.phoneNumber?.trim();
    final hasPhone = phone != null && phone.isNotEmpty;
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.phone_android, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('mobile'),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 2),
                if (!hasPhone)
                  Text(
                    dash,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  )
                  else
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _call(context),
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              displayPhone(phone),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: primary,
                                    decoration: TextDecoration.underline,
                                    decorationColor: primary,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.t('call'),
                        onPressed: () => _call(context),
                        visualDensity: VisualDensity.compact,
                        icon: SvgPicture.asset(
                          'assets/icons/call.svg',
                          width: 28,
                          height: 28,
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.t('whatsapp'),
                        onPressed: () => _whatsApp(context),
                        visualDensity: VisualDensity.compact,
                        icon: SvgPicture.asset(
                          'assets/icons/whatsapp.svg',
                          width: 28,
                          height: 28,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardRow extends StatelessWidget {
  const _CardRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.valueWidget,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 2),
                valueWidget ??
                    Text(
                      value,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: valueColor,
                          ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminProfileEditForm extends ConsumerStatefulWidget {
  const _AdminProfileEditForm({
    required this.profile,
    required this.l10n,
    required this.onCancel,
    required this.onSaved,
  });

  final Profile profile;
  final AppLocalizations l10n;
  final VoidCallback onCancel;
  final VoidCallback onSaved;

  @override
  ConsumerState<_AdminProfileEditForm> createState() =>
      _AdminProfileEditFormState();
}

class _AdminProfileEditFormState extends ConsumerState<_AdminProfileEditForm> {
  late final _phoneCtrl =
      TextEditingController(text: widget.profile.phoneNumber ?? '');
  late final _fullNameCtrl =
      TextEditingController(text: widget.profile.fullName);
  late final _birthOrderCtrl = TextEditingController(
    text: widget.profile.birthOrder > 0
        ? '${widget.profile.birthOrder}'
        : '',
  );
  late final _occupationCtrl =
      TextEditingController(text: widget.profile.occupation ?? '');
  late final _cityCtrl =
      TextEditingController(text: widget.profile.city ?? '');
  late MaritalStatus? _maritalStatus = widget.profile.maritalStatus;
  late Demographic _demographic = widget.profile.demographic;
  late String? _statusChoice = widget.profile.demographic == Demographic.child
      ? 'child'
      : widget.profile.maritalStatus?.name;
  late int _careRating = CareRatingTheme.normalize(widget.profile.careRating);
  Profile? _selectedFather;
  String? _branchFilterId;
  String? _subBranchFilterId;
  String? _fatherFilterId;
  FatherPickerIndex? _pickerIndex;
  bool _pickerInitialized = false;
  Uint8List? _imageBytes;
  String? _imageExt;
  bool _saving = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _fullNameCtrl.dispose();
    _birthOrderCtrl.dispose();
    _occupationCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final ext = file.path.split('.').last.toLowerCase();
    setState(() {
      _imageBytes = bytes;
      _imageExt = ext == 'png' ? 'png' : 'jpg';
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final service = ref.read(profileServiceProvider);
      var avatarUrl = widget.profile.avatarUrl;

      if (_imageBytes != null && _imageExt != null) {
        avatarUrl = await service.uploadAvatar(
          widget.profile.id,
          _imageBytes!,
          _imageExt!,
        );
      }

      final fullName = _fullNameCtrl.text.trim();
      if (fullName.isEmpty) {
        throw Exception(widget.l10n.t('add_member_name_required'));
      }

      final birthOrderText = _birthOrderCtrl.text.trim();
      final birthOrder = birthOrderText.isEmpty
          ? 0
          : int.tryParse(birthOrderText) ?? widget.profile.birthOrder;

      final allProfiles = await ref.read(allProfilesProvider.future);
      final branchIndex = BranchFilterIndex.fromProfiles(allProfiles);
      final isPatriarch = branchIndex.patriarchId == widget.profile.id;

      if (!isPatriarch && _selectedFather == null) {
        throw Exception(widget.l10n.t('add_member_father_required'));
      }

      final isChildStatus = _statusChoice == 'child';
      await service.updateMemberProfileAdmin(
        profileId: widget.profile.id,
        phoneNumber: _phoneCtrl.text.trim(),
        maritalStatus: isChildStatus ? null : _maritalStatus,
        clearMaritalStatus: isChildStatus || _statusChoice == null,
        demographic: isChildStatus
            ? Demographic.child
            : (_demographic == Demographic.child
                ? Demographic.adult
                : _demographic),
        occupation: _occupationCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        careRating: _careRating,
        avatarUrl: avatarUrl,
        fullName: fullName,
        clearFatherId: isPatriarch,
        fatherId: isPatriarch ? null : _selectedFather!.id,
        birthOrder: birthOrder,
      );

      widget.onSaved();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _initFatherPicker(FatherPickerIndex index) {
    if (_pickerInitialized) return;
    _pickerInitialized = true;
    _pickerIndex = index;

    final fatherId = widget.profile.fatherId;
    if (fatherId != null) {
      _selectedFather = index.branchIndex.byId[fatherId];
      if (_selectedFather != null) {
        index.applyInitialBranchForFather(
          _selectedFather!,
          (id) => _branchFilterId = id,
          setSubBranchId: (id) => _subBranchFilterId = id,
        );
      }
    }
  }

  void _onBranchChanged(String? branchId) {
    setState(() {
      _branchFilterId = branchId;
      _subBranchFilterId = null;
      _fatherFilterId = null;
      if (_selectedFather != null &&
          branchId != null &&
          _pickerIndex != null &&
          !_pickerIndex!.branchIndex.isInBranch(_selectedFather!.id, branchId)) {
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
          _pickerIndex != null &&
          !_pickerIndex!.branchIndex
              .isInBranch(_selectedFather!.id, subBranchId)) {
        _selectedFather = null;
      }
    });
  }

  void _onFatherFilterChanged(String? fatherId) {
    setState(() {
      _fatherFilterId = fatherId;
      if (_selectedFather != null &&
          fatherId != null &&
          _pickerIndex != null &&
          !_pickerIndex!.branchIndex.isDescendantOf(
            _selectedFather!.id,
            fatherId,
          ) &&
          _selectedFather!.id != fatherId) {
        _selectedFather = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final allProfiles = ref.watch(allProfilesProvider).valueOrNull;
    if (allProfiles == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final index = FatherPickerIndex.fromProfiles(allProfiles);
    _initFatherPicker(index);
    final isPatriarch = index.branchIndex.patriarchId == widget.profile.id;
    final fatherOptions = index.candidates(
      branchId: _branchFilterId,
      subBranchId: _subBranchFilterId,
      fatherFilterId: _fatherFilterId,
      editingProfileId: widget.profile.id,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.t('edit_member'),
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Center(
          child: Stack(
            children: [
              _imageBytes != null
                  ? CircleAvatar(
                      radius: 44,
                      backgroundImage: MemoryImage(_imageBytes!),
                    )
                  : _Avatar(profile: widget.profile, size: 88),
              Positioned(
                bottom: 0,
                right: 0,
                child: IconButton.filled(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.camera_alt, size: 18),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.t('lineage_section'),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.t('edit_lineage_hint'),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _fullNameCtrl,
          decoration: InputDecoration(
            labelText: l10n.t('member_full_name'),
            helperText: treeMotherLink(widget.profile, index.branchIndex.byId) !=
                    null
                ? l10n.t('daughter_child_name_hint')
                : null,
          ),
        ),
        const SizedBox(height: 12),
        if (!isPatriarch) ...[
          FatherPickerSection(
            index: index,
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
            fatherOptions: fatherOptions,
            enabled: !_saving,
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: _birthOrderCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: l10n.t('birth_order'),
            helperText: l10n.t('birth_order_hint'),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(labelText: l10n.t('mobile')),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String?>(
          decoration: InputDecoration(labelText: l10n.t('marital_status')),
          initialValue: _statusChoice,
          items: [
            DropdownMenuItem(value: null, child: Text(l10n.t('not_set'))),
            DropdownMenuItem(
              value: 'single',
              child: Text(
                l10n.t('marital_single'),
                style: const TextStyle(
                  color: MemberStatusTheme.single,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            DropdownMenuItem(
              value: 'married',
              child: Text(
                l10n.t('marital_married'),
                style: const TextStyle(
                  color: MemberStatusTheme.married,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            DropdownMenuItem(
              value: 'deceased',
              child: Text(
                l10n.t('marital_deceased'),
                style: const TextStyle(
                  color: MemberStatusTheme.deceased,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            DropdownMenuItem(
              value: 'child',
              child: Text(
                l10n.t('demographic_child'),
                style: const TextStyle(
                  color: MemberStatusTheme.child,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          onChanged: (v) => setState(() {
            _statusChoice = v;
            _maritalStatus = switch (v) {
              'single' => MaritalStatus.single,
              'married' => MaritalStatus.married,
              'deceased' => MaritalStatus.deceased,
              _ => null,
            };
            if (v == 'child') {
              _demographic = Demographic.child;
            } else if (_demographic == Demographic.child) {
              _demographic = Demographic.adult;
            }
          }),
        ),
        const SizedBox(height: 12),
        Text(l10n.t('care_rating')),
        CareRatingPicker(
          value: _careRating,
          l10n: l10n,
          onChanged: (v) => setState(() => _careRating = v),
        ),
        TextField(
          controller: _occupationCtrl,
          decoration: InputDecoration(labelText: l10n.t('occupation')),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _cityCtrl,
          decoration: InputDecoration(labelText: l10n.t('city')),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _saving ? null : widget.onCancel,
                child: Text(l10n.t('cancel')),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.t('save')),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
