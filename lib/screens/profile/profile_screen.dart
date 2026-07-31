import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';
import '../../widgets/member_business_card.dart';
import '../../widgets/widgets.dart';
import 'lineage_setup_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({
    super.key,
    this.showAppBar = true,
    this.onViewInTree,
  });

  /// When embedded in [HomeShell], hide the local AppBar to avoid a double bar.
  final bool showAppBar;

  /// Optional override when embedded (switch to the tree tab instead of popping).
  final VoidCallback? onViewInTree;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10nAsync = ref.watch(localizationsProvider);
    final profileAsync = ref.watch(currentProfileProvider);

    return l10nAsync.when(
      loading: () => const Scaffold(body: LoadingView()),
      error: (_, _) => const Scaffold(body: ErrorView(message: 'Error')),
      data: (l10n) {
        final profile = profileAsync.valueOrNull;
        final needsSetup =
            ref.read(profileServiceProvider).needsLineageSetup(profile);

        if (needsSetup) {
          return const LineageSetupScreen();
        }

        if (profileAsync.isLoading) {
          return Scaffold(body: LoadingView(message: l10n.t('loading')));
        }

        if (profile == null) {
          return Scaffold(
            body: ErrorView(message: l10n.t('no_profile_linked')),
          );
        }

        final body = ListView(
          padding: const EdgeInsets.all(24),
          children: [
            if (!showAppBar) ...[
              Text(
                l10n.t('my_profile'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 16),
            ],
            MemberBusinessCardContent(profile: profile, l10n: l10n),
            const SizedBox(height: 16),
            Row(
              children: [
                RoleBadge(role: profile.role, l10n: l10n),
                const SizedBox(width: 8),
                DemographicBadge(
                  demographic: profile.demographic,
                  l10n: l10n,
                ),
              ],
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                ref.read(focusedProfileIdProvider.notifier).state = profile.id;
                if (onViewInTree != null) {
                  onViewInTree!();
                } else if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.account_tree),
              label: Text(l10n.t('view_in_tree')),
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: () async {
                await ref.read(authServiceProvider).signOut();
                if (context.mounted && Navigator.canPop(context) && showAppBar) {
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.logout),
              label: Text(l10n.t('sign_out')),
            ),
          ],
        );

        if (!showAppBar) {
          return body;
        }

        return Scaffold(
          appBar: AppBar(title: Text(l10n.t('my_profile'))),
          body: body,
        );
      },
    );
  }
}
