import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/add_family_member_dialog.dart';
import '../../widgets/widgets.dart';
import '../admin/treasury_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10nAsync = ref.watch(localizationsProvider);
    final profileAsync = ref.watch(currentProfileProvider);
    final countAsync = ref.watch(memberCountProvider);
    final membersAsync = ref.watch(allProfilesProvider);

    return l10nAsync.when(
      loading: () => const LoadingView(),
      error: (_, __) => const ErrorView(message: 'Error'),
      data: (l10n) {
        final profile = profileAsync.valueOrNull;
        final isAdmin = profile?.role.isAdminOrManager ?? false;

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(currentProfileProvider);
            ref.invalidate(memberCountProvider);
            ref.invalidate(allProfilesProvider);
            ref.invalidate(carePriorityProvider);
            ref.invalidate(poolBalanceProvider);
            ref.invalidate(monthlyPaymentReportProvider);
            ref.invalidate(fullLineageTreeProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (profile != null)
                Text(
                  '${l10n.t('welcome')}, ${profile.fullName}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              const SizedBox(height: 16),
              countAsync.when(
                loading: () => const LoadingView(message: '...'),
                error: (e, _) => ErrorView(message: e.toString()),
                data: (count) => _FamilyCountCard(
                  count: count,
                  l10n: l10n,
                  isAdmin: isAdmin,
                  onAddMember: isAdmin
                      ? () async {
                          final added = await showAddFamilyMemberDialog(
                            context,
                            ref,
                          );
                          if (added && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.t('add_member_success'))),
                            );
                          }
                        }
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              membersAsync.when(
                loading: () => LoadingView(message: l10n.t('loading')),
                error: (e, _) => ErrorView(message: e.toString()),
                data: (members) {
                  final belowThree =
                      members.where((p) => p.careRating < 3).toList();
                  final exactlyThree =
                      members.where((p) => p.careRating == 3).toList();
                  final aboveThree =
                      members.where((p) => p.careRating > 3).toList();

                  return Column(
                    children: [
                      _CareGroupCard(
                        l10n: l10n,
                        title: l10n.t('care_below_3'),
                        description: l10n.t('care_below_3_desc'),
                        profiles: belowThree,
                        color: CareRatingTheme.colorFor(2),
                        icon: Icons.check_circle_outline,
                        isAdmin: isAdmin,
                        ref: ref,
                      ),
                      const SizedBox(height: 12),
                      _CareGroupCard(
                        l10n: l10n,
                        title: l10n.t('care_at_3'),
                        description: l10n.t('care_at_3_desc'),
                        profiles: exactlyThree,
                        color: CareRatingTheme.colorFor(3),
                        icon: Icons.warning_amber_outlined,
                        isAdmin: isAdmin,
                        ref: ref,
                      ),
                      const SizedBox(height: 12),
                      _CareGroupCard(
                        l10n: l10n,
                        title: l10n.t('care_above_3'),
                        description: l10n.t('care_above_3_desc'),
                        profiles: aboveThree,
                        color: CareRatingTheme.colorFor(5),
                        icon: Icons.error_outline,
                        isAdmin: isAdmin,
                        ref: ref,
                      ),
                    ],
                  );
                },
              ),
              if (isAdmin) ...[
                const SizedBox(height: 16),
                _AdminMetrics(l10n: l10n),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _FamilyCountCard extends StatelessWidget {
  const _FamilyCountCard({
    required this.count,
    required this.l10n,
    this.isAdmin = false,
    this.onAddMember,
  });

  final int count;
  final AppLocalizations l10n;
  final bool isAdmin;
  final VoidCallback? onAddMember;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.groups_rounded,
                size: 36,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.t('total_members'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$count',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  Text(
                    l10n.t('view_full_tree_hint'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                  ),
                  if (onAddMember != null) ...[
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      onPressed: onAddMember,
                      icon: const Icon(Icons.person_add_outlined, size: 18),
                      label: Text(l10n.t('add_family_member')),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CareGroupCard extends StatefulWidget {
  const _CareGroupCard({
    required this.l10n,
    required this.title,
    required this.description,
    required this.profiles,
    required this.color,
    required this.icon,
    required this.isAdmin,
    required this.ref,
  });

  final AppLocalizations l10n;
  final String title;
  final String description;
  final List<Profile> profiles;
  final Color color;
  final IconData icon;
  final bool isAdmin;
  final WidgetRef ref;

  @override
  State<_CareGroupCard> createState() => _CareGroupCardState();
}

class _CareGroupCardState extends State<_CareGroupCard> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    final count = widget.profiles.length;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: widget.color.withValues(alpha: 0.4)),
      ),
      child: InkWell(
        onTap: count > 0 ? () => setState(() => _expanded = !_expanded) : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.icon, color: widget.color, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          widget.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$count',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: widget.color,
                            ),
                      ),
                      Text(
                        widget.l10n.t('members_label'),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 8),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ],
              ),
              if (_expanded && count > 0) ...[
                const Divider(height: 24),
                ...widget.profiles.map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor:
                              CareRatingTheme.colorFor(p.careRating).withValues(alpha: 0.2),
                          child: Text(
                            p.fullName.isNotEmpty ? p.fullName[0].toUpperCase() : '?',
                            style: TextStyle(
                              fontSize: 12,
                              color: CareRatingTheme.colorFor(p.careRating),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            p.fullName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        CareRatingBadge(
                          rating: p.careRating,
                          l10n: widget.l10n,
                          compact: true,
                        ),
                        if (widget.isAdmin)
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18),
                            onPressed: () => _showCareRatingDialog(
                              context,
                              widget.ref,
                              p,
                              widget.l10n,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCareRatingDialog(
    BuildContext context,
    WidgetRef ref,
    Profile profile,
    AppLocalizations l10n,
  ) async {
    var rating = profile.careRating;
    final hasChildren = ref.read(allProfilesProvider).valueOrNull
            ?.any((p) => p.fatherId == profile.id) ??
        false;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.t('update_care_rating')),
        content: StatefulBuilder(
          builder: (ctx, setState) => Consumer(
            builder: (ctx, ref, _) {
              final lineageAsync =
                  ref.watch(profileLineageNameProvider(profile.id));

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  lineageAsync.when(
                    loading: () => Text(
                      profile.fullName,
                      style: Theme.of(ctx).textTheme.titleMedium,
                    ),
                    error: (_, __) => Text(
                      profile.fullName,
                      style: Theme.of(ctx).textTheme.titleMedium,
                    ),
                    data: (name) => Text(
                      name,
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  if (hasChildren) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.t('care_rating_applies_to_children'),
                      style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Slider(
                    value: rating.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: l10n.t(CareRatingTheme.labelKey(rating)),
                    onChanged: (v) => setState(() => rating = v.round()),
                  ),
                  CareRatingBadge(rating: rating, l10n: l10n),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (hasChildren && rating != profile.careRating) {
                final all = ref.read(allProfilesProvider).valueOrNull ?? [];
                final count = ref
                    .read(profileServiceProvider)
                    .descendantCount(profile.id, all);
                final confirmed = await showDialog<bool>(
                  context: ctx,
                  builder: (confirmCtx) => AlertDialog(
                    title: Text(l10n.t('update_care_rating')),
                    content: Text(
                      l10n
                          .t('care_rating_cascade_confirm')
                          .replaceAll('{count}', '$count'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(confirmCtx, false),
                        child: Text(l10n.t('cancel')),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(confirmCtx, true),
                        child: Text(l10n.t('save')),
                      ),
                    ],
                  ),
                );
                if (confirmed != true) return;
              }

              await ref
                  .read(profileServiceProvider)
                  .updateCareRating(profile.id, rating);
              ref.invalidate(allProfilesProvider);
              ref.invalidate(carePriorityProvider);
              ref.invalidate(fullLineageTreeProvider);
              ref.invalidate(profileLineageNameProvider(profile.id));
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(l10n.t('save')),
          ),
        ],
      ),
    );
  }
}

class _AdminMetrics extends ConsumerWidget {
  const _AdminMetrics({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(poolBalanceProvider);
    final reportAsync = ref.watch(monthlyPaymentReportProvider);

    return Row(
      children: [
        Expanded(
          child: balanceAsync.when(
            loading: () => MetricCard(title: l10n.t('total_pool_balance'), value: '...'),
            error: (_, __) => MetricCard(title: l10n.t('total_pool_balance'), value: '—'),
            data: (balance) => MetricCard(
              title: l10n.t('total_pool_balance'),
              value: '\$${balance.toStringAsFixed(2)}',
              icon: Icons.account_balance_wallet,
              color: const Color(0xFF059669),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TreasuryScreen()),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: reportAsync.when(
            loading: () => MetricCard(title: l10n.t('payment_report'), value: '...'),
            error: (_, __) => MetricCard(title: l10n.t('payment_report'), value: '—'),
            data: (report) => MetricCard(
              title: l10n.t('payment_report'),
              value: l10n
                  .t('dashboard_unpaid_this_month')
                  .replaceAll('{count}', '${report.unpaidCount}'),
              icon: Icons.receipt_long_outlined,
              color: Theme.of(context).colorScheme.primary,
              onTap: () {
                final now = DateTime.now();
                ref.read(selectedBillingPeriodProvider.notifier).state =
                    BillingPeriod(month: now.month, year: now.year);
                Navigator.pushNamed(context, '/payments-report');
              },
            ),
          ),
        ),
      ],
    );
  }
}
