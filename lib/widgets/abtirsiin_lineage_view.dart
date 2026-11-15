import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../models/lineage_tree.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

/// Short name used in nasab lines (keeps "Sheekh Yoonis" as two words).
String lineageShortName(String fullName) {
  final parts = fullName.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return fullName;
  final first = parts.first.toLowerCase();
  if ((first == 'sheekh' || first == 'sheikh') && parts.length >= 2) {
    return '${parts[0]} ${parts[1]}';
  }
  return parts.first;
}

/// Abtirsiin tab: nasab card + numbered founder → you timeline.
class AbtirsiinLineageView extends StatelessWidget {
  const AbtirsiinLineageView({
    super.key,
    required this.root,
    required this.focusId,
    required this.viewerId,
    required this.l10n,
    required this.onFocusChange,
    required this.onViewInTree,
    required this.onMemberTap,
  });

  final TreeNode root;
  final String focusId;
  final String? viewerId;
  final AppLocalizations l10n;
  final ValueChanged<String> onFocusChange;
  final ValueChanged<String> onViewInTree;
  final ValueChanged<Profile> onMemberTap;

  List<TreeNode> _chainNodes() {
    final focus = findNodeInTree(root, focusId) ?? root;
    final byId = <String, TreeNode>{};
    void index(TreeNode n) {
      byId[n.profile.id] = n;
      for (final c in n.children) {
        index(c);
      }
    }

    index(root);

    final upward = <TreeNode>[];
    TreeNode? current = focus;
    final visited = <String>{};
    while (current != null && !visited.contains(current.profile.id)) {
      visited.add(current.profile.id);
      upward.add(current);
      final fatherId = current.profile.fatherId;
      current = fatherId == null ? null : byId[fatherId];
    }
    return upward.reversed.toList();
  }

  Future<void> _shareNasab(BuildContext context, String nasabText) async {
    final text = '${l10n.t('abtirsiin_yours')}\n$nasabText';
    final encoded = Uri.encodeComponent(text);
    var ok = await launchUrl(
      Uri.parse('whatsapp://send?text=$encoded'),
      mode: LaunchMode.externalApplication,
    );
    if (!ok) {
      ok = await launchUrl(
        Uri.parse('https://wa.me/?text=$encoded'),
        mode: LaunchMode.externalApplication,
      );
    }
    if (!ok && context.mounted) {
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.t('whatsapp_not_installed_copied'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chain = _chainNodes();
    if (chain.isEmpty) return const SizedBox.shrink();

    final shortNames = chain.map((n) => lineageShortName(n.profile.fullName));
    final nasabPlain = shortNames.join(' bin ');
    final genCount = chain.length;
    final focusNode = chain.last;
    final isViewerFocus = viewerId != null && focusNode.profile.id == viewerId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _NasabCard(
          l10n: l10n,
          chain: chain,
          genCount: genCount,
          onShare: () => _shareNasab(context, nasabPlain),
          onViewInTree: () => onViewInTree(focusNode.profile.id),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.t('abtirsiin_from_founder'),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.06 * 13,
            color: BrandColors.muted,
          ),
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < chain.length; i++)
          _TimelineRow(
            index: i + 1,
            node: chain[i],
            father: i > 0 ? chain[i - 1] : null,
            isFirst: i == 0,
            isLast: i == chain.length - 1,
            isYou: isViewerFocus && i == chain.length - 1,
            isYourFather: isViewerFocus && i == chain.length - 2,
            l10n: l10n,
            onTap: () {
              onFocusChange(chain[i].profile.id);
              onMemberTap(chain[i].profile);
            },
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _NasabCard extends StatelessWidget {
  const _NasabCard({
    required this.l10n,
    required this.chain,
    required this.genCount,
    required this.onShare,
    required this.onViewInTree,
  });

  final AppLocalizations l10n;
  final List<TreeNode> chain;
  final int genCount;
  final VoidCallback onShare;
  final VoidCallback onViewInTree;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: BrandColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BrandColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.t('abtirsiin_yours'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.06 * 13,
                    color: BrandColors.muted,
                  ),
                ),
              ),
              Text(
                l10n.t('abtirsiin_generations').replaceAll('{count}', '$genCount'),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: BrandColors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                for (var i = 0; i < chain.length; i++) ...[
                  if (i > 0)
                    TextSpan(
                      text: ' bin ',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                        color: BrandColors.ink,
                      ),
                    ),
                  TextSpan(
                    text: lineageShortName(chain[i].profile.fullName),
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      height: 1.45,
                      color: BrandColors.teal,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SoftAction(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: l10n.t('abtirsiin_share'),
                  onTap: onShare,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SoftAction(
                  icon: Icons.account_tree_outlined,
                  label: l10n.t('abtirsiin_view_tree'),
                  onTap: onViewInTree,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SoftAction extends StatelessWidget {
  const _SoftAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BrandColors.mint,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: BrandColors.teal),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: BrandColors.teal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.index,
    required this.node,
    required this.father,
    required this.isFirst,
    required this.isLast,
    required this.isYou,
    required this.isYourFather,
    required this.l10n,
    required this.onTap,
  });

  final int index;
  final TreeNode node;
  final TreeNode? father;
  final bool isFirst;
  final bool isLast;
  final bool isYou;
  final bool isYourFather;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  String _subtitle() {
    if (isFirst) return l10n.t('abtirsiin_family_father');

    final fatherName = father == null
        ? ''
        : lineageShortName(father!.profile.fullName);
    final ina = l10n.t('abtirsiin_son_of').replaceAll('{name}', fatherName);

    if (isYou) {
      return '${l10n.t('relation_you')} · $ina';
    }
    if (isYourFather) {
      return '$ina · ${l10n.t('relation_your_father')}';
    }

    // Note branch count for multi-son nodes near the foundation.
    if (node.children.length >= 2 && index <= 3) {
      return '$ina · ${l10n.t('abtirsiin_branches').replaceAll('{count}', '${node.children.length}')}';
    }
    return ina;
  }

  String _countLabel() {
    if (isYou) {
      final n = node.children.length;
      return l10n.t('abtirsiin_children_count').replaceAll('{count}', '$n');
    }
    final n = node.descendantCount;
    return l10n.t('abtirsiin_descendants_count').replaceAll('{count}', '$n');
  }

  @override
  Widget build(BuildContext context) {
    final badgeBg = isFirst
        ? BrandColors.teal
        : (isYou ? BrandColors.gold : BrandColors.surface);
    final badgeFg = isFirst
        ? BrandColors.linen
        : (isYou ? BrandColors.onGold : BrandColors.teal);
    final badgeBorder = isYou ? BrandColors.gold : BrandColors.teal;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 36,
                child: Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: badgeBg,
                        border: Border.all(color: badgeBorder, width: 2),
                      ),
                      child: Text(
                        '$index',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: badgeFg,
                        ),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          color: BrandColors.tealMid.withValues(alpha: 0.35),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: BrandColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isYou ? BrandColors.gold : BrandColors.border,
                      width: isYou ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lineageShortName(node.profile.fullName),
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: BrandColors.ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _subtitle(),
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: BrandColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _countLabel(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: BrandColors.teal,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: BrandColors.muted,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
