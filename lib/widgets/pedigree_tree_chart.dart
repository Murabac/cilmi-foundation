import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/lineage_tree.dart';
import '../models/models.dart';
import '../theme/member_status_theme.dart';
import '../utils/patriarch_resolver.dart';

const _columnWidth = 112.0;
const _columnGap = 16.0;
const _spineWidth = 14.0;
const _busHeight = 20.0;
const _sideGap = 20.0;
const _cellHeight = 40.0;
const _compactCellHeight = 36.0;
const _lineWidth = 1.5;
const _trunkStub = 8.0;
const _siblingRowGap = 16.0;

const _patriarchConnectorHeight = _trunkStub + _busHeight;

Color get _lineColor => Colors.grey.shade600;

double _leafRowHeight(TreeNode node) {
  if (node.children.isEmpty) return _compactCellHeight;
  var total = 0.0;
  for (final child in node.children) {
    total += _leafRowHeight(child);
  }
  return total;
}

double _branchRowHeight(TreeNode node) {
  if (node.children.isEmpty) return _compactCellHeight;
  return _leafRowHeight(node).clamp(_compactCellHeight, double.infinity);
}

bool _needsRowGapAfter(TreeNode node) => node.children.isNotEmpty;

double _childrenBlockHeight(List<TreeNode> children) {
  if (children.isEmpty) return 0;
  var total = 0.0;
  for (var i = 0; i < children.length; i++) {
    total += _branchRowHeight(children[i]);
    if (i < children.length - 1 && _needsRowGapAfter(children[i])) {
      total += _siblingRowGap;
    }
  }
  return total;
}

/// Vertical center for a spine branch into a direct child's name cell.
double _branchCenterY(TreeNode child, double rowOffset) {
  if (child.children.isEmpty) {
    return rowOffset + _branchRowHeight(child) / 2;
  }
  return rowOffset + _compactCellHeight / 2;
}

/// Extra width to the right of the name column for nested side branches.
double _sideExtensionWidth(TreeNode node) {
  if (node.children.isEmpty) return 0;
  var maxExt = 0.0;
  for (final child in node.children) {
    if (child.children.isEmpty) continue;
    maxExt = math.max(
      maxExt,
      _columnWidth + _sideExtensionWidth(child),
    );
  }
  if (maxExt == 0) return 0;
  return _sideGap + maxExt;
}

double _pedigreeColumnWidth(TreeNode node) =>
    _spineWidth + _columnWidth + _sideExtensionWidth(node);

List<double> _childCenterYs(List<TreeNode> children) {
  final centers = <double>[];
  var offset = 0.0;
  for (var i = 0; i < children.length; i++) {
    final child = children[i];
    centers.add(_branchCenterY(child, offset));
    offset += _branchRowHeight(child);
    if (i < children.length - 1 && _needsRowGapAfter(child)) {
      offset += _siblingRowGap;
    }
  }
  return centers;
}

/// Horizontal center of each son's name cell (not the full column block).
List<double> _sonNameCellCenterXs(List<double> columnWidths) {
  final centers = <double>[];
  var x = 0.0;
  for (var i = 0; i < columnWidths.length; i++) {
    if (i > 0) x += _columnGap;
    centers.add(x + _spineWidth + _columnWidth / 2);
    x += columnWidths[i];
  }
  return centers;
}

/// Report-style pedigree: root at top, sons in columns, side branches to the right.
class PedigreeTreeChart extends StatelessWidget {
  const PedigreeTreeChart({
    super.key,
    required this.root,
    required this.onMemberTap,
  });

