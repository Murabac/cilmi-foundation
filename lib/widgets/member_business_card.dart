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
import '../models/lineage_tree.dart';
import '../utils/branch_filter.dart';
import '../utils/father_picker_index.dart';
import '../utils/lineage_name.dart';
import '../utils/payment_exempt.dart';
import '../utils/phone_utils.dart';
import 'abtirsiin_lineage_view.dart';
import 'father_picker_section.dart';
import 'widgets.dart';

Future<void> showMemberBusinessCard(
  BuildContext context,
  WidgetRef ref,
  Profile profile, {
  ValueChanged<String>? onViewBranch,
}) async {
  final l10n = await ref.read(localizationsProvider.future);
  if (!context.mounted) return;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: BrandColors.surface,
    barrierColor: BrandColors.teal.withValues(alpha: 0.48),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => _MemberBusinessCardSheet(
      profileId: profile.id,
      l10n: l10n,
      onViewBranch: onViewBranch,
    ),
  );
}

class _MemberBusinessCardSheet extends ConsumerStatefulWidget {
  const _MemberBusinessCardSheet({
    required this.profileId,
    required this.l10n,
    this.onViewBranch,
  });

  final String profileId;
  final AppLocalizations l10n;
  final ValueChanged<String>? onViewBranch;

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
      initialChildSize: 0.78,
      minChildSize: 0.45,
      maxChildSize: 0.94,
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
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: BrandColors.border,
                      borderRadius: BorderRadius.circular(3),
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
                      ref.invalidate(
                          profileLineageNameProvider(widget.profileId));
                      ref.invalidate(
                          profileLineageDisplayProvider(widget.profileId));
                      ref.invalidate(allProfilesProvider);
                      ref.invalidate(fullLineageTreeProvider);
                      setState(() => _editing = false);
                    },
                  )
                else ...[
                  MemberBusinessCardContent(
                    profile: profile,
                    l10n: widget.l10n,
                    sheetMode: true,
                    onClose: () => Navigator.of(context).pop(),
                    onFocusMember: widget.onViewBranch,
                    onViewBranch: widget.onViewBranch == null
                        ? null
                        : () {
                            final id = profile.id;
                            Navigator.of(context).pop();
                            widget.onViewBranch!(id);
                          },
                  ),
                  if (canEdit) ...[
                    const SizedBox(height: 16),
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

Future<void> _showChildrenPicker({
  required BuildContext context,
  required WidgetRef ref,
  required AppLocalizations l10n,
  required List<TreeNode> children,
  required ValueChanged<String>? onFocusMember,
}) {
  String initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: BrandColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      final bottom = MediaQuery.paddingOf(sheetContext).bottom;
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.7,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: BrandColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.t('geed_pick_children'),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: BrandColors.ink,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close_rounded),
                      style: IconButton.styleFrom(
                        minimumSize: const Size(48, 48),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: BrandColors.border),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(8, 8, 8, 16 + bottom),
                  itemCount: children.length,
                  separatorBuilder: (_, _) => const Divider(
                    height: 1,
                    indent: 72,
                    color: BrandColors.border,
                  ),
                  itemBuilder: (context, index) {
                    final child = children[index].profile;
                    final care = CareRatingTheme.colorFor(child.careRating);
                    return InkWell(
                      onTap: () async {
                        Navigator.pop(sheetContext);
                        if (!context.mounted) return;
                        await showMemberBusinessCard(
                          context,
                          ref,
                          child,
                          onViewBranch: onFocusMember,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: BrandColors.mint,
                                  child: Text(
                                    initials(child.fullName),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: BrandColors.teal,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: -1,
                                  bottom: -1,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: care,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: BrandColors.surface,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                child.fullName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: BrandColors.ink,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: BrandColors.muted,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class MemberBusinessCardContent extends ConsumerWidget {
  const MemberBusinessCardContent({
    super.key,
    required this.profile,
    required this.l10n,
    this.sheetMode = false,
    this.onClose,
    this.onViewBranch,
    this.onFocusMember,
  });

  final Profile profile;
  final AppLocalizations l10n;
  final bool sheetMode;
  final VoidCallback? onClose;
  final VoidCallback? onViewBranch;
  /// When set (from the tree sheet), used to focus a selected child on Geed.
  final ValueChanged<String>? onFocusMember;

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String? _relationPill(Profile? viewer) {
    if (viewer == null) return null;
    if (viewer.id == profile.id) return l10n.t('relation_you');
    if (profile.id == viewer.fatherId) {
      return l10n.t('relation_your_father');
    }
    if (profile.fatherId != null && profile.fatherId == viewer.id) {
      return l10n.t('relation_your_child');
    }
    if (profile.fatherId != null &&
        viewer.fatherId != null &&
        profile.fatherId == viewer.fatherId) {
      final base = l10n.t('relation_your_sibling');
      if (profile.birthOrder > 0 && viewer.birthOrder > 0) {
        if (profile.birthOrder < viewer.birthOrder) {
          return '$base · ${l10n.t('relation_older')}';
        }
        if (profile.birthOrder > viewer.birthOrder) {
          return '$base · ${l10n.t('relation_younger')}';
        }
      }
      return base;
    }
    if (profile.id == viewer.spouseId || viewer.id == profile.spouseId) {
      return l10n.t('relation_your_spouse');
    }
    return null;
  }

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
  Widget build(BuildContext context, WidgetRef ref) {
    final viewer = ref.watch(currentProfileProvider).valueOrNull;
    final allAsync = ref.watch(allProfilesProvider);
    final treeAsync = ref.watch(fullLineageTreeProvider);
    final care = CareRatingTheme.colorFor(profile.careRating);
    final relation = _relationPill(viewer);
    final hasPhone = (profile.phoneNumber?.trim().isNotEmpty ?? false);

    final all = allAsync.valueOrNull ?? const <Profile>[];
    final byId = {for (final p in all) p.id: p};
    final gen = all.isEmpty
        ? null
        : generationsFromPatriarch(profile, all);

    final tree = treeAsync.valueOrNull;
    final node = tree == null ? null : findNodeInTree(tree, profile.id);
    final childCount = node?.children.length ?? 0;
    final descendantCount = node?.descendantCount ?? 0;

    final nasabNames = <String>[];
    if (all.isNotEmpty) {
      final names = collectPatrilinealNames(profile, byId);
      for (final n in names) {
        nasabNames.add(lineageShortName(n));
      }
    } else {
      nasabNames.add(lineageShortName(profile.fullName));
    }

    final statusKey = MemberStatusTheme.labelKey(
      demographic: profile.demographic,
      maritalStatus: profile.maritalStatus,
    );
    final chips = <String>[
      if (statusKey != null) l10n.t(statusKey),
      if (profile.city?.trim().isNotEmpty == true) profile.city!.trim(),
      if (profile.occupation?.trim().isNotEmpty == true)
        profile.occupation!.trim(),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Avatar(profile: profile, size: 64, initials: _initials(profile.fullName)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.fullName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: BrandColors.ink,
                    ),
                  ),
                  if (relation != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      height: 26,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: BrandColors.gold.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Text(
                        relation,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: BrandColors.onGold,
                          height: 1.9,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (sheetMode && onClose != null)
              Material(
                color: BrandColors.linen,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onClose,
                  child: const SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(Icons.close_rounded, color: BrandColors.ink),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        CustomPaint(
          painter: _DashedRRectPainter(color: BrandColors.border),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('member_card_lineage'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.06 * 12,
                    color: BrandColors.muted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  nasabNames.join(' · '),
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    height: 1.45,
                    color: BrandColors.teal,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final chip in chips)
              Container(
                height: 26,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: BrandColors.linen,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  chip,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: BrandColors.ink,
                  ),
                ),
              ),
            Container(
              height: 26,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: care.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: care.withValues(alpha: 0.35)),
              ),
              child: Text(
                l10n.t(CareRatingTheme.labelKey(profile.careRating)),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: care,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                value: '$childCount',
                label: l10n.t('member_card_stat_children'),
                onTap: childCount > 0 && node != null
                    ? () => _showChildrenPicker(
                          context: context,
                          ref: ref,
                          l10n: l10n,
                          children: node.children,
                          onFocusMember: onFocusMember,
                        )
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                value: '$descendantCount',
                label: l10n.t('member_card_stat_descendants'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                value: gen == null ? '—' : 'J$gen',
                label: l10n.t('member_card_stat_generation'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _SoftActionButton(
                label: l10n.t('call'),
                onTap: hasPhone ? () => _call(context) : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.phone_rounded,
                      size: 20,
                      color: BrandColors.teal,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.t('call'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: BrandColors.teal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SoftActionButton(
                label: l10n.t('whatsapp'),
                onTap: hasPhone ? () => _whatsApp(context) : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/whatsapp.svg',
                      width: 22,
                      height: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.t('whatsapp'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: BrandColors.teal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (onViewBranch != null) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: onViewBranch,
              style: FilledButton.styleFrom(
                backgroundColor: BrandColors.teal,
                foregroundColor: BrandColors.linen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.account_tree_outlined, size: 20),
              label: Text(
                l10n.t('member_card_view_branch'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(14),
    );
    final path = Path()..addRRect(rrect);
    const dash = 5.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var dist = 0.0;
      while (dist < metric.length) {
        final next = (dist + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(dist, next), paint);
        dist = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    this.onTap,
  });

  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BrandColors.linen,
        borderRadius: BorderRadius.circular(14),
        border: onTap == null
            ? null
            : Border.all(color: BrandColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: BrandColors.teal,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: BrandColors.muted,
                  ),
                ),
              ),
              if (onTap != null)
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: BrandColors.muted,
                ),
            ],
          ),
        ],
      ),
    );

    if (onTap == null) return child;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: child,
      ),
    );
  }
}

class _SoftActionButton extends StatelessWidget {
  const _SoftActionButton({
    required this.label,
    required this.child,
    required this.onTap,
  });

  final String label;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onTap == null
          ? BrandColors.mint.withValues(alpha: 0.5)
          : BrandColors.mint,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 52,
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.profile,
    required this.initials,
    this.size = 64,
  });

  final Profile profile;
  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    final care = CareRatingTheme.colorFor(profile.careRating);

    Widget face;
    if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) {
      face = ClipOval(
        child: Image.network(
          profile.avatarUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _InitialsFace(
            initials: initials,
            size: size,
          ),
        ),
      );
    } else {
      face = _InitialsFace(initials: initials, size: size);
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          face,
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: 17,
              height: 17,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: care,
                border: Border.all(color: BrandColors.surface, width: 3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InitialsFace extends StatelessWidget {
  const _InitialsFace({required this.initials, required this.size});

  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: BrandColors.mint,
      ),
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size * 0.34,
          fontWeight: FontWeight.w800,
          color: BrandColors.teal,
        ),
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
                  : _Avatar(
                      profile: widget.profile,
                      size: 88,
                      initials: () {
                        final parts = widget.profile.fullName
                            .trim()
                            .split(RegExp(r'\s+'));
                        if (parts.isEmpty || parts.first.isEmpty) return '?';
                        if (parts.length == 1) {
                          return parts.first[0].toUpperCase();
                        }
                        return '${parts.first[0]}${parts.last[0]}'
                            .toUpperCase();
                      }(),
                    ),
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
