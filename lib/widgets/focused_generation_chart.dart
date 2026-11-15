import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/lineage_tree.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/payment_exempt.dart';

/// Focused 3-generation Geed view: father · you + siblings · children.
class FocusedGenerationChart extends StatelessWidget {
  const FocusedGenerationChart({
    super.key,
    required this.root,
    required this.focusId,
    required this.l10n,
    required this.viewerId,
    required this.onMemberTap,
    required this.onFocusChange,
  });

  final TreeNode root;
  final String focusId;
  final AppLocalizations l10n;
  final String? viewerId;
  final ValueChanged<Profile> onMemberTap;
  final ValueChanged<String> onFocusChange;

  TreeNode? _find(String id) => findNodeInTree(root, id);

  List<Profile> _allProfiles() {
    final out = <Profile>[];
    void walk(TreeNode n) {
      out.add(n.profile);
      for (final c in n.children) {
        walk(c);
      }
    }

    walk(root);
    return out;
  }

  int _generation(Profile profile, List<Profile> all) =>
      generationsFromPatriarch(profile, all) ?? 0;

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String _shortName(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length <= 2) return name.trim();
    return '${parts[0]} ${parts[1]}';
  }

  void _select(Profile profile) {
    onMemberTap(profile);
    onFocusChange(profile.id);
  }

  @override
  Widget build(BuildContext context) {
    final focus = _find(focusId) ?? root;
    final all = _allProfiles();
    final fatherId = focus.profile.fatherId;
    final parent = fatherId == null ? null : _find(fatherId);
    final siblings = parent?.children ?? [focus];
    final children = focus.children;

    final genFocus = _generation(focus.profile, all);
    final genParent =
        parent != null ? _generation(parent.profile, all) : (genFocus - 1).clamp(0, 99);
    final genChild = genFocus + 1;

    final householdName = l10n.t('reer_household').replaceAll(
          '{name}',
          parent?.profile.fullName ?? focus.profile.fullName,
        );

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: BrandColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: BrandColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  householdName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: BrandColors.ink,
                  ),
                ),
              ),
              if (parent != null)
                Material(
                  color: BrandColors.mint,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => onFocusChange(parent.profile.id),
                    borderRadius: BorderRadius.circular(12),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.arrow_upward_rounded,
                              size: 16,
                              color: BrandColors.teal,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.t('generation_up'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: BrandColors.teal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GenLabels(
                items: [
                  (genParent, l10n.t('gen_father')),
                  (genFocus, l10n.t('gen_you')),
                  (genChild, l10n.t('gen_children')),
                ],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  children: [
                    if (parent != null)
                      _PersonNode(
                        profile: parent.profile,
                        initials: _initials(parent.profile.fullName),
                        name: _shortName(parent.profile.fullName),
                        relation: l10n.t('relation_your_father'),
                        emphasized: false,
                        isYou: parent.profile.id == viewerId,
                        onTap: () => _select(parent.profile),
                      )
                    else
                      const SizedBox(height: 88),
                    _Connector(
                      childCount: siblings.length.clamp(1, 4),
                    ),
                    _SiblingRow(
                      siblings: siblings,
                      focusId: focus.profile.id,
                      viewerId: viewerId,
                      l10n: l10n,
                      initialsFor: _initials,
                      shortName: _shortName,
                      onSelect: _select,
                    ),
                    if (children.isNotEmpty) ...[
                      _Connector(
                        childCount: children.length.clamp(1, 4),
                      ),
                      _ChildRow(
                        children: children,
                        l10n: l10n,
                        initialsFor: _initials,
                        shortName: _shortName,
                        onSelect: _select,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _CareLegend(l10n: l10n),
          const SizedBox(height: 8),
          Text(
            l10n.t('tree_tap_hint'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: BrandColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _CareLegend extends StatelessWidget {
  const _CareLegend({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final items = [
      (CareRatingTheme.colorFor(1), l10n.t('care_group_1')),
      (CareRatingTheme.colorFor(2), l10n.t('care_group_2')),
      (CareRatingTheme.colorFor(3), l10n.t('care_group_3')),
    ];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 14,
      runSpacing: 6,
      children: [
        for (final item in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: item.$1,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                item.$2,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: BrandColors.muted,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _GenLabels extends StatelessWidget {
  const _GenLabels({required this.items});

  final List<(int, String)> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              SizedBox(
                height: 36,
                child: CustomPaint(
                  painter: _DashedLinePainter(color: BrandColors.border),
                  size: const Size(48, 36),
                ),
              ),
            Column(
              children: [
                Container(
                  height: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: BrandColors.linen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'J${items[i].$1}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: BrandColors.teal,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  items[i].$2,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: BrandColors.muted,
                  ),
                ),
                // Spacer under label to roughly align with person nodes.
                const SizedBox(height: 62),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const dash = 4.0;
    var y = 0.0;
    final x = size.width / 2;
    while (y < size.height) {
      final end = (y + dash).clamp(0.0, size.height);
      canvas.drawLine(Offset(x, y), Offset(x, end), paint);
      y += dash * 2;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _Connector extends StatelessWidget {
  const _Connector({required this.childCount});

  final int childCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      width: double.infinity,
      child: CustomPaint(
        painter: _TreeConnectorPainter(
          childCount: childCount,
          color: BrandColors.muted,
        ),
      ),
    );
  }
}

class _TreeConnectorPainter extends CustomPainter {
  _TreeConnectorPainter({
    required this.childCount,
    required this.color,
  });

  final int childCount;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final midX = size.width / 2;
    final midY = size.height * 0.45;
    canvas.drawLine(Offset(midX, 0), Offset(midX, midY), paint);

    if (childCount <= 0) return;

    final xs = List.generate(childCount, (i) {
      if (childCount == 1) return midX;
      final t = (i + 0.5) / childCount;
      return size.width * t;
    });

    canvas.drawLine(Offset(xs.first, midY), Offset(xs.last, midY), paint);
    for (final x in xs) {
      canvas.drawLine(Offset(x, midY), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TreeConnectorPainter oldDelegate) =>
      oldDelegate.childCount != childCount || oldDelegate.color != color;
}

class _SiblingRow extends StatelessWidget {
  const _SiblingRow({
    required this.siblings,
    required this.focusId,
    required this.viewerId,
    required this.l10n,
    required this.initialsFor,
    required this.shortName,
    required this.onSelect,
  });

  final List<TreeNode> siblings;
  final String focusId;
  final String? viewerId;
  final AppLocalizations l10n;
  final String Function(String) initialsFor;
  final String Function(String) shortName;
  final ValueChanged<Profile> onSelect;

  @override
  Widget build(BuildContext context) {
    final focusIndex = siblings.indexWhere((s) => s.profile.id == focusId);
    final safeFocus = focusIndex < 0 ? 0 : focusIndex;

    // Show up to 1 sibling left, focus, 1 sibling right, then +N.
    final left = safeFocus > 0 ? siblings[safeFocus - 1] : null;
    final center = siblings[safeFocus];
    final right =
        safeFocus + 1 < siblings.length ? siblings[safeFocus + 1] : null;
    final shownIds = {
      if (left != null) left.profile.id,
      center.profile.id,
      if (right != null) right.profile.id,
    };
    final overflow = siblings.length - shownIds.length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (left != null)
            _PersonNode(
              profile: left.profile,
              initials: initialsFor(left.profile.fullName),
              name: shortName(left.profile.fullName).split(' ').first,
              relation: l10n.t('relation_sibling'),
              emphasized: false,
              isYou: left.profile.id == viewerId,
              onTap: () => onSelect(left.profile),
            ),
          if (left != null) const SizedBox(width: 4),
          _PersonNode(
            profile: center.profile,
            initials: initialsFor(center.profile.fullName),
            name: shortName(center.profile.fullName),
            relation: center.profile.id == viewerId
                ? l10n.t('relation_you')
                : l10n.t('relation_selected'),
            emphasized: true,
            isYou: center.profile.id == viewerId,
            large: true,
            onTap: () => onSelect(center.profile),
          ),
          if (right != null) ...[
            const SizedBox(width: 4),
            _PersonNode(
              profile: right.profile,
              initials: initialsFor(right.profile.fullName),
              name: shortName(right.profile.fullName).split(' ').first,
              relation: l10n.t('relation_sibling'),
              emphasized: false,
              isYou: right.profile.id == viewerId,
              onTap: () => onSelect(right.profile),
            ),
          ],
          if (overflow > 0) ...[
            const SizedBox(width: 4),
            _OverflowChip(
              count: overflow,
              label: l10n.t('relation_more_siblings'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChildRow extends StatelessWidget {
  const _ChildRow({
    required this.children,
    required this.l10n,
    required this.initialsFor,
    required this.shortName,
    required this.onSelect,
  });

  final List<TreeNode> children;
  final AppLocalizations l10n;
  final String Function(String) initialsFor;
  final String Function(String) shortName;
  final ValueChanged<Profile> onSelect;

  @override
  Widget build(BuildContext context) {
    final visible = children.take(3).toList();
    final overflow = children.length - visible.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < visible.length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          _PersonNode(
            profile: visible[i].profile,
            initials: initialsFor(visible[i].profile.fullName),
            name: shortName(visible[i].profile.fullName).split(' ').first,
            relation: i == 0 &&
                    (visible[i].profile.birthOrder <= 1)
                ? l10n.t('relation_child_first')
                : l10n.t('relation_child'),
            emphasized: false,
            isYou: false,
            onTap: () => onSelect(visible[i].profile),
          ),
        ],
        if (overflow > 0) ...[
          const SizedBox(width: 4),
          _OverflowChip(
            count: overflow,
            label: l10n.t('relation_more_children'),
          ),
        ],
      ],
    );
  }
}

class _OverflowChip extends StatelessWidget {
  const _OverflowChip({required this.count, required this.label});

  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: BrandColors.surface,
              border: Border.all(color: BrandColors.muted, width: 1.5),
            ),
            child: Text(
              '+$count',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: BrandColors.teal,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: BrandColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonNode extends StatelessWidget {
  const _PersonNode({
    required this.profile,
    required this.initials,
    required this.name,
    required this.relation,
    required this.emphasized,
    required this.isYou,
    required this.onTap,
    this.large = false,
  });

  final Profile profile;
  final String initials;
  final String name;
  final String relation;
  final bool emphasized;
  final bool isYou;
  final bool large;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = (large || emphasized) ? 60.0 : 52.0;
    final care = CareRatingTheme.colorFor(profile.careRating);
    final fill = (isYou || emphasized) ? BrandColors.teal : BrandColors.mint;
    final fg = (isYou || emphasized) ? BrandColors.linen : BrandColors.teal;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        child: SizedBox(
          width: large ? 86 : 78,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: size,
                    height: size,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: fill,
                      border: (isYou || emphasized)
                          ? Border.all(color: BrandColors.gold, width: 3)
                          : null,
                    ),
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: large ? 18 : 16,
                        color: fg,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: care,
                        border: Border.all(color: BrandColors.surface, width: 2.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: emphasized ? 14 : 13.5,
                  fontWeight: FontWeight.w800,
                  color: BrandColors.ink,
                ),
              ),
              Text(
                relation,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: BrandColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
