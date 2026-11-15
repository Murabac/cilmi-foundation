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
  var _provider = PaymentProvider.zaad;

  /// Month label for headers/history. Falls back to English if Somali locale
  /// data is missing so the Bixi tab never goes blank.
  static String _monthLabel(DateTime date, String localeCode) {
    final preferSo = localeCode.startsWith('so');
    try {
      return DateFormat('MMMM yyyy', preferSo ? 'so' : 'en').format(date);
    } catch (_) {
      try {
        return DateFormat('MMMM yyyy', 'en').format(date);
      } catch (_) {
        return '${date.month}/${date.year}';
      }
    }
  }

  Future<void> _dialUssdPayment(
    GlobalSettings settings,
    double amount,
    AppLocalizations l10n,
    PaymentProvider provider,
  ) async {
    final ussd = settings.ussdCodeFor(amount, provider: provider);
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
    final localeCode = ref.watch(localeProvider);

    return l10nAsync.when(
      loading: () => const ColoredBox(
        color: BrandColors.linen,
        child: LoadingView(),
      ),
      error: (_, _) => const ColoredBox(
        color: BrandColors.linen,
        child: ErrorView(message: 'Error'),
      ),
      data: (l10n) {
        final profile = profileAsync.valueOrNull;
        final allProfiles = allProfilesAsync.valueOrNull ?? [];
        final nowLabel = _monthLabel(DateTime.now(), localeCode);

        if (profile != null && allProfilesAsync.isLoading) {
          return ColoredBox(
            color: BrandColors.linen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _GiveHeader(
                  title: l10n.t('monthly_contribution'),
                  subtitle: nowLabel,
                ),
                Expanded(
                  child: LoadingView(message: l10n.t('loading')),
                ),
              ],
            ),
          );
        }

        if (profile != null &&
            isProfilePaymentExempt(profile, allProfiles: allProfiles)) {
          return ColoredBox(
            color: BrandColors.linen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _GiveHeader(
                  title: l10n.t('monthly_contribution'),
                  subtitle: nowLabel,
                ),
                Expanded(child: _ExemptView(l10n: l10n)),
              ],
            ),
          );
        }

        return ColoredBox(
          color: BrandColors.linen,
          child: RefreshIndicator(
            color: BrandColors.teal,
            onRefresh: () async {
              ref.invalidate(myContributionsProvider);
              ref.invalidate(globalSettingsProvider);
            },
            child: contributionsAsync.when(
              loading: () => CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _GiveHeader(
                      title: l10n.t('monthly_contribution'),
                      subtitle: nowLabel,
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: LoadingView(message: l10n.t('loading')),
                  ),
                ],
              ),
              error: (_, _) => CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _GiveHeader(
                      title: l10n.t('monthly_contribution'),
                      subtitle: nowLabel,
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: ErrorView(message: l10n.t('error_generic')),
                  ),
                ],
              ),
              data: (contributions) {
                final now = DateTime.now();
                final current = contributions
                    .where(
                      (c) =>
                          c.billingMonth == now.month &&
                          c.billingYear == now.year,
                    )
                    .firstOrNull;
                final monthLabel = _monthLabel(now, localeCode);
                final settings = settingsAsync.valueOrNull;
                final rate = profile?.monthlyAmount ??
                    settings?.currentAdultRate ??
                    50;
                final awaitingAdmin =
                    current?.status == PaymentStatus.pending &&
                        current?.transactionReference != null;
                final isPaid = current?.status == PaymentStatus.approved;
                final isRejected = current?.status == PaymentStatus.rejected;
                final amount = current?.amountDue ?? rate;

                return CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: _GiveHeader(
                        title: l10n.t('monthly_contribution'),
                        subtitle: monthLabel,
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _PayFlowCard(
                            l10n: l10n,
                            amount: amount,
                            contribution: current,
                            provider: _provider,
                            onProviderChanged: (p) =>
                                setState(() => _provider = p),
                            showPayActions: !isPaid,
                            awaitingAdmin: awaitingAdmin,
                            isRejected: isRejected,
                            submitting: _submitting,
                            enabled: profile != null && settings != null,
                            onPayNow: profile == null || settings == null
                                ? null
                                : () => _dialUssdPayment(
                                      settings,
                                      rate,
                                      l10n,
                                      _provider,
                                    ),
                            onNotify: profile == null || awaitingAdmin
                                ? null
                                : () => _submitForVerification(
                                      profile,
                                      l10n,
                                      rate,
                                    ),
                          ),
                          const SizedBox(height: 14),
                          _HistoryCard(
                            l10n: l10n,
                            contributions: contributions,
                            localeCode: localeCode,
                          ),
                          const SizedBox(height: 24),
                        ]),
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
}

