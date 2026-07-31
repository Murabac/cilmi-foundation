import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../config/payment_config.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/payment_exempt.dart';
import '../../utils/phone_dialer.dart';
import '../../widgets/widgets.dart';

class ContributionScreen extends ConsumerStatefulWidget {
  const ContributionScreen({super.key});

  @override
  ConsumerState<ContributionScreen> createState() => _ContributionScreenState();
}

class _ContributionScreenState extends ConsumerState<ContributionScreen> {
  var _submitting = false;

  Future<void> _dialUssdPayment(
    GlobalSettings settings,
    double amount,
    AppLocalizations l10n,
  ) async {
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

  Future<void> _submitForVerification(
    Profile profile,
    AppLocalizations l10n,
    double rate,
  ) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await ref.read(contributionServiceProvider).submitForVerification(
            userId: profile.id,
            amountDue: rate,
          );
      ref.invalidate(myContributionsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('verification_submitted'))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10nAsync = ref.watch(localizationsProvider);
    final profileAsync = ref.watch(currentProfileProvider);
    final allProfilesAsync = ref.watch(allProfilesProvider);
    final contributionsAsync = ref.watch(myContributionsProvider);
    final settingsAsync = ref.watch(globalSettingsProvider);

    return l10nAsync.when(
      loading: () => const LoadingView(),
      error: (_, _) => const ErrorView(message: 'Error'),
      data: (l10n) {
        final profile = profileAsync.valueOrNull;
        final allProfiles = allProfilesAsync.valueOrNull ?? [];

        if (profile != null && allProfilesAsync.isLoading) {
          return LoadingView(message: l10n.t('loading'));
        }

        if (profile != null &&
            isProfilePaymentExempt(profile, allProfiles: allProfiles)) {
          return _ExemptView(l10n: l10n);
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myContributionsProvider);
            ref.invalidate(globalSettingsProvider);
          },
          child: contributionsAsync.when(
            loading: () => LoadingView(message: l10n.t('loading')),
            error: (_, _) => ErrorView(message: l10n.t('error_generic')),
            data: (contributions) {
              final now = DateTime.now();
              final current = contributions
                  .where(
                    (c) =>
                        c.billingMonth == now.month &&
                        c.billingYear == now.year,
                  )
                  .firstOrNull;
              final monthLabel =
                  DateFormat('MMMM yyyy').format(now).toUpperCase();
              final settings = settingsAsync.valueOrNull;
              final rate = settings?.currentAdultRate ?? 50;
              final ussd = settings?.ussdCodeFor(rate) ??
                  PaymentConfig.ussdCode(
                    amount: rate,
                    merchantId: PaymentConfig.defaultMerchantId,
                  );
              final awaitingAdmin = current?.status == PaymentStatus.pending &&
                  current?.transactionReference != null;
              final isPaid = current?.status == PaymentStatus.approved;
              final isRejected = current?.status == PaymentStatus.rejected;

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                children: [
                  Text(
                    l10n.t('monthly_contribution'),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: BrandColors.navy,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    monthLabel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _StatusHero(
                    l10n: l10n,
                    contribution: current,
                    rate: rate,
                  ),
                  if (!isPaid) ...[
                    const SizedBox(height: 16),
                    _PayCard(
                      l10n: l10n,
                      merchantId: settings?.paymentMerchantId,
                      ussd: ussd,
                      enabled: profile != null && settings != null,
                      onPay: () => _dialUssdPayment(settings!, rate, l10n),
                    ),
                    const SizedBox(height: 12),
                    _NotifyAdminsCard(
                      l10n: l10n,
                      awaitingAdmin: awaitingAdmin,
                      isRejected: isRejected,
                      submitting: _submitting,
                      enabled: profile != null && !awaitingAdmin,
                      onSubmit: profile == null
                          ? null
                          : () => _submitForVerification(profile, l10n, rate),
                    ),
                  ],
                  const SizedBox(height: 28),
                  Text(
                    l10n.t('payment_history'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: BrandColors.navy,
                        ),
                  ),
                  const SizedBox(height: 10),
                  if (contributions.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE8E4D8)),
                      ),
                      child: Center(
                        child: Text(
                          l10n.t('no_data'),
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
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
        );
      },
    );
  }
}

class _ExemptView extends StatelessWidget {
  const _ExemptView({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF059669).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_rounded,
                size: 48,
                color: Color(0xFF059669),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.t('exempt'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: BrandColors.navy,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.t('contribution_exempt_hint'),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusHero extends StatelessWidget {
  const _StatusHero({
    required this.l10n,
    required this.contribution,
    required this.rate,
  });

  final AppLocalizations l10n;
  final Contribution? contribution;
  final double rate;

  @override
  Widget build(BuildContext context) {
    final status = contribution?.status;
    final awaiting = status == PaymentStatus.pending &&
        contribution?.transactionReference != null;
    final (label, color, icon) = switch (status) {
      PaymentStatus.approved => (
          l10n.t('paid'),
          const Color(0xFF059669),
          Icons.check_circle_rounded,
        ),
      PaymentStatus.rejected => (
          l10n.t('rejected'),
          const Color(0xFFDC2626),
          Icons.cancel_rounded,
        ),
      PaymentStatus.pending when awaiting => (
          l10n.t('pending_verification'),
          BrandColors.gold,
          Icons.hourglass_top_rounded,
        ),
      _ => (
          l10n.t('pending'),
          BrandColors.softNavy,
          Icons.schedule_rounded,
        ),
    };
    final amount = contribution?.amountDue ?? rate;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: BrandColors.navy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('current_month_status'),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: BrandColors.gold,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _PayCard extends StatelessWidget {
  const _PayCard({
    required this.l10n,
    required this.ussd,
    required this.enabled,
    required this.onPay,
    this.merchantId,
  });

  final AppLocalizations l10n;
  final String ussd;
  final bool enabled;
  final VoidCallback onPay;
  final String? merchantId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E4D8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.phone_iphone_rounded, color: BrandColors.navy),
              const SizedBox(width: 8),
              Text(
                l10n.t('pay'),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: BrandColors.navy,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (merchantId != null)
            Text(
              l10n.t('payment_send_to').replaceAll('{number}', merchantId!),
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(height: 6),
          Text(
            l10n.t('ussd_dial_hint'),
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 10),
          SelectableText(
            ussd,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              fontSize: 15,
              color: BrandColors.navy,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: enabled ? onPay : null,
            icon: const Icon(Icons.phone_rounded),
            label: Text(l10n.t('pay_now')),
          ),
        ],
      ),
    );
  }
}

class _NotifyAdminsCard extends StatelessWidget {
  const _NotifyAdminsCard({
    required this.l10n,
    required this.awaitingAdmin,
    required this.isRejected,
    required this.submitting,
    required this.enabled,
    required this.onSubmit,
  });

  final AppLocalizations l10n;
  final bool awaitingAdmin;
  final bool isRejected;
  final bool submitting;
  final bool enabled;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E4D8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                awaitingAdmin
                    ? Icons.hourglass_top_rounded
                    : Icons.verified_user_outlined,
                color: awaitingAdmin ? BrandColors.gold : BrandColors.navy,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  awaitingAdmin
                      ? l10n.t('pending_verification')
                      : l10n.t('notify_admins_title'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: BrandColors.navy,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            awaitingAdmin
                ? l10n.t('awaiting_admin_hint')
                : isRejected
                    ? l10n.t('payment_rejected_resubmit_hint')
                    : l10n.t('notify_admins_hint'),
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          if (!awaitingAdmin) ...[
            const SizedBox(height: 14),
            FilledButton.tonalIcon(
              onPressed: enabled && !submitting ? onSubmit : null,
              icon: submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(l10n.t('submit_for_verification')),
            ),
          ],
        ],
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
    final awaiting = contribution.status == PaymentStatus.pending &&
        contribution.transactionReference != null;

    final statusLabel = switch (contribution.status) {
      PaymentStatus.approved => l10n.t('paid'),
      PaymentStatus.rejected => l10n.t('rejected'),
      PaymentStatus.pending when awaiting => l10n.t('pending_verification'),
      PaymentStatus.pending => l10n.t('pending'),
    };

    final color = switch (contribution.status) {
      PaymentStatus.approved => const Color(0xFF059669),
      PaymentStatus.rejected => const Color(0xFFDC2626),
      PaymentStatus.pending when awaiting => BrandColors.gold,
      _ => Colors.grey,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E4D8)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  month.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: BrandColors.navy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  statusLabel,
                  style: TextStyle(color: color, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '\$${contribution.amountDue.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: BrandColors.navy,
            ),
          ),
        ],
      ),
    );
  }
}
