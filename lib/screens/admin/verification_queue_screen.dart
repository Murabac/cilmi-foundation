import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

class VerificationQueueScreen extends ConsumerWidget {
  const VerificationQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10nAsync = ref.watch(localizationsProvider);
    final pendingAsync = ref.watch(pendingContributionsProvider);
    final profileAsync = ref.watch(currentProfileProvider);

    return l10nAsync.when(
      loading: () => const Scaffold(body: LoadingView()),
      error: (_, __) => const Scaffold(body: ErrorView(message: 'Error')),
      data: (l10n) => Scaffold(
        appBar: AppBar(title: Text(l10n.t('verification_queue'))),
        body: pendingAsync.when(
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
        ),
      ),
    );
  }
}