class _GiveHeader extends StatelessWidget {
  const _GiveHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      width: double.infinity,
      color: BrandColors.teal,
      padding: EdgeInsets.fromLTRB(20, top + 14, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: BrandColors.linen,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: BrandColors.onTealMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _PayFlowCard extends StatelessWidget {
  const _PayFlowCard({
    required this.l10n,
    required this.amount,
    required this.contribution,
    required this.provider,
    required this.onProviderChanged,
    required this.showPayActions,
    required this.awaitingAdmin,
    required this.isRejected,
    required this.submitting,
    required this.enabled,
    required this.onPayNow,
    required this.onNotify,
  });

  final AppLocalizations l10n;
  final double amount;
  final Contribution? contribution;
  final PaymentProvider provider;
  final ValueChanged<PaymentProvider> onProviderChanged;
  final bool showPayActions;
  final bool awaitingAdmin;
  final bool isRejected;
  final bool submitting;
  final bool enabled;
  final VoidCallback? onPayNow;
  final VoidCallback? onNotify;

  @override
  Widget build(BuildContext context) {
    final status = contribution?.status;
    final (pillLabel, pillFg, pillBg) = switch (status) {
      PaymentStatus.approved => (
          l10n.t('paid'),
          BrandColors.paid,
          BrandColors.paid.withValues(alpha: 0.12),
        ),
      PaymentStatus.rejected => (
          l10n.t('rejected'),
          BrandColors.urgent,
          BrandColors.urgentBg,
        ),
      PaymentStatus.pending when awaitingAdmin => (
          l10n.t('pending_verification'),
          BrandColors.pendingInk,
          BrandColors.pendingBg,
        ),
      _ => (
          l10n.t('pending'),
          BrandColors.urgent,
          BrandColors.urgentBg,
        ),
    };

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
                  l10n.t('amount_due'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: BrandColors.muted,
                  ),
                ),
              ),
              Container(
                height: 26,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: pillBg,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  pillLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: pillFg,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '\$${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)}',
            style: const TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w800,
              color: BrandColors.teal,
              height: 1.1,
            ),
          ),
          if (showPayActions) ...[
            const SizedBox(height: 14),
            Text(
              l10n.t('pay_with_label'),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: BrandColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _ProviderChoice(
                    label: l10n.t('zaad'),
                    selected: provider == PaymentProvider.zaad,
                    onTap: () => onProviderChanged(PaymentProvider.zaad),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ProviderChoice(
                    label: l10n.t('edahab'),
                    selected: provider == PaymentProvider.edahab,
                    onTap: () => onProviderChanged(PaymentProvider.edahab),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _StepRow(
              number: '1',
              title: l10n.t('pay_step1_title'),
              body: l10n.t('pay_step1_body'),
            ),
            const SizedBox(height: 14),
            _StepRow(
              number: '2',
              title: l10n.t('pay_step2_title'),
              body: l10n.t('pay_step2_body'),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: enabled ? onPayNow : null,
                style: FilledButton.styleFrom(
                  backgroundColor: BrandColors.gold,
                  foregroundColor: BrandColors.onGold,
                  disabledBackgroundColor:
                      BrandColors.gold.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.phone_rounded, size: 20),
                label: Text(
                  l10n.t('pay_now'),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 54,
              child: OutlinedButton.icon(
                onPressed: enabled && !submitting && onNotify != null
                    ? onNotify
                    : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: BrandColors.teal,
                  side: const BorderSide(color: BrandColors.teal, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_rounded, size: 20),
                label: Text(
                  awaitingAdmin
                      ? l10n.t('pending_verification')
                      : l10n.t('submit_for_verification'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            if (isRejected) ...[
              const SizedBox(height: 10),
              Text(
                l10n.t('payment_rejected_resubmit_hint'),
                style: const TextStyle(
                  fontSize: 13.5,
                  color: BrandColors.muted,
                  height: 1.4,
                ),
              ),
            ] else if (awaitingAdmin) ...[
              const SizedBox(height: 10),
              Text(
                l10n.t('awaiting_admin_hint'),
                style: const TextStyle(
                  fontSize: 13.5,
                  color: BrandColors.muted,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _ProviderChoice extends StatelessWidget {
  const _ProviderChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
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
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? BrandColors.teal : BrandColors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? BrandColors.teal : BrandColors.muted,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: BrandColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.number,
    required this.title,
    required this.body,
  });

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: BrandColors.teal,
          ),
          child: Text(
            number,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: BrandColors.linen,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
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
                  body,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: BrandColors.muted,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.l10n,
    required this.contributions,
    required this.localeCode,
  });

  final AppLocalizations l10n;
  final List<Contribution> contributions;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
      decoration: BoxDecoration(
        color: BrandColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BrandColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.t('payment_history'),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: BrandColors.ink,
            ),
          ),
          if (contributions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                l10n.t('no_data'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: BrandColors.muted),
              ),
            )
          else
            for (var i = 0; i < contributions.length; i++) ...[
              if (i > 0)
                const Divider(height: 1, color: BrandColors.border),
              _HistoryRow(
                contribution: contributions[i],
                l10n: l10n,
                localeCode: localeCode,
              ),
            ],
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.contribution,
    required this.l10n,
    required this.localeCode,
  });

  final Contribution contribution;
  final AppLocalizations l10n;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final month = _ContributionScreenState._monthLabel(
      DateTime(contribution.billingYear, contribution.billingMonth),
      localeCode,
    );
    final awaiting = contribution.status == PaymentStatus.pending &&
        contribution.transactionReference != null;

    final (label, fg, bg) = switch (contribution.status) {
      PaymentStatus.approved => (
          l10n.t('paid'),
          BrandColors.paid,
          BrandColors.paid.withValues(alpha: 0.12),
        ),
      PaymentStatus.rejected => (
          l10n.t('rejected'),
          BrandColors.urgent,
          BrandColors.urgentBg,
        ),
      PaymentStatus.pending when awaiting => (
          l10n.t('pending_verification'),
          BrandColors.pendingInk,
          BrandColors.pendingBg,
        ),
      _ => (
          l10n.t('pending'),
          BrandColors.pendingInk,
          BrandColors.pendingBg,
        ),
    };

    final amount = contribution.amountDue;
    final amountText =
        '\$${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  month,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: BrandColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  amountText,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: BrandColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 26,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ),
        ],
      ),
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
                color: BrandColors.paid.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_rounded,
                size: 48,
                color: BrandColors.paid,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.t('exempt'),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: BrandColors.teal,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.t('contribution_exempt_hint'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: BrandColors.muted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