  final TreeNode root;
  final ValueChanged<Profile> onMemberTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade400),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth - 32),
              child: _PedigreeSubtree(
                node: root,
                onMemberTap: onMemberTap,
                isRoot: true,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PedigreeSubtree extends StatelessWidget {
  const _PedigreeSubtree({
    required this.node,
    required this.onMemberTap,
    this.isRoot = false,
  });

  final TreeNode node;
  final ValueChanged<Profile> onMemberTap;
  final bool isRoot;

  @override
  Widget build(BuildContext context) {
    if (node.children.isEmpty) {
      return _NameCell(
        profile: node.profile,
        onTap: () => onMemberTap(node.profile),
        emphasized: isRoot,
      );
    }

    if (isRoot) {
      final split = splitPatriarchChildren(node);
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          _PatriarchSonsSection(
            profile: node.profile,
            sons: split.sons,
            onMemberTap: onMemberTap,
          ),
          if (split.daughters.isNotEmpty) ...[
            SizedBox(width: _columnGap * 2),
            _PatriarchDaughtersSection(
              daughters: split.daughters,
              onMemberTap: onMemberTap,
            ),
          ],
        ],
      );
    }

    return _PatriarchSonsSection(
      profile: node.profile,
      sons: node.children,
      onMemberTap: onMemberTap,
      emphasized: false,
    );
  }
}

class _PatriarchSonsSection extends StatelessWidget {
  const _PatriarchSonsSection({
    required this.profile,
    required this.sons,
    required this.onMemberTap,
    this.emphasized = true,
  });

  final Profile profile;
  final List<TreeNode> sons;
  final ValueChanged<Profile> onMemberTap;
  final bool emphasized;

  static double _branchRowWidth(List<TreeNode> children) {
    if (children.isEmpty) return _spineWidth + _columnWidth;
    var width = 0.0;
    for (var i = 0; i < children.length; i++) {
      if (i > 0) width += _columnGap;
      width += _pedigreeColumnWidth(children[i]);
    }
    return width;
  }

