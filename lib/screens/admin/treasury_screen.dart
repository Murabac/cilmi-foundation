import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../models/payment_report.dart';
import '../../providers/providers.dart';
import '../../services/services.dart';
import '../../theme/app_theme.dart';
import '../../utils/branch_filter.dart';
import '../../utils/lineage_name.dart';
import '../../utils/profile_sort.dart';
import '../../widgets/branch_father_filters.dart';
import '../../widgets/widgets.dart';
import 'payment_report_screen.dart';
import 'verification_queue_screen.dart';

class TreasuryScreen extends ConsumerWidget {
  const TreasuryScreen({super.key});

  String _roleLabel(AppLocalizations l10n, UserRole? role) {
    return switch (role) {
      UserRole.superAdmin => l10n.t('role_super_admin'),
      UserRole.treasury => l10n.t('role_treasury'),
      UserRole.manager => l10n.t('role_manager'),
      _ => l10n.t('role_family_member'),
    };
  }

  String _money(double v) {
    if (v == v.roundToDouble()) return '\$${v.toStringAsFixed(0)}';
    return '\$${v.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10nAsync = ref.watch(localizationsProvider);
    final balanceAsync = ref.watch(poolBalanceProvider);
    final ledgerAsync = ref.watch(auditLedgerProvider);
    final pendingAsync = ref.watch(pendingContributionsProvider);
    final reportAsync = ref.watch(monthlyPaymentReportProvider);
    final profile = ref.watch(currentProfileProvider).valueOrNull;
    final canPayments = profile?.role.canManagePayments ?? false;
    final canTreasury = profile?.role.canManageTreasury ?? false;
    final localeCode = ref.watch(localeProvider);

    return l10nAsync.when(
      loading: () => const Scaffold(body: LoadingView()),
      error: (_, _) => const Scaffold(body: ErrorView(message: 'Error')),
      data: (l10n) {
        final now = DateTime.now();
        final ledger = ledgerAsync.valueOrNull ?? const <LedgerEntry>[];
        var inflowMonth = 0.0;
        var outflowMonth = 0.0;
        for (final e in ledger) {
          if (e.date.year != now.year || e.date.month != now.month) continue;
          if (e.isInflow) {
            inflowMonth += e.amount;
          } else {
            outflowMonth += e.amount;
          }
        }

        return Scaffold(
          backgroundColor: BrandColors.linen,
          body: RefreshIndicator(
            color: BrandColors.teal,
            onRefresh: () async {
              ref.invalidate(poolBalanceProvider);
              ref.invalidate(auditLedgerProvider);
              ref.invalidate(pendingContributionsProvider);
              ref.invalidate(monthlyPaymentReportProvider);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _TreasuryHeader(
                    title: l10n.t('treasury'),
                    roleLabel: _roleLabel(l10n, profile?.role),
                    balanceLabel: l10n.t('total_pool_balance'),
                    balance: balanceAsync.valueOrNull,
                    inflowLabel: l10n.t('treasury_inflow_month'),
                    outflowLabel: l10n.t('treasury_outflow_month'),
                    inflow: inflowMonth,
                    outflow: outflowMonth,
                    money: _money,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (canTreasury)
                        Row(
                          children: [
                            Expanded(
                              child: _SoftAction(
                                icon: Icons.add_rounded,
                                label: l10n.t('add_to_pool'),
                                onTap: () =>
                                    _openAddToPoolDialog(context, ref, l10n),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _SoftAction(
                                icon: Icons.favorite_border_rounded,
                                label: l10n.t('disburse_aid'),
                                onTap: () =>
                                    _openDisburseDialog(context, ref, l10n),
                              ),
                            ),
                          ],
                        ),
                      if (canPayments) ...[
                        const SizedBox(height: 14),
                        _VerificationPreviewCard(
                          l10n: l10n,
                          localeCode: localeCode,
                          pendingAsync: pendingAsync,
                          verifierId: profile?.id,
                          money: _money,
                          onSeeAll: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const VerificationQueueScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _PaymentReportSummaryCard(
                          l10n: l10n,
                          reportAsync: reportAsync,
                          onSeeAll: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const PaymentReportScreen(),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      Text(
                        l10n.t('audit_ledger'),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: BrandColors.ink,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ledgerAsync.when(
                        loading: () =>
                            LoadingView(message: l10n.t('loading')),
                        error: (_, _) =>
                            ErrorView(message: l10n.t('error_generic')),
                        data: (entries) {
                          if (entries.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: BrandColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: BrandColors.border),
                              ),
                              child: Center(
                                child: Text(
                                  l10n.t('no_data'),
                                  style: const TextStyle(
                                    color: BrandColors.muted,
                                  ),
                                ),
                              ),
                            );
                          }
                          final isSuperAdmin =
                              profile?.role.isSuperAdmin ?? false;
                          return Column(
                            children: entries
                                .map(
                                  (e) => _LedgerTile(
                                    entry: e,
                                    l10n: l10n,
                                    canDelete: isSuperAdmin && e.canDelete,
                                    onDelete: () => _deleteLedgerEntry(
                                      context,
                                      ref,
                                      l10n,
                                      e,
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteLedgerEntry(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    LedgerEntry entry,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.t('delete_ledger_entry')),
        content: Text(
          l10n
              .t('delete_ledger_entry_confirm')
              .replaceAll('{amount}', entry.amount.toStringAsFixed(2))
              .replaceAll('{description}', entry.description),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.t('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: BrandColors.urgent),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.t('delete')),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(treasuryServiceProvider).deleteLedgerEntry(entry);
      ref.invalidate(poolBalanceProvider);
      ref.invalidate(auditLedgerProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.t('delete_ledger_entry_done'))),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _openAddToPoolDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => _AddToPoolDialog(l10n: l10n),
    );

    if (saved == true && context.mounted) {
      ref.invalidate(poolBalanceProvider);
      ref.invalidate(auditLedgerProvider);
    }
  }

  Future<void> _openDisburseDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final profiles = await ref.read(allProfilesProvider.future);
    final approver = await ref.read(currentProfileProvider.future);
    final balance = await ref.read(treasuryServiceProvider).getPoolBalance();

    if (!context.mounted) return;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => _DisburseAidDialog(
        l10n: l10n,
        profiles: profiles,
        approver: approver,
        balance: balance,
      ),
    );

    if (saved == true && context.mounted) {
      ref.invalidate(poolBalanceProvider);
      ref.invalidate(auditLedgerProvider);
    }
  }
}

class _TreasuryHeader extends StatelessWidget {
  const _TreasuryHeader({
    required this.title,
    required this.roleLabel,
    required this.balanceLabel,
    required this.balance,
    required this.inflowLabel,
    required this.outflowLabel,
    required this.inflow,
    required this.outflow,
    required this.money,
  });

  final String title;
  final String roleLabel;
  final String balanceLabel;
  final double? balance;
  final String inflowLabel;
  final String outflowLabel;
  final double inflow;
  final double outflow;
  final String Function(double) money;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      width: double.infinity,
      color: BrandColors.teal,
      padding: EdgeInsets.fromLTRB(20, top + 12, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                color: BrandColors.linen,
                style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
              ),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: BrandColors.linen,
                  ),
                ),
              ),
              Container(
                height: 26,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: BrandColors.gold,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  roleLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: BrandColors.onGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            balanceLabel,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: BrandColors.onTealMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            balance == null ? '…' : money(balance!),
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: BrandColors.linen,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _HeaderStat(
                  icon: Icons.arrow_downward_rounded,
                  iconColor: const Color(0xFF9FE0BC),
                  label: inflowLabel,
                  value: money(inflow),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeaderStat(
                  icon: Icons.arrow_upward_rounded,
                  iconColor: const Color(0xFFF4C7A1),
                  label: outflowLabel,
                  value: money(outflow),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: BrandColors.linen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: BrandColors.onTealMuted,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: BrandColors.linen,
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
      color: BrandColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 50),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: BrandColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: BrandColors.teal),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: BrandColors.teal,
                    height: 1.2,
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

class _VerificationPreviewCard extends ConsumerWidget {
  const _VerificationPreviewCard({
    required this.l10n,
    required this.localeCode,
    required this.pendingAsync,
    required this.verifierId,
    required this.money,
    required this.onSeeAll,
  });

  final AppLocalizations l10n;
  final String localeCode;
  final AsyncValue<List<Contribution>> pendingAsync;
  final String? verifierId;
  final String Function(double) money;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = pendingAsync.valueOrNull ?? const <Contribution>[];
    final preview = items.take(3).toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
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
                  l10n.t('verification_queue'),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: BrandColors.ink,
                  ),
                ),
              ),
              InkWell(
                onTap: onSeeAll,
                child: Container(
                  height: 26,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: BrandColors.pendingBg,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Text(
                    l10n
                        .t('pending_count_badge')
                        .replaceAll('{count}', '${items.length}'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: BrandColors.pendingInk,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (pendingAsync.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (preview.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Text(
                l10n.t('no_pending_payments'),
                style: const TextStyle(color: BrandColors.muted),
              ),
            )
          else
            for (final c in preview) ...[
              const Divider(height: 1, color: BrandColors.border),
              _PendingPaymentRow(
                contribution: c,
                l10n: l10n,
                localeCode: localeCode,
                verifierId: verifierId,
                money: money,
              ),
            ],
        ],
      ),
    );
  }
}

class _PendingPaymentRow extends ConsumerStatefulWidget {
  const _PendingPaymentRow({
    required this.contribution,
    required this.l10n,
    required this.localeCode,
    required this.verifierId,
    required this.money,
  });

  final Contribution contribution;
  final AppLocalizations l10n;
  final String localeCode;
  final String? verifierId;
  final String Function(double) money;

  @override
  ConsumerState<_PendingPaymentRow> createState() => _PendingPaymentRowState();
}

class _PendingPaymentRowState extends ConsumerState<_PendingPaymentRow> {
  var _busy = false;

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Future<void> _verify(bool approve) async {
    final verifierId = widget.verifierId;
    if (_busy || verifierId == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(contributionServiceProvider).verifyContribution(
            contributionId: widget.contribution.id,
            verifierId: verifierId,
            approve: approve,
          );
      ref.invalidate(pendingContributionsProvider);
      if (approve) {
        ref.invalidate(poolBalanceProvider);
        ref.invalidate(auditLedgerProvider);
        ref.invalidate(monthlyPaymentReportProvider);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              approve
                  ? widget.l10n.t('payment_marked_paid')
                  : widget.l10n.t('rejected'),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.contribution;
    final name = c.profileName ?? 'Member';
    final month = DateFormat(
      'MMMM',
      widget.localeCode.startsWith('so') ? 'so' : 'en',
    ).format(DateTime(c.billingYear, c.billingMonth));
    final selfReported = c.transactionReference == 'submitted';
    final detail = selfReported
        ? widget.l10n.t('member_self_reported_payment')
        : (c.transactionReference ?? '');
    final amount = c.amountDue > 0 ? c.amountDue : c.amountPaid;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: BrandColors.mint,
                ),
                child: Text(
                  _initials(name),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: BrandColors.teal,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: BrandColors.ink,
                      ),
                    ),
                    Text(
                      detail.isEmpty ? month : '$month · $detail',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: BrandColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                widget.money(amount),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: BrandColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: FilledButton.icon(
                    onPressed: _busy || widget.verifierId == null
                        ? null
                        : () => _verify(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: BrandColors.teal,
                      foregroundColor: BrandColors.linen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: _busy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: BrandColors.linen,
                            ),
                          )
                        : const Icon(Icons.check_rounded, size: 18),
                    label: Text(widget.l10n.t('approve')),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: _busy || widget.verifierId == null
                        ? null
                        : () => _verify(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: BrandColors.urgent,
                      side: const BorderSide(
                        color: BrandColors.border,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: Text(widget.l10n.t('reject')),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentReportSummaryCard extends StatelessWidget {
  const _PaymentReportSummaryCard({
    required this.l10n,
    required this.reportAsync,
    required this.onSeeAll,
  });

  final AppLocalizations l10n;
  final AsyncValue<MonthlyPaymentReport> reportAsync;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final report = reportAsync.valueOrNull;
    final paid = report?.paidCount ?? 0;
    final pending = report?.pendingCount ?? 0;
    final unpaid = report?.unpaidCount ?? 0;

    return Container(
      padding: const EdgeInsets.all(18),
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
                  l10n.t('payment_report'),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: BrandColors.ink,
                  ),
                ),
              ),
              TextButton(
                onPressed: onSeeAll,
                child: Text(
                  l10n.t('view_all'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: BrandColors.tealMid,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  if (paid > 0)
                    Expanded(
                      flex: paid,
                      child: const ColoredBox(color: BrandColors.tealMid),
                    ),
                  if (pending > 0)
                    Expanded(
                      flex: pending,
                      child: const ColoredBox(color: BrandColors.gold),
                    ),
                  if (unpaid > 0)
                    Expanded(
                      flex: unpaid,
                      child: const ColoredBox(color: BrandColors.linen),
                    ),
                  if (paid + pending + unpaid == 0)
                    const Expanded(
                      child: ColoredBox(color: BrandColors.border),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$paid ',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: BrandColors.ink,
                      ),
                    ),
                    TextSpan(
                      text: l10n.t('report_paid_label'),
                      style: const TextStyle(color: BrandColors.muted),
                    ),
                  ],
                ),
                style: const TextStyle(fontSize: 13.5),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$pending ',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: BrandColors.ink,
                      ),
                    ),
                    TextSpan(
                      text: l10n.t('report_pending_label'),
                      style: const TextStyle(color: BrandColors.muted),
                    ),
                  ],
                ),
                style: const TextStyle(fontSize: 13.5),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$unpaid ',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: BrandColors.ink,
                      ),
                    ),
                    TextSpan(
                      text: l10n.t('report_unpaid_label'),
                      style: const TextStyle(color: BrandColors.muted),
                    ),
                  ],
                ),
                style: const TextStyle(fontSize: 13.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LedgerTile extends StatelessWidget {
  const _LedgerTile({
    required this.entry,
    required this.l10n,
    this.canDelete = false,
    this.onDelete,
  });

  final LedgerEntry entry;
  final AppLocalizations l10n;
  final bool canDelete;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat.yMMMd().format(entry.date);
    final typeLabel = entry.isInflow ? l10n.t('inflow') : l10n.t('outflow');
    final color = entry.isInflow ? BrandColors.paid : BrandColors.pending;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: BrandColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BrandColors.border),
      ),
      child: ListTile(
        leading: Icon(
          entry.isInflow ? Icons.arrow_downward : Icons.arrow_upward,
          color: color,
        ),
        title: Text(
          '$dateStr — $typeLabel',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: BrandColors.ink,
          ),
        ),
        subtitle: Text(
          entry.isInflow && entry.verifiedByName != null
              ? '${entry.description} (${l10n.t('verified_by')} ${entry.verifiedByName})'
              : entry.description,
          style: const TextStyle(color: BrandColors.muted),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '\$${entry.amount.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
            if (canDelete && onDelete != null)
              IconButton(
                tooltip: l10n.t('delete'),
                icon: const Icon(Icons.delete_outline, color: BrandColors.urgent),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}

class _AddToPoolDialog extends ConsumerStatefulWidget {
  const _AddToPoolDialog({required this.l10n});

  final AppLocalizations l10n;

  @override
  ConsumerState<_AddToPoolDialog> createState() => _AddToPoolDialogState();
}

class _AddToPoolDialogState extends ConsumerState<_AddToPoolDialog> {
  final _amountCtrl = TextEditingController();
  final _donorCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  var _saving = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _donorCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    final reason = _reasonCtrl.text.trim();
    if (_saving || amount <= 0 || reason.isEmpty) return;

    setState(() => _saving = true);
    try {
      await ref.read(treasuryServiceProvider).recordInflow(
            amount: amount,
            reason: reason,
            donorName: _donorCtrl.text.trim().isEmpty
                ? null
                : _donorCtrl.text.trim(),
          );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    final invalidAmount = _amountCtrl.text.trim().isNotEmpty && amount <= 0;
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final maxContentHeight =
        MediaQuery.sizeOf(context).height - viewInsets.bottom - 220;

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      title: Text(l10n.t('add_to_pool')),
      content: SizedBox(
        width: double.maxFinite,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: maxContentHeight.clamp(180.0, 420.0),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.t('add_to_pool_hint'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _amountCtrl,
                  enabled: !_saving,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: l10n.t('amount'),
                    prefixText: '\$ ',
                    isDense: true,
                    errorText: invalidAmount ? l10n.t('invalid_amount') : null,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _donorCtrl,
                  enabled: !_saving,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: l10n.t('donor_name'),
                    hintText: l10n.t('donor_name_hint'),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _reasonCtrl,
                  enabled: !_saving,
                  decoration: InputDecoration(
                    labelText: l10n.t('reason'),
                    hintText: l10n.t('donation_reason_hint'),
                    isDense: true,
                  ),
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: Text(l10n.t('cancel')),
        ),
        FilledButton(
          onPressed: _saving || amount <= 0 || _reasonCtrl.text.trim().isEmpty
              ? null
              : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.t('save')),
        ),
      ],
    );
  }
}

class _DisburseAidDialog extends ConsumerStatefulWidget {
  const _DisburseAidDialog({
    required this.l10n,
    required this.profiles,
    required this.approver,
    required this.balance,
  });

  final AppLocalizations l10n;
  final List<Profile> profiles;
  final Profile? approver;
  final double balance;

  @override
  ConsumerState<_DisburseAidDialog> createState() => _DisburseAidDialogState();
}

class _DisburseAidDialogState extends ConsumerState<_DisburseAidDialog> {
  final _amountCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();

  late final BranchFilterIndex _branchIndex;
  late final Map<String, String> _lineageById;

  String? _branchFilterId;
  String? _subBranchFilterId;
  String? _fatherFilterId;
  String? _selectedId;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _branchIndex = BranchFilterIndex.fromProfiles(widget.profiles);
    final byId = {for (final p in widget.profiles) p.id: p};
    _lineageById = {
      for (final p in widget.profiles) p.id: buildFullMemberName(p, byId),
    };
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  List<Profile> _beneficiaries() {
    final scopeId = _fatherFilterId ?? _subBranchFilterId ?? _branchFilterId;
    var candidates = _branchIndex.filterByBranch(
      widget.profiles,
      _subBranchFilterId ?? _branchFilterId,
      profileId: (p) => p.id,
    );
    if (_fatherFilterId != null) {
      candidates = _branchIndex.filterByAncestor(
        candidates,
        _fatherFilterId,
        profileId: (p) => p.id,
      );
    }
    final list = candidates.toList();
    if (scopeId != null) {
      _branchIndex.sortByGeneration(list, scopeId);
    } else {
      sortProfilesByAge(list);
    }
    return list;
  }

  Future<void> _save(Profile beneficiary, double amount) async {
    final approver = widget.approver;
    if (approver == null || _saving) return;

    setState(() => _saving = true);
    try {
      await ref.read(treasuryServiceProvider).recordOutflow(
            beneficiaryId: beneficiary.id,
            amount: amount,
            reason: _reasonCtrl.text.trim(),
            approvedBy: approver.id,
          );
      if (!mounted) return;
      Navigator.pop(context, true);
    } on InsufficientPoolBalanceException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.l10n.t('insufficient_pool_balance').replaceAll(
                  '{available}',
                  e.available.toStringAsFixed(2),
                ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final balance = widget.balance;
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    final exceedsBalance = amount > balance;
    final invalidAmount = _amountCtrl.text.trim().isNotEmpty && amount <= 0;
    final beneficiaries = _beneficiaries();
    final selectedId = _selectedId != null &&
            beneficiaries.any((p) => p.id == _selectedId)
        ? _selectedId
        : null;
    final selected = selectedId == null
        ? null
        : beneficiaries.firstWhere((p) => p.id == selectedId);
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final maxContentHeight =
        MediaQuery.sizeOf(context).height - viewInsets.bottom - 220;

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      title: Text(l10n.t('disburse_aid')),
      content: SizedBox(
        width: double.maxFinite,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: maxContentHeight.clamp(220.0, 480.0),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n
                      .t('treasury_available_balance')
                      .replaceAll('{amount}', balance.toStringAsFixed(2)),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: balance <= 0 ? Colors.red.shade700 : null,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (_branchIndex.branches.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  BranchFatherFilters(
                    index: _branchIndex,
                    l10n: l10n,
                    branchId: _branchFilterId,
                    subBranchId: _subBranchFilterId,
                    fatherFilterId: _fatherFilterId,
                    lineageById: _lineageById,
                    fatherOptions: _branchIndex.fathersWithChildren(
                      branchId: _subBranchFilterId ?? _branchFilterId,
                    ),
                    onBranchChanged: (id) => setState(() {
                      _branchFilterId = id;
                      _subBranchFilterId = null;
                      _fatherFilterId = null;
                      _selectedId = null;
                    }),
                    onSubBranchChanged: (id) => setState(() {
                      _subBranchFilterId = id;
                      _fatherFilterId = null;
                      _selectedId = null;
                    }),
                    onFatherChanged: (id) => setState(() {
                      _fatherFilterId = id;
                      _selectedId = null;
                    }),
                  ),
                ],
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  // Recreate when filters change so the list resets cleanly.
                  key: ValueKey(
                    'beneficiary_${_branchFilterId}_'
                    '${_subBranchFilterId}_$_fatherFilterId',
                  ),
                  initialValue: selectedId,
                  isExpanded: true,
                  menuMaxHeight: MediaQuery.sizeOf(context).height * 0.35,
                  decoration: InputDecoration(
                    labelText: l10n.t('beneficiary'),
                    isDense: true,
                  ),
                  items: beneficiaries
                      .map(
                        (p) => DropdownMenuItem<String>(
                          value: p.id,
                          child: Text(
                            _lineageById[p.id] ?? p.fullName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: _saving
                      ? null
                      : (id) => setState(() => _selectedId = id),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _amountCtrl,
                  enabled: !_saving,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: l10n.t('amount'),
                    prefixText: '\$ ',
                    isDense: true,
                    errorMaxLines: 3,
                    errorText: exceedsBalance
                        ? l10n.t('insufficient_pool_balance').replaceAll(
                              '{available}',
                              balance.toStringAsFixed(2),
                            )
                        : invalidAmount
                            ? l10n.t('invalid_amount')
                            : null,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _reasonCtrl,
                  enabled: !_saving,
                  decoration: InputDecoration(
                    labelText: l10n.t('reason'),
                    isDense: true,
                  ),
                  textInputAction: TextInputAction.done,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: Text(l10n.t('cancel')),
        ),
        FilledButton(
          onPressed: selected == null ||
                  widget.approver == null ||
                  amount <= 0 ||
                  exceedsBalance ||
                  _reasonCtrl.text.trim().isEmpty ||
                  _saving
              ? null
              : () => _save(selected, amount),
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.t('save')),
        ),
      ],
    );
  }
}

