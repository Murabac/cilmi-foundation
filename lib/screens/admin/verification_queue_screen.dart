import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/phone_utils.dart';
import '../../widgets/widgets.dart';

class VerificationQueueScreen extends ConsumerWidget {
  const VerificationQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10nAsync = ref.watch(localizationsProvider);
    final profileAsync = ref.watch(currentProfileProvider);

    return l10nAsync.when(
      loading: () => const Scaffold(body: LoadingView()),
      error: (_, _) => const Scaffold(body: ErrorView(message: 'Error')),
      data: (l10n) {
        final role = profileAsync.valueOrNull?.role;
        final isSuperAdmin = role?.isSuperAdmin ?? false;
        final canPayments = role?.canManagePayments ?? false;

        if (!isSuperAdmin && !canPayments) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.t('verification_queue'))),
            body: _EmptyState(
              icon: Icons.lock_outline_rounded,
              title: l10n.t('unauthorized'),
              subtitle: l10n.t('error_generic'),
            ),
          );
        }

        if (!isSuperAdmin) {
          return Scaffold(
            backgroundColor: BrandColors.cream,
            appBar: AppBar(
              title: Text(l10n.t('verification_queue')),
              backgroundColor: BrandColors.navy,
              foregroundColor: Colors.white,
            ),
            body: _PaymentVerificationTab(l10n: l10n),
          );
        }

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: BrandColors.cream,
            appBar: AppBar(
              title: Text(l10n.t('verification_queue')),
              backgroundColor: BrandColors.navy,
              foregroundColor: Colors.white,
              bottom: TabBar(
                indicatorColor: BrandColors.gold,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                tabs: [
                  Tab(text: l10n.t('profile_claim_requests')),
                  Tab(text: l10n.t('payment_verification')),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _ProfileClaimRequestsTab(l10n: l10n),
                _PaymentVerificationTab(l10n: l10n),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

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
                color: BrandColors.navy.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: BrandColors.navy),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: BrandColors.navy,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, height: 1.35),
            ),
          ],
        ),
      ),
    );
  }
}

class _QueueHeader extends StatelessWidget {
  const _QueueHeader({
    required this.count,
    required this.label,
  });

  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: BrandColors.gold.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: BrandColors.navy,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileClaimRequestsTab extends ConsumerWidget {
  const _ProfileClaimRequestsTab({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final claimsAsync = ref.watch(pendingClaimRequestsProvider);

    return RefreshIndicator(
      color: BrandColors.navy,
      onRefresh: () async {
        ref.invalidate(pendingClaimRequestsProvider);
        await ref.read(pendingClaimRequestsProvider.future);
      },
      child: claimsAsync.when(
        loading: () => LoadingView(message: l10n.t('loading')),
        error: (e, _) => ErrorView(message: claimErrorMessage(e, l10n)),
        data: (items) {
          if (items.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.55,
                  child: _EmptyState(
                    icon: Icons.person_off_outlined,
                    title: l10n.t('no_claim_requests'),
                    subtitle: l10n.t('verification_claims_empty_hint'),
                  ),
                ),
              ],
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: items.length + 1,
            itemBuilder: (ctx, i) {
              if (i == 0) {
                return _QueueHeader(
                  count: items.length,
                  label: l10n.t('verification_waiting_review'),
                );
              }
              final claim = items[i - 1];
              return _ClaimCard(claim: claim, l10n: l10n);
            },
          );
        },
      ),
    );
  }
}

class _ClaimCard extends ConsumerStatefulWidget {
  const _ClaimCard({required this.claim, required this.l10n});

  final ProfileClaimRequest claim;
  final AppLocalizations l10n;

  @override
  ConsumerState<_ClaimCard> createState() => _ClaimCardState();
}

class _ClaimCardState extends ConsumerState<_ClaimCard> {
  var _busy = false;

