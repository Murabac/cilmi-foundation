import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../models/payment_report.dart';
import '../../providers/providers.dart';
import '../../utils/branch_filter.dart';
import '../../utils/lineage_name.dart';
import '../../utils/phone_utils.dart';
import '../../widgets/branch_father_filters.dart';
import '../../widgets/member_business_card.dart';
import '../../widgets/widgets.dart';

class PaymentReportScreen extends ConsumerStatefulWidget {
  const PaymentReportScreen({super.key});

  @override
  ConsumerState<PaymentReportScreen> createState() => _PaymentReportScreenState();
}

class _PaymentReportScreenState extends ConsumerState<PaymentReportScreen> {
  static const _statusFilters = [
    PaymentReportFilter.all,
    PaymentReportFilter.paid,
    PaymentReportFilter.pending,
    PaymentReportFilter.unpaid,
  ];

  PaymentReportFilter _filter = PaymentReportFilter.all;
  String? _branchFilterId;
  String? _fatherFilterId;
  final _searchCtrl = TextEditingController();
  var _searchQuery = '';

  void _onBranchChanged(String? branchId) {
    setState(() {
      _branchFilterId = branchId;
      _fatherFilterId = null;
    });
  }

  void _onFatherFilterChanged(String? fatherId) {
    setState(() => _fatherFilterId = fatherId);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _shiftMonth(int delta) {
    final current = ref.read(selectedBillingPeriodProvider);
    var month = current.month + delta;
    var year = current.year;
    while (month < 1) {
      month += 12;
      year -= 1;
    }
    while (month > 12) {
      month -= 12;
      year += 1;
    }
    ref.read(selectedBillingPeriodProvider.notifier).state =
        BillingPeriod(month: month, year: year);
  }

  void _refreshReport() {
    ref.invalidate(monthlyPaymentReportProvider);
    ref.invalidate(poolBalanceProvider);
    ref.invalidate(pendingContributionsProvider);
  }

  Future<void> _markPaid(MemberPaymentRow row, MonthlyPaymentReport report) async {
    final l10n = await ref.read(localizationsProvider.future);
    final verifier = await ref.read(currentProfileProvider.future);
    if (verifier == null || !mounted) return;

    final referenceCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.t('mark_as_paid')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.t('mark_paid_confirm').replaceAll('{name}', row.profile.fullName)),
            const SizedBox(height: 12),
            TextField(
              controller: referenceCtrl,
              decoration: InputDecoration(
                labelText: l10n.t('transaction_reference'),
                hintText: l10n.t('phone_payment_hint'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.t('mark_as_paid')),
          ),
        ],
      ),
    );

    final reference = referenceCtrl.text;
    referenceCtrl.dispose();
    if (confirmed != true || !mounted) return;

    try {
      await ref.read(contributionServiceProvider).adminSetPaymentStatus(
            userId: row.profile.id,
            month: report.month,
            year: report.year,
            verifierId: verifier.id,
            adultRate: report.adultRate,
            markPaid: true,
            reference: reference,
          );
      _refreshReport();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.t('payment_marked_paid'))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _markUnpaid(MemberPaymentRow row, MonthlyPaymentReport report) async {
    final l10n = await ref.read(localizationsProvider.future);
    final verifier = await ref.read(currentProfileProvider.future);
    if (verifier == null || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.t('mark_as_unpaid')),
        content: Text(
          l10n.t('mark_unpaid_confirm').replaceAll('{name}', row.profile.fullName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.t('mark_as_unpaid')),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ref.read(contributionServiceProvider).adminSetPaymentStatus(
            userId: row.profile.id,
            month: report.month,
            year: report.year,
            verifierId: verifier.id,
            adultRate: report.adultRate,
            markPaid: false,
          );
      _refreshReport();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _approvePending(MemberPaymentRow row, MonthlyPaymentReport report) async {
    final contribution = row.contribution;
    if (contribution == null) return;
    final verifier = await ref.read(currentProfileProvider.future);
    if (verifier == null) return;

    await ref.read(contributionServiceProvider).verifyContribution(
          contributionId: contribution.id,
          verifierId: verifier.id,
          approve: true,
        );
    _refreshReport();
  }

  @override
  Widget build(BuildContext context) {
    final l10nAsync = ref.watch(localizationsProvider);
    final period = ref.watch(selectedBillingPeriodProvider);
    final reportAsync = ref.watch(monthlyPaymentReportProvider);

    return l10nAsync.when(
      loading: () => const Scaffold(body: LoadingView()),
      error: (_, __) => const Scaffold(body: ErrorView(message: 'Error')),
      data: (l10n) {
        final monthLabel = DateFormat('MMMM yyyy')
            .format(DateTime(period.year, period.month))
            .toUpperCase();

        return Scaffold(
          appBar: AppBar(title: Text(l10n.t('payment_report'))),
          body: RefreshIndicator(
            onRefresh: () async => _refreshReport(),
            child: reportAsync.when(
              loading: () => LoadingView(message: l10n.t('loading')),
              error: (e, _) => ErrorView(
                message: e.toString(),
                onRetry: _refreshReport,
              ),
              data: (report) {
                final allProfiles = ref.watch(allProfilesProvider).valueOrNull ??
                    report.rows.map((r) => r.profile).toList();
                final branchIndex = BranchFilterIndex.fromProfiles(allProfiles);
                final byId = {for (final p in allProfiles) p.id: p};
                final lineageById = {
                  for (final p in allProfiles)
                    p.id: buildPatrilinealDisplayName(p, byId),
                };

                final filtered = report.rows
                    .where((r) => r.matchesFilter(_filter))
                    .where((r) => _matchesBranch(r, branchIndex))
                    .where((r) => _matchesAncestor(r, branchIndex))
                    .where((r) => _matchesSearch(r, lineageById))
                    .toList();

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _MonthSelector(
                      label: monthLabel,
                      onPrevious: () => _shiftMonth(-1),
                      onNext: () => _shiftMonth(1),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.t('payment_report_admin_hint'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _FilteredSummaryGrid(rows: filtered, l10n: l10n, adultRate: report.adultRate),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _statusFilters.map((f) {
                        return FilterChip(
                          label: Text(_filterLabel(l10n, f)),
                          selected: _filter == f,
                          onSelected: (_) => setState(() => _filter = f),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    if (branchIndex.branches.isNotEmpty)
                      BranchFatherFilters(
                        index: branchIndex,
                        l10n: l10n,
                        branchId: _branchFilterId,
                        fatherFilterId: _fatherFilterId,
                        onBranchChanged: _onBranchChanged,
                        onFatherChanged: _onFatherFilterChanged,
                        lineageById: lineageById,
                        showFatherFilter: _branchFilterId != null,
                        fatherOptions: branchIndex.fathersWithChildren(
                          branchId: _branchFilterId,
                        ),
                      ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: l10n.t('search_members'),
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                      ),
                    ),
                    if (_searchQuery.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        l10n
                            .t('search_results')
                            .replaceAll('{count}', '${filtered.length}'),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      '${filtered.length} ${l10n.t('members_label')}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    if (filtered.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              _searchQuery.isNotEmpty
                                  ? l10n.t('no_search_results')
                                  : l10n.t('no_data'),
                            ),
                          ),
                        ),
                      )
                    else
                      ...filtered.map(
                        (row) => _MemberPaymentTile(
                          row: row,
                          report: report,
                          l10n: l10n,
                          onTap: () => showMemberBusinessCard(
                            context,
                            ref,
                            row.profile,
                          ),
                          onMarkPaid: () => _markPaid(row, report),
                          onMarkUnpaid: () => _markUnpaid(row, report),
                          onApprovePending: () => _approvePending(row, report),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  String _filterLabel(AppLocalizations l10n, PaymentReportFilter filter) {
    return switch (filter) {
      PaymentReportFilter.all => l10n.t('filter_all'),
      PaymentReportFilter.paid => l10n.t('paid'),
      PaymentReportFilter.pending => l10n.t('pending_verification'),
      PaymentReportFilter.unpaid => l10n.t('filter_unpaid'),
      PaymentReportFilter.exempt => l10n.t('exempt'),
    };
  }

  bool _matchesBranch(MemberPaymentRow row, BranchFilterIndex index) {
    if (_branchFilterId == null) return true;
    return index.isInBranch(row.profile.id, _branchFilterId!);
  }

  bool _matchesAncestor(MemberPaymentRow row, BranchFilterIndex index) {
    if (_fatherFilterId == null) return true;
    final id = row.profile.id;
    return id == _fatherFilterId ||
        index.isDescendantOf(id, _fatherFilterId!);
  }

  bool _matchesSearch(MemberPaymentRow row, Map<String, String> lineageById) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return true;
    final shortName = row.profile.fullName.toLowerCase();
    final fullName = (lineageById[row.profile.id] ?? '').toLowerCase();
    final phone = (row.profile.phoneNumber ?? '').toLowerCase();
    return shortName.contains(query) ||
        fullName.contains(query) ||
        phone.contains(query.replaceAll(RegExp(r'\D'), ''));
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            IconButton(onPressed: onPrevious, icon: const Icon(Icons.chevron_left)),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right)),
          ],
        ),
      ),
    );
  }
}

class _FilteredSummaryGrid extends StatelessWidget {
  const _FilteredSummaryGrid({
    required this.rows,
    required this.l10n,
    required this.adultRate,
  });

  final List<MemberPaymentRow> rows;
  final AppLocalizations l10n;
  final double adultRate;

  int _count(PaymentReportCategory cat) =>
      rows.where((r) => r.category == cat).length;

  @override
  Widget build(BuildContext context) {
    final paidCount = _count(PaymentReportCategory.paid);
    final pendingCount = _count(PaymentReportCategory.pendingVerification);
    final unpaidCount = _count(PaymentReportCategory.unpaid) +
        _count(PaymentReportCategory.notBilled) +
        _count(PaymentReportCategory.rejected);
    final collected = rows
        .where((r) => r.category == PaymentReportCategory.paid)
        .fold(0.0, (sum, r) => sum + (r.contribution?.amountPaid ?? 0));

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: l10n.t('paid'),
                value: '$paidCount',
                icon: Icons.check_circle,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: MetricCard(
                title: l10n.t('pending_verification'),
                value: '$pendingCount',
                icon: Icons.hourglass_top,
                color: Colors.amber.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: l10n.t('filter_unpaid'),
                value: '$unpaidCount',
                icon: Icons.schedule,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: MetricCard(
                title: l10n.t('collected'),
                value: '\$${collected.toStringAsFixed(0)}',
                icon: Icons.payments,
                color: const Color(0xFF059669),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MemberPaymentTile extends StatelessWidget {
  const _MemberPaymentTile({
    required this.row,
    required this.report,
    required this.l10n,
    required this.onTap,
    required this.onMarkPaid,
    required this.onMarkUnpaid,
    required this.onApprovePending,
  });

  final MemberPaymentRow row;
  final MonthlyPaymentReport report;
  final AppLocalizations l10n;
  final VoidCallback onTap;
  final VoidCallback onMarkPaid;
  final VoidCallback onMarkUnpaid;
  final VoidCallback onApprovePending;

  Future<void> _callMember(BuildContext context) async {
    final phone = row.profile.phoneNumber;
    if (phone == null || phone.trim().isEmpty) return;

    final digits = normalizePhoneDigits(phone);
    if (digits.isEmpty) return;

    final uri = Uri.parse('tel:+$digits');
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('call_failed'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = _statusVisual(row.category, l10n);
    final amount = row.contribution?.amountDue ?? report.adultRate;
    final isExempt = row.paymentExempt;
    final isPaid = row.category == PaymentReportCategory.paid;
    final isPending = row.category == PaymentReportCategory.pendingVerification;
    final phone = row.profile.phoneNumber?.trim();
    final hasPhone = phone != null && phone.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Icon(icon, color: color, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PaymentDetailRow(
                      label: l10n.t('full_name'),
                      value: row.profile.fullName,
                      valueStyle: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    _PaymentDetailRow(
                      label: l10n.t('mobile'),
                      value: hasPhone
                          ? displayPhone(phone)
                          : l10n.t('not_set'),
                      valueColor: hasPhone
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade600,
                      onValueTap: hasPhone
                          ? () => _callMember(context)
                          : null,
                      trailing: hasPhone
                          ? Icon(
                              Icons.phone_outlined,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                    ),
                    const SizedBox(height: 6),
                    _PaymentDetailRow(
                      label: l10n.t('amount'),
                      value: isExempt
                          ? l10n.t('exempt')
                          : '\$${amount.toStringAsFixed(2)}',
                      valueStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isExempt ? Colors.grey.shade600 : color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(color: color, fontSize: 12),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (action) {
                  switch (action) {
                    case 'paid':
                      onMarkPaid();
                    case 'unpaid':
                      onMarkUnpaid();
                    case 'approve':
                      onApprovePending();
                  }
                },
                itemBuilder: (_) => [
                  if (!isPaid && !isExempt)
                    PopupMenuItem(
                      value: 'paid',
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Text(l10n.t('mark_as_paid')),
                        ],
                      ),
                    ),
                  if (isPending)
                    PopupMenuItem(
                      value: 'approve',
                      child: Row(
                        children: [
                          const Icon(Icons.verified, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Text(l10n.t('approve')),
                        ],
                      ),
                    ),
                  if (isPaid)
                    PopupMenuItem(
                      value: 'unpaid',
                      child: Row(
                        children: [
                          const Icon(Icons.undo, size: 20),
                          const SizedBox(width: 8),
                          Text(l10n.t('mark_as_unpaid')),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  (String, Color, IconData) _statusVisual(
    PaymentReportCategory category,
    AppLocalizations l10n,
  ) {
    return switch (category) {
      PaymentReportCategory.paid =>
        (l10n.t('paid'), Colors.green, Icons.check_circle),
      PaymentReportCategory.pendingVerification =>
        (l10n.t('pending_verification'), Colors.amber.shade800, Icons.hourglass_top),
      PaymentReportCategory.unpaid =>
        (l10n.t('filter_unpaid'), Colors.red.shade400, Icons.schedule),
      PaymentReportCategory.notBilled =>
        (l10n.t('not_billed'), Colors.grey.shade600, Icons.receipt_long),
      PaymentReportCategory.rejected =>
        (l10n.t('rejected'), Colors.red, Icons.cancel),
      PaymentReportCategory.exempt =>
        (l10n.t('exempt'), Colors.blueGrey, Icons.block),
    };
  }
}

class _PaymentDetailRow extends StatelessWidget {
  const _PaymentDetailRow({
    required this.label,
    required this.value,
    this.valueStyle,
    this.valueColor,
    this.onValueTap,
    this.trailing,
  });

  final String label;
  final String value;
  final TextStyle? valueStyle;
  final Color? valueColor;
  final VoidCallback? onValueTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final valueWidget = Text(
      value,
      style: (valueStyle ?? Theme.of(context).textTheme.bodyMedium)?.copyWith(
            color: valueColor,
            decoration: onValueTap != null ? TextDecoration.underline : null,
          ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Expanded(
          child: onValueTap == null
              ? valueWidget
              : InkWell(
                  onTap: onValueTap,
                  child: valueWidget,
                ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 4),
          trailing!,
        ],
      ],
    );
  }
}
