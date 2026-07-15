import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
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
      error: (_, __) => const Scaffold(body: ErrorView(message: 'Error')),
      data: (l10n) {
        final isSuperAdmin =
            profileAsync.valueOrNull?.role == UserRole.superAdmin;

        if (!isSuperAdmin) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.t('verification_queue'))),
            body: _PaymentVerificationTab(l10n: l10n),
          );
        }

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text(l10n.t('verification_queue')),
              bottom: TabBar(
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

class _ProfileClaimRequestsTab extends ConsumerWidget {
  const _ProfileClaimRequestsTab({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final claimsAsync = ref.watch(pendingClaimRequestsProvider);

    return claimsAsync.when(
      loading: () => LoadingView(message: l10n.t('loading')),
      error: (e, _) => ErrorView(message: claimErrorMessage(e, l10n)),
      data: (items) {
        if (items.isEmpty) {
          return Center(child: Text(l10n.t('no_claim_requests')));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (ctx, i) {
            final claim = items[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(claim.profileFullName ?? claim.requesterName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n
                          .t('claim_request_subtitle')
                          .replaceAll('{name}', claim.requesterName),
                    ),
                    if (claim.requesterPhone != null)
                      Text('${l10n.t('mobile')}: ${claim.requesterPhone}'),
                    if (claim.createdAt != null)
                      Text(
                        DateFormat.yMMMd().add_jm().format(claim.createdAt!),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      tooltip: l10n.t('approve'),
                      onPressed: () async {
                        try {
                          await ref
                              .read(profileServiceProvider)
                              .approveProfileClaim(claim.id);
                          ref.invalidate(pendingClaimRequestsProvider);
                          ref.invalidate(unclaimedProfilesProvider);
                          ref.invalidate(allProfilesProvider);
                          ref.invalidate(fullLineageTreeProvider);
                          ref.invalidate(memberCountProvider);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(claimErrorMessage(e, l10n)),
                              ),
                            );
                          }
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      tooltip: l10n.t('reject'),
                      onPressed: () async {
                        try {
                          await ref
                              .read(profileServiceProvider)
                              .rejectProfileClaim(claim.id);
                          ref.invalidate(pendingClaimRequestsProvider);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(claimErrorMessage(e, l10n)),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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

    return pendingAsync.when(
      loading: () => LoadingView(message: l10n.t('loading')),
      error: (_, __) => ErrorView(message: l10n.t('error_generic')),
      data: (items) {
        if (items.isEmpty) {
          return Center(child: Text(l10n.t('no_data')));
        }

        final verifierId = profileAsync.valueOrNull?.id;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (ctx, i) {
            final c = items[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(c.profileName ?? 'Member'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMMM yyyy')
                          .format(DateTime(c.billingYear, c.billingMonth)),
                    ),
                    if (c.transactionReference != null)
                      Text('Ref: ${c.transactionReference}'),
                    Text('\$${c.amountPaid.toStringAsFixed(2)}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: verifierId == null
                          ? null
                          : () async {
                              await ref
                                  .read(contributionServiceProvider)
                                  .verifyContribution(
                                    contributionId: c.id,
                                    verifierId: verifierId,
                                    approve: true,
                                  );
                              ref.invalidate(pendingContributionsProvider);
                              ref.invalidate(poolBalanceProvider);
                              ref.invalidate(auditLedgerProvider);
                            },
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: verifierId == null
                          ? null
                          : () async {
                              await ref
                                  .read(contributionServiceProvider)
                                  .verifyContribution(
                                    contributionId: c.id,
                                    verifierId: verifierId,
                                    approve: false,
                                  );
                              ref.invalidate(pendingContributionsProvider);
                            },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