  Future<void> _approve() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(profileServiceProvider)
          .approveProfileClaim(widget.claim.id);
      ref.invalidate(pendingClaimRequestsProvider);
      ref.invalidate(unclaimedProfilesProvider);
      ref.invalidate(allProfilesProvider);
      ref.invalidate(fullLineageTreeProvider);
      ref.invalidate(memberCountProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.l10n.t('claim_self_approved'))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(claimErrorMessage(e, widget.l10n))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reject() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(profileServiceProvider)
          .rejectProfileClaim(widget.claim.id);
      ref.invalidate(pendingClaimRequestsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(claimErrorMessage(e, widget.l10n))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final claim = widget.claim;
    final l10n = widget.l10n;
    final title = claim.profileFullName ?? claim.requesterName;
    final initial = title.isNotEmpty ? title[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E4D8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: BrandColors.navy.withValues(alpha: 0.1),
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: BrandColors.navy,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: BrandColors.navy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n
                          .t('claim_request_subtitle')
                          .replaceAll('{name}', claim.requesterName),
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                    if (claim.requesterPhone != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${l10n.t('mobile')}: ${claim.requesterPhone}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    if (claim.createdAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        DateFormat.yMMMd().add_jm().format(claim.createdAt!),
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: BrandColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.t('pending'),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: BrandColors.navy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _reject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    side: const BorderSide(color: Color(0xFFDC2626)),
                  ),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: Text(l10n.t('reject')),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _busy ? null : _approve,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                  ),
                  icon: _busy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded, size: 18),
                  label: Text(l10n.t('approve')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentVerificationTab extends ConsumerWidget {
  const _PaymentVerificationTab({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingContributionsProvider);
    final profileAsync = ref.watch(currentProfileProvider);

    return RefreshIndicator(
      color: BrandColors.navy,
      onRefresh: () async {
        ref.invalidate(pendingContributionsProvider);
        await ref.read(pendingContributionsProvider.future);
      },
      child: pendingAsync.when(
        loading: () => LoadingView(message: l10n.t('loading')),
        error: (_, _) => ErrorView(message: l10n.t('error_generic')),
        data: (items) {
          if (items.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.55,
                  child: _EmptyState(
                    icon: Icons.payments_outlined,
                    title: l10n.t('no_pending_payments'),
                    subtitle: l10n.t('verification_payments_empty_hint'),
                  ),
                ),
              ],
            );
          }

          final verifierId = profileAsync.valueOrNull?.id;

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: items.length + 1,
            itemBuilder: (ctx, i) {
              if (i == 0) {
                return _QueueHeader(
                  count: items.length,
                  label: l10n.t('verification_waiting_review'),
                );
              }
              return _PaymentCard(
                contribution: items[i - 1],
                l10n: l10n,
                verifierId: verifierId,
              );
            },
          );
        },
      ),
    );
  }
}

class _PaymentCard extends ConsumerStatefulWidget {
  const _PaymentCard({
    required this.contribution,
    required this.l10n,
    required this.verifierId,
  });

  final Contribution contribution;
  final AppLocalizations l10n;
  final String? verifierId;

  @override
  ConsumerState<_PaymentCard> createState() => _PaymentCardState();
}

class _PaymentCardState extends ConsumerState<_PaymentCard> {
  var _busy = false;

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
    final l10n = widget.l10n;
    final name = c.profileName ?? 'Member';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final month = DateFormat('MMMM yyyy')
        .format(DateTime(c.billingYear, c.billingMonth));
    final selfReported = c.transactionReference == 'submitted';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E4D8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: BrandColors.gold.withValues(alpha: 0.2),
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: BrandColors.navy,
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
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: BrandColors.navy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      month,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selfReported
                          ? l10n.t('member_self_reported_payment')
                          : '${l10n.t('transaction_reference')}: ${c.transactionReference}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${c.amountPaid.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: BrandColors.navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      _busy || widget.verifierId == null ? null : () => _verify(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    side: const BorderSide(color: Color(0xFFDC2626)),
                  ),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: Text(l10n.t('reject')),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed:
                      _busy || widget.verifierId == null ? null : () => _verify(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                  ),
                  icon: _busy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded, size: 18),
                  label: Text(l10n.t('approve')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