  @override
  Widget build(BuildContext context) {
    if (sons.isEmpty) {
      return _NameCell(
        profile: profile,
        onTap: () => onMemberTap(profile),
        emphasized: emphasized,
      );
    }

    final columnWidths =
        sons.map(_pedigreeColumnWidth).toList(growable: false);
    final rowWidth = _branchRowWidth(sons);
    final sonCenterXs = _sonNameCellCenterXs(columnWidths);
    final patriarchCenterX = rowWidth / 2;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: rowWidth,
          child: Center(
            child: _NameCell(
              profile: profile,
              onTap: () => onMemberTap(profile),
              emphasized: emphasized,
            ),
          ),
        ),
        SizedBox(
          width: rowWidth,
          height: _patriarchConnectorHeight,
          child: CustomPaint(
            painter: _PatriarchToSonsPainter(
              patriarchCenterX: patriarchCenterX,
              sonCenterXs: sonCenterXs,
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < sons.length; i++) ...[
              if (i > 0) SizedBox(width: _columnGap),
              SizedBox(
                width: columnWidths[i],
                child: _PedigreeColumn(
                  node: sons[i],
                  onMemberTap: onMemberTap,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _PatriarchDaughtersSection extends StatelessWidget {
  const _PatriarchDaughtersSection({
    required this.daughters,
    required this.onMemberTap,
  });

  final List<TreeNode> daughters;
  final ValueChanged<Profile> onMemberTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < daughters.length; i++) ...[
          if (i > 0) const SizedBox(height: _siblingRowGap),
          _PedigreeColumn(
            node: daughters[i],
            onMemberTap: onMemberTap,
          ),
        ],
      ],
    );
  }
}

class _PedigreeColumn extends StatelessWidget {
  const _PedigreeColumn({
    required this.node,
    required this.onMemberTap,
  });

  final TreeNode node;
  final ValueChanged<Profile> onMemberTap;

  @override
  Widget build(BuildContext context) {
    if (node.children.isEmpty) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: _spineWidth),
          _NameCell(
            profile: node.profile,
            onTap: () => onMemberTap(node.profile),
          ),
        ],
      );
    }

    final branchCenters = _childCenterYs(node.children);
    final descendantsTop = _cellHeight + _trunkStub;
    final branchCenterYs = branchCenters
        .map((y) => descendantsTop + y)
        .toList(growable: false);
    final blockHeight = _childrenBlockHeight(node.children);
    final totalHeight = descendantsTop + blockHeight;
    final nameCenterX = _columnWidth / 2;
    final childCenters = branchCenterYs
        .map((y) => Offset(nameCenterX, y))
        .toList(growable: false);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: _spineWidth),
        SizedBox(
          width: _columnWidth + _sideExtensionWidth(node),
          height: totalHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _ParentToChildrenPainter(
                      parentCenter: Offset(nameCenterX, _cellHeight / 2),
                      childCenters: childCenters,
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _NameCell(
                    profile: node.profile,
                    onTap: () => onMemberTap(node.profile),
                  ),
                  const SizedBox(height: _trunkStub),
                  for (var i = 0; i < node.children.length; i++) ...[
                    SizedBox(
                      height: _branchRowHeight(node.children[i]),
                      child: _SideBranchRow(
                        node: node.children[i],
                        onMemberTap: onMemberTap,
                        showTopBorder: i > 0,
                      ),
                    ),
                    if (i < node.children.length - 1 &&
                        _needsRowGapAfter(node.children[i]))
                      const SizedBox(height: _siblingRowGap),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SideBranchRow extends StatelessWidget {
  const _SideBranchRow({
    required this.node,
    required this.onMemberTap,
    this.showTopBorder = false,
  });

  final TreeNode node;
  final ValueChanged<Profile> onMemberTap;
  final bool showTopBorder;

  @override
  Widget build(BuildContext context) {
    if (node.children.isEmpty) {
      return Align(
        alignment: Alignment.topLeft,
        child: _NameCell(
          profile: node.profile,
          onTap: () => onMemberTap(node.profile),
          compact: true,
          showTopBorder: showTopBorder,
        ),
      );
    }

    final childCenters = _childCenterYs(node.children);
    final columnHeight = _leafRowHeight(node);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _NameCell(
          profile: node.profile,
          onTap: () => onMemberTap(node.profile),
          compact: true,
          showTopBorder: showTopBorder,
        ),
        SizedBox(
          width: _sideGap,
          height: columnHeight,
          child: CustomPaint(
            painter: _SideBranchPainter(
              parentCenterY: _compactCellHeight / 2,
              childCenterYs: childCenters,
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < node.children.length; i++)
              SizedBox(
                height: _branchRowHeight(node.children[i]),
                child: _SideBranchRow(
                  node: node.children[i],
                  onMemberTap: onMemberTap,
                  showTopBorder: i > 0,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _NameCell extends StatelessWidget {
  const _NameCell({
    required this.profile,
    required this.onTap,
    this.emphasized = false,
    this.compact = false,
    this.showTopBorder = false,
  });

  final Profile profile;
  final VoidCallback onTap;
  final bool emphasized;
  final bool compact;
  final bool showTopBorder;

  @override
  Widget build(BuildContext context) {
    final statusColor = MemberStatusTheme.colorFor(
          demographic: profile.demographic,
          maritalStatus: profile.maritalStatus,
        ) ??
        Colors.grey.shade500;
    final height = compact ? _compactCellHeight : _cellHeight;
    final fill = statusColor.withValues(alpha: emphasized ? 0.22 : 0.12);
    final borderColor = statusColor.withValues(alpha: 0.85);

    return Material(
      color: fill,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: _columnWidth,
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: fill,
            border: Border.all(
              color: borderColor,
              width: emphasized ? 1.8 : 1.4,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  profile.fullName,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 11 : (emphasized ? 14 : 12),
                    fontWeight: emphasized ? FontWeight.w700 : FontWeight.w600,
                    height: 1.15,
                    color: statusColor.withValues(alpha: 0.95),
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

class _PatriarchToSonsPainter extends CustomPainter {
  const _PatriarchToSonsPainter({
    required this.patriarchCenterX,
    required this.sonCenterXs,
  });

  final double patriarchCenterX;
  final List<double> sonCenterXs;

  @override
  void paint(Canvas canvas, Size size) {
    if (sonCenterXs.isEmpty) return;

    final paint = Paint()
      ..color = _lineColor
      ..strokeWidth = _lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final busY = _trunkStub + _busHeight / 2;
    final firstSonX = sonCenterXs.first;
    final lastSonX = sonCenterXs.last;
    final busLeft = math.min(patriarchCenterX, firstSonX);
    final busRight = math.max(patriarchCenterX, lastSonX);

    // Trunk down from patriarch (top of connector) to horizontal bus.
    canvas.drawLine(
      Offset(patriarchCenterX, 0),
      Offset(patriarchCenterX, busY),
      paint,
    );

    // Horizontal bus spanning patriarch + all sons.
    canvas.drawLine(Offset(busLeft, busY), Offset(busRight, busY), paint);

    // Vertical drop into each son name cell (bottom of connector = top of cell).
    for (final x in sonCenterXs) {
      canvas.drawLine(Offset(x, busY), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PatriarchToSonsPainter oldDelegate) =>
      oldDelegate.patriarchCenterX != patriarchCenterX ||
      oldDelegate.sonCenterXs != sonCenterXs;
}

class _ParentToChildrenPainter extends CustomPainter {
  const _ParentToChildrenPainter({
    required this.parentCenter,
    required this.childCenters,
  });

  final Offset parentCenter;
  final List<Offset> childCenters;

  @override
  void paint(Canvas canvas, Size size) {
    if (childCenters.isEmpty) return;

    final paint = Paint()
      ..color = _lineColor
      ..strokeWidth = _lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final trunkX = parentCenter.dx;
    final stubMidY = _cellHeight + _trunkStub / 2;
    final lastChildY = childCenters.last.dy;

    // Down from the middle of the parent node through the stub gap.
    canvas.drawLine(parentCenter, Offset(trunkX, stubMidY), paint);

    // Center trunk through each child node's vertical center.
    canvas.drawLine(Offset(trunkX, stubMidY), Offset(trunkX, lastChildY), paint);

    for (final child in childCenters) {
      final childTop = child.dy - _compactCellHeight / 2;
      if (childTop > stubMidY) {
        canvas.drawLine(Offset(trunkX, childTop), child, paint);
      } else if ((child.dx - trunkX).abs() > 0.5) {
        canvas.drawLine(Offset(trunkX, child.dy), child, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParentToChildrenPainter oldDelegate) =>
      oldDelegate.parentCenter != parentCenter ||
      oldDelegate.childCenters != childCenters;
}

class _SideBranchPainter extends CustomPainter {
  _SideBranchPainter({
    required this.parentCenterY,
    required this.childCenterYs,
  });

  final double parentCenterY;
  final List<double> childCenterYs;

  @override
  void paint(Canvas canvas, Size size) {
    if (childCenterYs.isEmpty) return;

    final paint = Paint()
      ..color = _lineColor
      ..strokeWidth = _lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final busX = size.width / 2;
    final outX = size.width;

    canvas.drawLine(Offset(0, parentCenterY), Offset(busX, parentCenterY), paint);

    if (childCenterYs.length == 1) {
      final childY = childCenterYs.first;
      if ((childY - parentCenterY).abs() > 0.5) {
        canvas.drawLine(Offset(busX, parentCenterY), Offset(busX, childY), paint);
      }
      canvas.drawLine(Offset(busX, childY), Offset(outX, childY), paint);
      return;
    }

    final firstY = childCenterYs.first;
    final lastY = childCenterYs.last;
    final busTop = math.min(parentCenterY, firstY);
    final busBottom = math.max(parentCenterY, lastY);

    canvas.drawLine(Offset(busX, busTop), Offset(busX, busBottom), paint);

    for (final childY in childCenterYs) {
      canvas.drawLine(Offset(busX, childY), Offset(outX, childY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SideBranchPainter oldDelegate) =>
      oldDelegate.parentCenterY != parentCenterY ||
      oldDelegate.childCenterYs != childCenterYs;
}
