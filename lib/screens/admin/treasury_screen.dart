import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../services/services.dart';
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
      error: (_, __) => const Scaffold(body: ErrorView(message: 'Error')),
      data: (l10n) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.t('treasury')),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: l10n.t('disburse_aid'),
              onPressed: () => _showDisburseDialog(context, ref, l10n),
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
                loading: () => MetricCard(title: l10n.t('total_pool_balance'), value: '...'),
                error: (_, __) => MetricCard(title: l10n.t('total_pool_balance'), value: '—'),
                data: (balance) => MetricCard(
                  title: l10n.t('total_pool_balance'),
                  value: '\$${balance.toStringAsFixed(2)}',
                  icon: Icons.account_balance_wallet,
                  color: const Color(0xFF059669),
                ),
              ),
              const SizedBox(height: 24),
              Text(l10n.t('audit_ledger'), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ledgerAsync.when(
                loading: () => LoadingView(message: l10n.t('loading')),
                error: (_, __) => ErrorView(message: l10n.t('error_generic')),
                data: (entries) {
                  if (entries.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(child: Text(l10n.t('no_data'))),
                      ),
                    );
                  }

                  return Column(
                    children: entries.map((e) => _LedgerTile(entry: e, l10n: l10n)).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDisburseDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final amountCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    Profile? selected;
    final profiles = await ref.read(allProfilesProvider.future);
    final approver = await ref.read(currentProfileProvider.future);
    final balance = await ref.read(treasuryServiceProvider).getPoolBalance();

    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
          final exceedsBalance = amount > balance;
          final invalidAmount = amountCtrl.text.trim().isNotEmpty && amount <= 0;

          return AlertDialog(
            title: Text(l10n.t('disburse_aid')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n
                      .t('treasury_available_balance')
                      .replaceAll('{amount}', balance.toStringAsFixed(2)),
                  style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                        color: balance <= 0 ? Colors.red.shade700 : null,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Profile>(
                  decoration: InputDecoration(labelText: l10n.t('beneficiary')),
                  initialValue: selected,
                  items: profiles
                      .map((p) => DropdownMenuItem(value: p, child: Text(p.fullName)))
                      .toList(),
                  onChanged: (v) => setState(() => selected = v),
                ),
                TextField(
                  controller: amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: l10n.t('amount'),
                    prefixText: '\$ ',
                    errorText: exceedsBalance
                        ? l10n
                            .t('insufficient_pool_balance')
                            .replaceAll('{available}', balance.toStringAsFixed(2))
                        : invalidAmount
                            ? l10n.t('invalid_amount')
                            : null,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                TextField(
                  controller: reasonCtrl,
                  decoration: InputDecoration(labelText: l10n.t('reason')),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              FilledButton(
                onPressed: selected == null ||
                        approver == null ||
                        amount <= 0 ||
                        exceedsBalance ||
                        reasonCtrl.text.trim().isEmpty
                    ? null
                    : () async {
                        try {
                          await ref.read(treasuryServiceProvider).recordOutflow(
                                beneficiaryId: selected!.id,
                                amount: amount,
                                reason: reasonCtrl.text.trim(),
                                approvedBy: approver.id,
                              );
                          ref.invalidate(poolBalanceProvider);
                          ref.invalidate(auditLedgerProvider);
                          if (ctx.mounted) Navigator.pop(ctx);
                        } on InsufficientPoolBalanceException catch (e) {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n
                                      .t('insufficient_pool_balance')
                                      .replaceAll(
                                        '{available}',
                                        e.available.toStringAsFixed(2),
                                      ),
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        }
                      },
                child: Text(l10n.t('save')),
              ),
            ],
          );
        },
      ),
    );

    amountCtrl.dispose();
    reasonCtrl.dispose();
  }
}

class _LedgerTile extends StatelessWidget {
  const _LedgerTile({required this.entry, required this.l10n});

  final LedgerEntry entry;
  final AppLocalizations l10n;

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
        trailing: Text(
          '\$${entry.amount.toStringAsFixed(2)}',
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ),
    );
  }
}
