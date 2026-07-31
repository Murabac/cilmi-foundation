import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../services/services.dart';
import '../../utils/branch_filter.dart';
import '../../utils/lineage_name.dart';
import '../../utils/profile_sort.dart';
import '../../widgets/branch_father_filters.dart';
import '../../widgets/widgets.dart';

class TreasuryScreen extends ConsumerWidget {
  const TreasuryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10nAsync = ref.watch(localizationsProvider);
    final balanceAsync = ref.watch(poolBalanceProvider);
    final ledgerAsync = ref.watch(auditLedgerProvider);

    return l10nAsync.when(
      loading: () => const Scaffold(body: LoadingView()),
      error: (_, _) => const Scaffold(body: ErrorView(message: 'Error')),
      data: (l10n) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.t('treasury')),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: l10n.t('add_to_pool'),
              onPressed: () => _openAddToPoolDialog(context, ref, l10n),
            ),
            IconButton(
              icon: const Icon(Icons.volunteer_activism_outlined),
              tooltip: l10n.t('disburse_aid'),
              onPressed: () => _openDisburseDialog(context, ref, l10n),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(poolBalanceProvider);
            ref.invalidate(auditLedgerProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              balanceAsync.when(
                loading: () =>
                    MetricCard(title: l10n.t('total_pool_balance'), value: '...'),
                error: (_, _) =>
                    MetricCard(title: l10n.t('total_pool_balance'), value: '—'),
                data: (balance) => MetricCard(
                  title: l10n.t('total_pool_balance'),
                  value: '\$${balance.toStringAsFixed(2)}',
                  icon: Icons.account_balance_wallet,
                  color: const Color(0xFF059669),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.t('audit_ledger'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ledgerAsync.when(
                loading: () => LoadingView(message: l10n.t('loading')),
                error: (_, _) => ErrorView(message: l10n.t('error_generic')),
                data: (entries) {
                  if (entries.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(child: Text(l10n.t('no_data'))),
                      ),
                    );
                  }

                  final isSuperAdmin = ref
                          .watch(currentProfileProvider)
                          .valueOrNull
                          ?.role
                          .isSuperAdmin ??
                      false;

                  return Column(
                    children: entries
                        .map(
                          (e) => _LedgerTile(
                            entry: e,
                            l10n: l10n,
                            canDelete: isSuperAdmin && e.canDelete,
                            onDelete: () =>
                                _deleteLedgerEntry(context, ref, l10n, e),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
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
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
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
    final color = entry.isInflow ? Colors.green : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          entry.isInflow ? Icons.arrow_downward : Icons.arrow_upward,
          color: color,
        ),
        title: Text('$dateStr — $typeLabel'),
        subtitle: Text(
          entry.isInflow && entry.verifiedByName != null
              ? '${entry.description} (${l10n.t('verified_by')} ${entry.verifiedByName})'
              : entry.description,
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
                icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}
