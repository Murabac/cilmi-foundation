import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../config/payment_config.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../utils/phone_dialer.dart';
import '../../widgets/widgets.dart';

class ContributionScreen extends ConsumerStatefulWidget {
  const ContributionScreen({super.key});

  @override
  ConsumerState<ContributionScreen> createState() => _ContributionScreenState();
}

class _ContributionScreenState extends ConsumerState<ContributionScreen> {
  Future<void> _dialUssdPayment(GlobalSettings settings, double amount, AppLocalizations l10n) async {
    final ussd = settings.ussdCodeFor(amount);
    final result = await PhoneDialer.callUssd(ussd);
    if (!mounted) return;

    switch (result) {
      case PhoneDialResult.success:
        return;
      case PhoneDialResult.permissionDenied:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.t('phone_permission_denied'))),
        );
      case PhoneDialResult.failed:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.t('ussd_dial_failed'))),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10nAsync = ref.watch(localizationsProvider);
    final profileAsync = ref.watch(currentProfileProvider);
    final contributionsAsync = ref.watch(myContributionsProvider);
    final settingsAsync = ref.watch(globalSettingsProvider);

    return l10nAsync.when(
      loading: () => const LoadingView(),
      error: (_, __) => const ErrorView(message: 'Error'),
      data: (l10n) {
        final profile = profileAsync.valueOrNull;

        if (profile != null && profile.demographic.isPaymentExempt) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 64, color: Colors.green.shade400),
                const SizedBox(height: 16),
                Text(
                  l10n.t('exempt'),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text('\$0.00', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myContributionsProvider);
            ref.invalidate(globalSettingsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                l10n.t('monthly_contribution'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              contributionsAsync.when(
                loading: () => LoadingView(message: l10n.t('loading')),
                error: (_, __) => ErrorView(message: l10n.t('error_generic')),
                data: (contributions) {
                  final now = DateTime.now();
                  final current = contributions.where(
                    (c) => c.billingMonth == now.month && c.billingYear == now.year,
                  ).firstOrNull;

                  final monthLabel = DateFormat('MMMM yyyy').format(now).toUpperCase();
                  final settings = settingsAsync.valueOrNull;
                  final rate = settings?.currentAdultRate ?? 50;
                  final ussd = settings?.ussdCodeFor(rate) ??
                      PaymentConfig.ussdCode(
                        amount: rate,
                        merchantId: PaymentConfig.defaultMerchantId,
                      );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _StatusCard(
                        l10n: l10n,
                        monthLabel: monthLabel,
                        contribution: current,
                        rate: rate,
                      ),
                      const SizedBox(height: 16),
                      if (settings != null)
                        Text(
                          l10n
                              .t('payment_send_to')
                              .replaceAll('{number}', settings.paymentMerchantId),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      if (settings != null) const SizedBox(height: 8),
                      Text(
                        l10n.t('ussd_dial_hint'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        ussd,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: profile == null || settings == null
                            ? null
                            : () => _dialUssdPayment(settings, rate, l10n),
                        icon: const Icon(Icons.phone),
                        label: Text(l10n.t('pay')),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: profile == null
                            ? null
                            : () => _showPaymentDrawer(context, profile, l10n, rate),
                        icon: const Icon(Icons.receipt_long),
                        label: Text(l10n.t('submit_payment_proof')),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.t('payment_history'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (contributions.isEmpty)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Center(child: Text(l10n.t('no_data'))),
                          ),
                        )
                      else
                        ...contributions.map(
                          (c) => _HistoryTile(contribution: c, l10n: l10n),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showPaymentDrawer(
    BuildContext context,
    Profile profile,
    AppLocalizations l10n,
    double rate,
  ) async {
    final refCtrl = TextEditingController();
    Uint8List? receiptBytes;
    String? receiptExt;
    var loading = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.t('submit_payment'), style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              Text('${l10n.t('amount_due')}: \$${rate.toStringAsFixed(2)}'),
              const SizedBox(height: 12),
              TextField(
                controller: refCtrl,
                decoration: InputDecoration(labelText: l10n.t('transaction_reference')),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final picker = ImagePicker();
                  final file = await picker.pickImage(source: ImageSource.gallery);
                  if (file != null) {
                    receiptBytes = await file.readAsBytes();
                    receiptExt = file.name.split('.').last;
                    setSheetState(() {});
                  }
                },
                icon: const Icon(Icons.upload_file),
                label: Text(
                  receiptBytes != null ? 'Receipt selected' : l10n.t('receipt_optional'),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: loading || refCtrl.text.trim().isEmpty
                    ? null
                    : () async {
                        setSheetState(() => loading = true);
                        try {
                          String? receiptUrl;
                          if (receiptBytes != null && receiptExt != null) {
                            receiptUrl = await ref
                                .read(contributionServiceProvider)
                                .uploadReceipt(profile.id, receiptBytes!, receiptExt!);
                          }
                          await ref.read(contributionServiceProvider).logPayment(
                                userId: profile.id,
                                reference: refCtrl.text.trim(),
                                receiptUrl: receiptUrl,
                                amountDue: rate,
                              );
                          ref.invalidate(myContributionsProvider);
                          if (ctx.mounted) Navigator.pop(ctx);
                        } catch (e) {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        } finally {
                          setSheetState(() => loading = false);
                        }
                      },
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.t('submit_payment')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.l10n,
    required this.monthLabel,
    required this.contribution,
    required this.rate,
  });

  final AppLocalizations l10n;
  final String monthLabel;
  final Contribution? contribution;
  final double rate;

  @override
  Widget build(BuildContext context) {
    final status = contribution?.status;
    final (label, color, icon) = switch (status) {
      PaymentStatus.approved => (l10n.t('paid'), Colors.green, Icons.check_circle),
      PaymentStatus.rejected => (l10n.t('rejected'), Colors.red, Icons.cancel),
      PaymentStatus.pending when contribution?.transactionReference != null =>
        (l10n.t('pending_verification'), Colors.amber, Icons.hourglass_top),
      _ => (l10n.t('pending'), Colors.grey, Icons.schedule),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.t('current_month_status'), style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 8),
            Text(
              '$monthLabel: $label',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text('\$${(contribution?.amountDue ?? rate).toStringAsFixed(2)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.contribution, required this.l10n});

  final Contribution contribution;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final month = DateFormat('MMMM yyyy').format(
      DateTime(contribution.billingYear, contribution.billingMonth),
    );

    final statusLabel = switch (contribution.status) {
      PaymentStatus.approved => l10n.t('paid'),
      PaymentStatus.rejected => l10n.t('rejected'),
      PaymentStatus.pending when contribution.transactionReference != null =>
        l10n.t('pending_verification'),
      PaymentStatus.pending => l10n.t('pending'),
    };

    final color = switch (contribution.status) {
      PaymentStatus.approved => Colors.green,
      PaymentStatus.rejected => Colors.red,
      _ => Colors.amber,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(month.toUpperCase()),
        subtitle: contribution.transactionReference != null
            ? Text(contribution.transactionReference!)
            : null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('\$${contribution.amountDue.toStringAsFixed(2)}'),
            Text(statusLabel, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
