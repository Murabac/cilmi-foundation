import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/models.dart';

/// Value edited by [MemberStatusFields].
class MemberStatusValue {
  const MemberStatusValue({
    this.lifeStatus,
    this.occupation = '',
    this.maritalStatus,
  });

  final LifeStatus? lifeStatus;
  final String occupation;
  final MaritalStatus? maritalStatus;

  MemberStatusValue copyWith({
    LifeStatus? lifeStatus,
    String? occupation,
    MaritalStatus? maritalStatus,
  }) =>
      MemberStatusValue(
        lifeStatus: lifeStatus ?? this.lifeStatus,
        occupation: occupation ?? this.occupation,
        maritalStatus: maritalStatus ?? this.maritalStatus,
      );

  static MemberStatusValue fromProfile(Profile p) => MemberStatusValue(
        lifeStatus: p.lifeStatus,
        occupation: p.occupation ?? '',
        maritalStatus: p.maritalStatus == MaritalStatus.deceased
            ? null
            : p.maritalStatus,
      );
}

IconData lifeStatusIcon(LifeStatus s) => switch (s) {
      LifeStatus.school => Icons.backpack_outlined,
      LifeStatus.university => Icons.school_outlined,
      LifeStatus.working => Icons.work_outline,
      LifeStatus.business => Icons.storefront_outlined,
      LifeStatus.unemployed => Icons.search_off,
      LifeStatus.homemaker => Icons.home_outlined,
      LifeStatus.retired => Icons.chair_outlined,
      LifeStatus.tooYoung => Icons.child_care,
    };

Color lifeStatusColor(LifeStatus s) => switch (s) {
      LifeStatus.school => const Color(0xFF2F6FB0),
      LifeStatus.university => const Color(0xFF5B4BB7),
      LifeStatus.working => const Color(0xFF1E7A4C),
      LifeStatus.business => const Color(0xFF0F6F6B),
      LifeStatus.unemployed => const Color(0xFFB26A00),
      LifeStatus.homemaker => const Color(0xFF9A4B6E),
      LifeStatus.retired => const Color(0xFF5F6B6A),
      LifeStatus.tooYoung => const Color(0xFF7A8B2E),
    };

/// Big, tap-friendly status picker: what the member does this month, job
/// title (for working / business), and marital status.
class MemberStatusFields extends StatefulWidget {
  const MemberStatusFields({
    super.key,
    required this.l10n,
    required this.value,
    required this.onChanged,
  });

  final AppLocalizations l10n;
  final MemberStatusValue value;
  final ValueChanged<MemberStatusValue> onChanged;

  @override
  State<MemberStatusFields> createState() => _MemberStatusFieldsState();
}

class _MemberStatusFieldsState extends State<MemberStatusFields> {
  late final _jobCtrl = TextEditingController(text: widget.value.occupation);

  @override
  void dispose() {
    _jobCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final v = widget.value;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.t('status_question'), style: theme.textTheme.titleSmall),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 3.2,
          children: LifeStatus.values.map((s) {
            final selected = v.lifeStatus == s;
            final color = lifeStatusColor(s);
            return Material(
              color: selected ? color : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: selected ? color : const Color(0xFFE3DDD0),
                  width: selected ? 2 : 1,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => widget.onChanged(v.copyWith(lifeStatus: s)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(
                        lifeStatusIcon(s),
                        size: 20,
                        color: selected ? Colors.white : color,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.t(s.labelKey),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: selected ? Colors.white : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (v.lifeStatus?.hasJob ?? false) ...[
          const SizedBox(height: 14),
          TextField(
            controller: _jobCtrl,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (t) => widget.onChanged(v.copyWith(occupation: t)),
            decoration: InputDecoration(
              labelText: l10n.t('job_title'),
              hintText: l10n.t('job_title_hint'),
              prefixIcon: const Icon(Icons.badge_outlined),
            ),
          ),
        ],
        const SizedBox(height: 18),
        Text(l10n.t('marital_status'), style: theme.textTheme.titleSmall),
        const SizedBox(height: 10),
        SegmentedButton<MaritalStatus>(
          emptySelectionAllowed: true,
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
              value: MaritalStatus.single,
              label: Text(l10n.t('marital_single')),
            ),
            ButtonSegment(
              value: MaritalStatus.married,
              label: Text(l10n.t('marital_married')),
            ),
          ],
          selected: {if (v.maritalStatus != null) v.maritalStatus!},
          onSelectionChanged: (set) {
            if (set.isEmpty) return;
            widget.onChanged(v.copyWith(maritalStatus: set.first));
          },
        ),
      ],
    );
  }
}

/// Small coloured chip showing a member's status.
class LifeStatusChip extends StatelessWidget {
  const LifeStatusChip({super.key, required this.status, required this.l10n});

  final LifeStatus? status;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final s = status;
    final color = s == null ? const Color(0xFF8A8F98) : lifeStatusColor(s);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            s == null ? Icons.help_outline : lifeStatusIcon(s),
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            s == null ? l10n.t('status_not_set') : l10n.t(s.labelKey),
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
