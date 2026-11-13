import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../screens/admin/members_manager_screen.dart';
import '../screens/admin/whatsapp_message_screen.dart';
import '../screens/reports/status_report_screen.dart';
import 'member_status_fields.dart';
import 'status_update_sheet.dart';

/// Reminder card: "update your status for this month" (or current status).
class MonthlyStatusCard extends ConsumerWidget {
  const MonthlyStatusCard({
    super.key,
    required this.profile,
    required this.l10n,
  });

  final Profile profile;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stale = profile.statusIsStale;
    final theme = Theme.of(context);
    return Card(
      color: stale ? const Color(0xFFFBEFD9) : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => showStatusUpdateSheet(context, ref, profile),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                stale ? Icons.update : Icons.check_circle_outline,
                color: stale ? const Color(0xFF9A5B00) : const Color(0xFF1E7A4C),
                size: 28,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stale
                          ? l10n.t('status_reminder_title')
                          : l10n.t('status_this_month'),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (stale)
                      Text(l10n.t('status_reminder_body'))
                    else
                      Wrap(
                        spacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          LifeStatusChip(status: profile.lifeStatus, l10n: l10n),
                          if ((profile.occupation ?? '').isNotEmpty &&
                              (profile.lifeStatus?.hasJob ?? false))
                            Text(profile.occupation!),
                        ],
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

/// Staff shortcuts: manage members, status report, WhatsApp message.
class StaffQuickActions extends StatelessWidget {
  const StaffQuickActions({
    super.key,
    required this.l10n,
    required this.canPayments,
  });

  final AppLocalizations l10n;
  final bool canPayments;

  @override
  Widget build(BuildContext context) {
    void open(Widget screen) => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => screen),
        );

    Widget action(IconData icon, String label, Color color, VoidCallback onTap) =>
        Expanded(
          child: Card(
            margin: EdgeInsets.zero,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: color.withValues(alpha: 0.12),
                      child: Icon(icon, color: color),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

    return Row(
      children: [
        action(
          Icons.manage_accounts_outlined,
          l10n.t('manage_members'),
          const Color(0xFF1F6F6B),
          () => open(const MembersManagerScreen()),
        ),
        const SizedBox(width: 10),
        action(
          Icons.insights_outlined,
          l10n.t('status_report_title'),
          const Color(0xFF5B4BB7),
          () => open(const StatusReportScreen()),
        ),
        if (canPayments) ...[
          const SizedBox(width: 10),
          action(
            Icons.share,
            l10n.t('whatsapp_short'),
            const Color(0xFF1E7A4C),
            () => open(const WhatsAppMessageScreen()),
          ),
        ],
      ],
    );
  }
}
