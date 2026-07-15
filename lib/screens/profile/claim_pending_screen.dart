import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../utils/phone_utils.dart';
import '../../widgets/widgets.dart';

/// Shown while an admin reviews the user's profile link request.
class ClaimPendingScreen extends ConsumerStatefulWidget {
  const ClaimPendingScreen({super.key});

  @override
  ConsumerState<ClaimPendingScreen> createState() => _ClaimPendingScreenState();
}

class _ClaimPendingScreenState extends ConsumerState<ClaimPendingScreen> {
  bool _approving = false;

  Future<void> _refresh() async {
    ref.invalidate(myPendingClaimProvider);
    ref.invalidate(currentProfileProvider);
  }

  Future<void> _selfApprove(AppLocalizations l10n, String claimId) async {
    setState(() => _approving = true);
    try {
      await ref.read(profileServiceProvider).approveProfileClaim(claimId);
      ref.invalidate(myPendingClaimProvider);
      ref.invalidate(currentProfileProvider);
      ref.invalidate(allProfilesProvider);
      ref.invalidate(fullLineageTreeProvider);
      ref.invalidate(memberCountProvider);
      ref.invalidate(unclaimedProfilesProvider);
      ref.invalidate(pendingClaimRequestsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.t('claim_self_approved'))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(claimErrorMessage(e, l10n))),
        );
      }
    } finally {
      if (mounted) setState(() => _approving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10nAsync = ref.watch(localizationsProvider);
    final pendingAsync = ref.watch(myPendingClaimProvider);
    final profileAsync = ref.watch(currentProfileProvider);

    return l10nAsync.when(
      loading: () => const Scaffold(body: LoadingView()),
      error: (_, __) => const Scaffold(body: ErrorView(message: 'Error')),
      data: (l10n) => pendingAsync.when(
        loading: () => LoadingView(message: l10n.t('loading')),
        error: (e, _) => ErrorView(
          message: claimErrorMessage(e, l10n),
          onRetry: _refresh,
        ),
        data: (pending) {
          if (pending == null) {
            return LoadingView(message: l10n.t('loading'));
          }

          final isSuperAdmin =
              profileAsync.valueOrNull?.role == UserRole.superAdmin;

          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.t('claim_pending_title')),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _refresh,
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => ref.read(authServiceProvider).signOut(),
                ),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.hourglass_top,
                      size: 56,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.t('claim_pending_title'),
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isSuperAdmin
                          ? l10n.t('claim_pending_super_admin_body')
                          : l10n.t('claim_pending_body'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.t('claim_requested_profile'),
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              pending.profileFullName ?? pending.requesterName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            if (pending.requesterPhone != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                '${l10n.t('mobile')}: ${pending.requesterPhone}',
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (isSuperAdmin) ...[
                      FilledButton.icon(
                        onPressed: _approving
                            ? null
                            : () => _selfApprove(l10n, pending.id),
                        icon: _approving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.verified_user),
                        label: Text(l10n.t('claim_self_approve')),
                      ),
                      const SizedBox(height: 8),
                    ],
                    OutlinedButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.t('claim_check_status')),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
