import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../models/payment_report.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/branch_filter.dart';
import '../../utils/lineage_name.dart';
import '../../widgets/add_family_member_dialog.dart';
import '../../widgets/branch_father_filters.dart';
import '../../widgets/widgets.dart';
import '../admin/treasury_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String? _branchFilterId;
  String? _subBranchFilterId;

  void _onBranchChanged(String? branchId) {
    setState(() {
      _branchFilterId = branchId;
      _subBranchFilterId = null;
    });
  }

  void _onSubBranchChanged(String? subBranchId) {
    setState(() => _subBranchFilterId = subBranchId);
  }

  @override
  Widget build(BuildContext context) {
    final l10nAsync = ref.watch(localizationsProvider);
    final profileAsync = ref.watch(currentProfileProvider);
    final countAsync = ref.watch(memberCountProvider);
    final membersAsync = ref.watch(allProfilesProvider);

    return l10nAsync.when(
      loading: () => const LoadingView(),
      error: (_, _) => const ErrorView(message: 'Error'),
      data: (l10n) {
        final profile = profileAsync.valueOrNull;
        final role = profile?.role;
        final canPayments = role?.canManagePayments ?? false;
        final canCare = role?.canManageCare ?? false;
        final canTreasury = role?.canManageTreasury ?? false;
        final isSuperAdmin = role?.isSuperAdmin ?? false;
        final scheme = Theme.of(context).colorScheme;

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(currentProfileProvider);
            ref.invalidate(memberCountProvider);
            ref.invalidate(allProfilesProvider);
            ref.invalidate(carePriorityProvider);
            ref.invalidate(poolBalanceProvider);
            if (canPayments) ref.invalidate(monthlyPaymentReportProvider);
            ref.invalidate(fullLineageTreeProvider);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              if (profile != null) ...[
                Text(
                  l10n.t('welcome'),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.grey.shade600,
                        letterSpacing: 0.3,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.fullName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: BrandColors.navy,
                        height: 1.2,
                      ),
                ),
                const SizedBox(height: 20),
              ],

              // Pool balance visible to everyone; treasury staff can open treasury.
              _PoolBalanceHero(
                l10n: l10n,
                canOpenTreasury: canTreasury,
              ),
              const SizedBox(height: 14),

              countAsync.when(
                loading: () => const SizedBox(height: 88),
                error: (e, _) => ErrorView(message: e.toString()),
                data: (count) => _SummaryRow(
                  l10n: l10n,
                  memberCount: count,
                  showUnpaid: canPayments,
                  onAddMember: isSuperAdmin
                      ? () async {
                          final added = await showAddFamilyMemberDialog(
                            context,
                            ref,
                          );
                          if (added && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.t('add_member_success')),
                              ),
                            );
                          }
                        }
                      : null,
                ),
              ),

              const SizedBox(height: 28),
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    l10n.t('family_status'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: BrandColors.navy,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              membersAsync.when(
                loading: () => LoadingView(message: l10n.t('loading')),
                error: (e, _) => ErrorView(message: e.toString()),
                data: (members) {
                  final branchIndex = BranchFilterIndex.fromProfiles(members);
                  final byId = {for (final p in members) p.id: p};
                  // Care status is tracked per married household (Reer).
                  final scopeId = _subBranchFilterId ?? _branchFilterId;
                  final households = branchIndex
                      .filterByBranch(
                        members.where(
                          (p) => p.maritalStatus == MaritalStatus.married,
                        ),
                        scopeId,
                        profileId: (p) => p.id,
                      )
                      .toList();
                  branchIndex.sortByGeneration(households, scopeId);
                  final stable =
                      households.where((p) => p.careRating == 1).toList();
                  final underPressure =
                      households.where((p) => p.careRating == 2).toList();
                  final needsSupport =
                      households.where((p) => p.careRating == 3).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (branchIndex.branches.isNotEmpty) ...[
                        BranchFatherFilters(
                          index: branchIndex,
                          l10n: l10n,
                          branchId: _branchFilterId,
                          subBranchId: _subBranchFilterId,
                          fatherFilterId: null,
                          onBranchChanged: _onBranchChanged,
                          onSubBranchChanged: _onSubBranchChanged,
                          onFatherChanged: (_) {},
                          showFatherFilter: false,
                        ),
                        const SizedBox(height: 14),
                      ],
                      _CareGroupCard(
                        l10n: l10n,
                        title: l10n.t('care_group_1'),
                        description: l10n.t('care_group_1_desc'),
                        profiles: stable,
                        byId: byId,
                        color: CareRatingTheme.colorFor(1),
                        icon: Icons.check_circle_outline,
                        isAdmin: canCare,
                        ref: ref,
                      ),
                      const SizedBox(height: 10),
                      _CareGroupCard(
                        l10n: l10n,
                        title: l10n.t('care_group_2'),
                        description: l10n.t('care_group_2_desc'),
                        profiles: underPressure,
                        byId: byId,
                        color: CareRatingTheme.colorFor(2),
                        icon: Icons.warning_amber_outlined,
                        isAdmin: canCare,
                        ref: ref,
                      ),
                      const SizedBox(height: 10),
                      _CareGroupCard(
                        l10n: l10n,
                        title: l10n.t('care_group_3'),
                        description: l10n.t('care_group_3_desc'),
                        profiles: needsSupport,
                        byId: byId,
                        color: CareRatingTheme.colorFor(3),
                        icon: Icons.error_outline,
                        isAdmin: canCare,
                        ref: ref,
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
}

class _PoolBalanceHero extends ConsumerWidget {
  const _PoolBalanceHero({
    required this.l10n,
    this.canOpenTreasury = false,
  });

  final AppLocalizations l10n;
  final bool canOpenTreasury;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(poolBalanceProvider);

    return Material(
      color: BrandColors.navy,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: canOpenTreasury
            ? () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TreasuryScreen()),
                )
            : null,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: BrandColors.gold.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: BrandColors.gold,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.t('total_pool_balance'),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 6),
                    balanceAsync.when(
                      loading: () => Text(
                        '…',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      error: (_, _) => Text(
                        '—',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      data: (balance) => Text(
                        '\$${balance.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              if (canOpenTreasury)
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends ConsumerWidget {
  const _SummaryRow({
    required this.l10n,
    required this.memberCount,
    required this.showUnpaid,
    this.onAddMember,
  });

  final AppLocalizations l10n;
  final int memberCount;
  final bool showUnpaid;
  final VoidCallback? onAddMember;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _StatTile(
                label: l10n.t('total_members'),
                value: '$memberCount',
                icon: Icons.groups_rounded,
                accent: BrandColors.navy,
              ),
            ),
            if (showUnpaid) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Consumer(
                  builder: (context, ref, _) {
                    final reportAsync =
                        ref.watch(monthlyPaymentReportProvider);
                    return reportAsync.when(
                      loading: () => _StatTile(
                        label: l10n.t('payment_report'),
                        value: '…',
                        icon: Icons.receipt_long_outlined,
                        accent: BrandColors.gold,
                      ),
                      error: (_, _) => _StatTile(
                        label: l10n.t('payment_report'),
                        value: '—',
                        icon: Icons.receipt_long_outlined,
                        accent: BrandColors.gold,
                      ),
                      data: (report) => _StatTile(
                        label: l10n.t('filter_unpaid'),
                        value: '${report.unpaidCount}',
                        icon: Icons.receipt_long_outlined,
                        accent: const Color(0xFFDC2626),
                        onTap: () {
                          final now = DateTime.now();
                          ref
                              .read(selectedBillingPeriodProvider.notifier)
                              .state = BillingPeriod(
                            month: now.month,
                            year: now.year,
                          );
                          ref
                              .read(
                                selectedPaymentReportFilterProvider.notifier,
                              )
                              .state = PaymentReportFilter.unpaid;
                          Navigator.pushNamed(context, '/payments-report');
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
        if (onAddMember != null) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonalIcon(
              onPressed: onAddMember,
              icon: const Icon(Icons.person_add_outlined, size: 18),
              label: Text(l10n.t('add_family_member')),
            ),
          ),
        ],
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: accent, size: 22),
              const SizedBox(height: 12),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: BrandColors.navy,
                      height: 1.1,
                    ),
              ),
            ],
          ),
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
    required this.byId,
    required this.color,
    required this.icon,
    required this.isAdmin,
    required this.ref,
  });

  final AppLocalizations l10n;
  final String title;
  final String description;
  final List<Profile> profiles;
  final Map<String, Profile> byId;
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

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: count > 0 ? () => setState(() => _expanded = !_expanded) : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.color.withValues(alpha: 0.28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.icon, color: widget.color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                                height: 1.3,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$count',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: widget.color,
                              height: 1,
                            ),
                      ),
                      Text(
                        widget.l10n.t('households_label'),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 4),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey.shade500,
                    ),
                  ],
                ],
              ),
              if (_expanded && count > 0) ...[
                const SizedBox(height: 14),
                Divider(height: 1, color: Colors.grey.shade200),
                const SizedBox(height: 12),
                ...widget.profiles.map((p) {
                  final lineage = buildLineageDisplayInfo(p, widget.byId);
                  final reerName = widget.l10n
                      .t('reer_household')
                      .replaceAll('{name}', p.fullName);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: CareRatingTheme.colorFor(p.careRating)
                              .withValues(alpha: 0.18),
                          child: Text(
                            p.fullName.isNotEmpty
                                ? p.fullName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: CareRatingTheme.colorFor(p.careRating),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reerName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (lineage.subtitleText != null)
                                Text(
                                  lineage.subtitleText!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        CareRatingBadge(
                          rating: p.careRating,
                          l10n: widget.l10n,
                          compact: true,
                        ),
                        if (widget.isAdmin)
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            onPressed: () => _showCareRatingDialog(
                              context,
                              widget.ref,
                              p,
                              widget.l10n,
                            ),
                          ),
                      ],
                    ),
                  );
                }),
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
    var rating = CareRatingTheme.normalize(profile.careRating);
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
                  Text(
                    l10n
                        .t('reer_household')
                        .replaceAll('{name}', profile.fullName),
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  lineageAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                    data: (name) {
                      if (name.isEmpty || name == profile.fullName) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          name,
                          style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade700,
                              ),
                        ),
                      );
                    },
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
                  CareRatingPicker(
                    value: rating,
                    l10n: l10n,
                    onChanged: (v) => setState(() => rating = v),
                  ),
                  const SizedBox(height: 8),
                  CareRatingBadge(rating: rating, l10n: l10n),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.t('cancel')),
          ),
          FilledButton(
            onPressed: () async {
              if (hasChildren &&
                  rating != CareRatingTheme.normalize(profile.careRating)) {
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
              // Pop before invalidate — refreshing providers under an open
              // dialog can trigger InheritedWidget dependent assertion errors.
              if (ctx.mounted) Navigator.pop(ctx);
              ref.invalidate(allProfilesProvider);
              ref.invalidate(carePriorityProvider);
              ref.invalidate(fullLineageTreeProvider);
              ref.invalidate(profileLineageNameProvider(profile.id));
            },
            child: Text(l10n.t('save')),
          ),
        ],
      ),
    );
  }
}
