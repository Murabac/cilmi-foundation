import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../models/payment_report.dart';
import '../../providers/providers.dart';
import '../../utils/whatsapp_contributions_message.dart';
import '../../widgets/widgets.dart';

/// Finance admin: preview this month's contributions message and send it to
/// the family WhatsApp group with one tap (WhatsApp opens with the text ready,
/// pick the group, press send).
class WhatsAppMessageScreen extends ConsumerWidget {
  const WhatsAppMessageScreen({super.key});

  Future<void> _share(BuildContext context, String text, String failMsg) async {
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
          SnackBar(content: Text(failMsg)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10nAsync = ref.watch(localizationsProvider);
    final reportAsync = ref.watch(monthlyPaymentReportProvider);
    final settingsAsync = ref.watch(globalSettingsProvider);
    final profilesAsync = ref.watch(allProfilesProvider);
    final period = ref.watch(selectedBillingPeriodProvider);

    void shift(int delta) {
      final d = DateTime(period.year, period.month + delta);
      ref.read(selectedBillingPeriodProvider.notifier).state =
          BillingPeriod(month: d.month, year: d.year);
    }

    return l10nAsync.when(
      loading: () => const Scaffold(body: LoadingView()),
      error: (_, _) => const Scaffold(body: ErrorView(message: 'Error')),
      data: (l10n) {
        final monthLabel =
            DateFormat('MMMM yyyy').format(DateTime(period.year, period.month));
        final ready = reportAsync.hasValue &&
            settingsAsync.hasValue &&
            profilesAsync.hasValue;
        final error =
            reportAsync.error ?? settingsAsync.error ?? profilesAsync.error;

        Widget body;
        if (error != null) {
          body = ErrorView(
            message: error.toString(),
            onRetry: () => ref.invalidate(monthlyPaymentReportProvider),
          );
        } else if (!ready) {
          body = LoadingView(message: l10n.t('loading'));
        } else {
          final report = reportAsync.value!;
          final text = buildContributionsWhatsAppMessage(
            report: report,
            settings: settingsAsync.value!,
            allProfiles: profilesAsync.value!,
          );
          final payers = report.rows.where((r) => !r.paymentExempt).toList();
          final paid = payers
              .where((r) => r.category == PaymentReportCategory.paid)
              .length;

          body = Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  children: [
                    Row(
                      children: [
                        IconButton.filledTonal(
                          tooltip: l10n.t('previous_month'),
                          onPressed: () => shift(-1),
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Expanded(
                          child: Text(
                            monthLabel,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        IconButton.filledTonal(
                          tooltip: l10n.t('next_month'),
                          onPressed: () => shift(1),
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n
                          .t('whatsapp_paid_of')
                          .replaceAll('{paid}', '$paid')
                          .replaceAll('{total}', '${payers.length}'),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 12),
                    // WhatsApp-like preview bubble.
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7F7DC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFCDE8BC)),
                      ),
                      child: SelectableText(
                        text.replaceAll('*', ''),
                        style: const TextStyle(fontSize: 15, height: 1.45),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.t('whatsapp_hint'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Row(
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 54),
                        ),
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: text));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.t('copied'))),
                            );
                          }
                        },
                        icon: const Icon(Icons.copy),
                        label: Text(l10n.t('copy')),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF1E7A4C),
                            minimumSize: const Size.fromHeight(54),
                          ),
                          onPressed: () => _share(
                            context,
                            text,
                            l10n.t('whatsapp_not_installed_copied'),
                          ),
                          icon: const Icon(Icons.send),
                          label: Text(l10n.t('send_to_whatsapp')),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(l10n.t('whatsapp_share_report'))),
          body: body,
        );
      },
    );
  }
}
