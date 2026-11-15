import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../screens/admin/members_manager_screen.dart';
import '../screens/admin/payment_report_screen.dart';
import '../screens/admin/whatsapp_message_screen.dart';
import '../screens/reports/status_report_screen.dart';
import '../screens/settings/admin_settings_screen.dart';
import '../theme/app_theme.dart';
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
      color: stale ? BrandColors.pendingBg : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => showStatusUpdateSheet(context, ref, profile),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Builder(
                builder: (context) {
                  if (stale) {
                    return const Icon(
                      Icons.update,
                      color: BrandColors.pendingInk,
                      size: 28,
                    );
                  }
                  final status = profile.lifeStatus;
                  if (status == null) {
                    return const Icon(
                      Icons.help_outline,
                      color: BrandColors.muted,
                      size: 28,
                    );
                  }
                  return Icon(
                    lifeStatusIcon(status),
                    color: lifeStatusColor(status),
                    size: 28,
                  );
                },
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

/// Staff entry points formerly on bottom tabs / app-bar icons.
///
/// Admin areas are not tabs — they open from Home (Maamulka + shortcuts).
class StaffQuickActions extends StatelessWidget {
  const StaffQuickActions({
    super.key,
    required this.l10n,
    required this.canPayments,
    required this.canTreasury,
    required this.isSuperAdmin,
  });

  final AppLocalizations l10n;
  final bool canPayments;
  final bool canTreasury;
  final bool isSuperAdmin;

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final roleLabel = isSuperAdmin
        ? l10n.t('role_super_admin')
        : canTreasury
            ? l10n.t('role_treasury')
            : l10n.t('role_manager');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.t('admin_section'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Container(
                      height: 26,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: BrandColors.mint,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Text(
                        roleLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: BrandColors.teal,
                        ),
                      ),
                    ),
                  ],
                ),
                if (canPayments || isSuperAdmin)
                  _AdminRow(
                    icon: Icons.verified_user_outlined,
                    title: l10n.t('verification_queue'),
                    subtitle: l10n.t('admin_verification_hint'),
                    onTap: () => Navigator.pushNamed(context, '/verification'),
                  ),
                if (canTreasury)
                  _AdminRow(
                    icon: Icons.account_balance_wallet_outlined,
                    title: l10n.t('treasury'),
                    subtitle: l10n.t('admin_treasury_hint'),
                    onTap: () => Navigator.pushNamed(context, '/treasury'),
                  ),
                if (canPayments)
                  _AdminRow(
                    icon: Icons.receipt_long_outlined,
                    title: l10n.t('payment_report'),
                    subtitle: l10n.t('admin_payment_report_hint'),
                    onTap: () => _open(context, const PaymentReportScreen()),
                  ),
                if (isSuperAdmin)
                  _AdminRow(
                    icon: Icons.settings_outlined,
                    title: l10n.t('settings'),
                    subtitle: l10n.t('admin_settings_hint'),
                    onTap: () => _open(context, const AdminSettingsScreen()),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _ShortcutTile(
              icon: Icons.manage_accounts_outlined,
              label: l10n.t('manage_members'),
              color: BrandColors.tealMid,
              onTap: () => _open(context, const MembersManagerScreen()),
            ),
            const SizedBox(width: 10),
            _ShortcutTile(
              icon: Icons.insights_outlined,
              label: l10n.t('status_report_title'),
              color: BrandColors.ink,
              onTap: () => _open(context, const StatusReportScreen()),
            ),
            if (canPayments) ...[
              const SizedBox(width: 10),
              _ShortcutTile(
                icon: Icons.share_outlined,
                label: l10n.t('whatsapp_short'),
                color: BrandColors.paid,
                onTap: () => _open(context, const WhatsAppMessageScreen()),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _AdminRow extends StatelessWidget {
  const _AdminRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: BrandColors.mint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: BrandColors.teal, size: 21),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: BrandColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: BrandColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: BrandColors.muted),
          ],
        ),
      ),
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
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
                    color: BrandColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
