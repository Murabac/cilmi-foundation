import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../models/payment_report.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/branch_filter.dart';
import '../../utils/lineage_name.dart';
import '../../widgets/add_family_member_dialog.dart';
import '../../widgets/branch_father_filters.dart';
import '../../widgets/dashboard_actions.dart';
import '../../widgets/widgets.dart';
import '../admin/treasury_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({
    super.key,
    this.onOpenGive,
    this.onOpenTree,
    this.onOpenPaymentHistory,
  });

  final VoidCallback? onOpenGive;
  final VoidCallback? onOpenTree;
  final VoidCallback? onOpenPaymentHistory;

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

  String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.t('greeting_morning');
    if (hour < 17) return l10n.t('greeting_afternoon');
    return l10n.t('greeting_evening');
  }

  @override
  Widget build(BuildContext context) {
    final l10nAsync = ref.watch(localizationsProvider);
    final profileAsync = ref.watch(currentProfileProvider);
    final countAsync = ref.watch(memberCountProvider);
    final membersAsync = ref.watch(allProfilesProvider);
    final locale = ref.watch(localeProvider);

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

        return RefreshIndicator(
          color: BrandColors.teal,
          onRefresh: () async {
            ref.invalidate(currentProfileProvider);
            ref.invalidate(memberCountProvider);
            ref.invalidate(allProfilesProvider);
            ref.invalidate(carePriorityProvider);
            ref.invalidate(poolBalanceProvider);
            ref.invalidate(myContributionsProvider);
            if (canPayments) ref.invalidate(monthlyPaymentReportProvider);
            ref.invalidate(fullLineageTreeProvider);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _HomeHeader(
                  greeting: _greeting(l10n),
                  name: profile?.fullName ?? '…',
                  l10n: l10n,
                  showBell: canPayments || isSuperAdmin,
                  onBell: () =>
                      Navigator.pushNamed(context, '/verification'),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  profile != null && profile.isPayer ? 0 : 14,
                  16,
                  28,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Transform.translate(
                      // Hero card overlaps the teal header (~50 px). Without a
                      // hero (non-payers), skip the pull-up so quick links stay visible.
                      offset: Offset(
                        0,
                        profile != null && profile.isPayer ? -50 : 0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (profile != null && profile.isPayer)
                            _ContributionHeroCard(
                              l10n: l10n,
                              locale: locale,
                              profile: profile,
                              onPay: widget.onOpenGive,
                            ),
                          if (profile != null && profile.isPayer)
                            const SizedBox(height: 14),
                          _QuickLinksRow(
                            l10n: l10n,
                            onTree: widget.onOpenTree,
                            onHistory: widget.onOpenPaymentHistory,
                          ),
                          if (profile != null &&
                              profile.maritalStatus !=
                                  MaritalStatus.deceased) ...[
                            const SizedBox(height: 14),
                            MonthlyStatusCard(profile: profile, l10n: l10n),
                          ],
                          const SizedBox(height: 14),
                          _FamilyStatusCard(
                            l10n: l10n,
                            memberCountAsync: countAsync,
                            membersAsync: membersAsync,
                            showPaidStat: canPayments,
                          ),
                          const SizedBox(height: 14),
                          _PoolBalanceHero(
                            l10n: l10n,
                            canOpenTreasury: canTreasury,
                          ),
                          if (canCare) ...[
                            const SizedBox(height: 14),
                            StaffQuickActions(
                              l10n: l10n,
                              canPayments: canPayments,
                              canTreasury: canTreasury,
                              isSuperAdmin: isSuperAdmin,
                            ),
                          ],
                          if (isSuperAdmin) ...[
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: FilledButton.tonalIcon(
                                onPressed: () async {
                                  final added =
                                      await showAddFamilyMemberDialog(
                                    context,
                                    ref,
                                  );
                                  if (added && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text(l10n.t('add_member_success')),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(
                                  Icons.person_add_outlined,
                                  size: 18,
                                ),
                                label: Text(l10n.t('add_family_member')),
                              ),
                            ),
                          ],
                          const SizedBox(height: 28),
                          Text(
                            l10n.t('care_priority_feed'),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(color: BrandColors.ink),
                          ),
                          const SizedBox(height: 14),
                          membersAsync.when(
                            loading: () =>
                                LoadingView(message: l10n.t('loading')),
                            error: (e, _) => ErrorView(message: e.toString()),
                            data: (members) {
                              final branchIndex =
                                  BranchFilterIndex.fromProfiles(members);
                              final byId = {
                                for (final p in members) p.id: p,
                              };
                              final scopeId =
                                  _subBranchFilterId ?? _branchFilterId;
                              final households = branchIndex
                                  .filterByBranch(
                                    members.where(
                                      (p) =>
                                          p.maritalStatus ==
                                          MaritalStatus.married,
                                    ),
                                    scopeId,
                                    profileId: (p) => p.id,
                                  )
                                  .toList();
                              branchIndex.sortByGeneration(
                                households,
                                scopeId,
                              );
                              final stable = households
                                  .where((p) => p.careRating == 1)
                                  .toList();
                              final underPressure = households
                                  .where((p) => p.careRating == 2)
                                  .toList();
                              final needsSupport = households
                                  .where((p) => p.careRating == 3)
                                  .toList();

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
                          // Offset for the -50 overlap so list end isn't clipped oddly.
                          const SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.greeting,
    required this.name,
    required this.l10n,
    required this.showBell,
    required this.onBell,
  });

  final String greeting;
  final String name;
  final AppLocalizations l10n;
  final bool showBell;
  final VoidCallback onBell;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      width: double.infinity,
      color: BrandColors.teal,
      padding: EdgeInsets.fromLTRB(20, top + 12, 20, 70),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppLogo(
                height: 36,
                variant: AppLogoVariant.markReversed,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'CILMI',
                  style: TextStyle(
                    color: BrandColors.linen,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    letterSpacing: 2.1,
                  ),
                ),
              ),
              if (showBell)
                IconButton(
                  onPressed: onBell,
                  tooltip: l10n.t('notifications'),
                  style: IconButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    side: BorderSide(
                      color: BrandColors.linen.withValues(alpha: 0.25),
                    ),
                    shape: const CircleBorder(),
                  ),
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: BrandColors.linen,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            greeting,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: BrandColors.onTealMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: BrandColors.linen,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContributionHeroCard extends ConsumerWidget {
  const _ContributionHeroCard({
    required this.l10n,
    required this.locale,
    required this.profile,
    this.onPay,
  });

  final AppLocalizations l10n;
  final String locale;
  final Profile profile;
  final VoidCallback? onPay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contributionsAsync = ref.watch(myContributionsProvider);
    final settingsAsync = ref.watch(globalSettingsProvider);
    final now = DateTime.now();
    final monthName = DateFormat.MMMM(locale == 'so' ? 'so' : 'en').format(now);
    final title = l10n
        .t('contribution_for_month')
        .replaceAll('{month}', monthName);

    final amount = profile.monthlyAmount ??
        settingsAsync.valueOrNull?.currentAdultRate ??
        0;

    return contributionsAsync.when(
      loading: () => _contributionShell(
        title: title,
        amount: amount,
        pill: '…',
        pillBg: BrandColors.mint,
        pillFg: BrandColors.teal,
        onPay: onPay,
        l10n: l10n,
      ),
      error: (_, _) => _contributionShell(
        title: title,
        amount: amount,
        pill: l10n.t('pending'),
        pillBg: BrandColors.urgentBg,
        pillFg: BrandColors.urgent,
        onPay: onPay,
        l10n: l10n,
      ),
      data: (list) {
        final current = list
            .where(
              (c) => c.billingMonth == now.month && c.billingYear == now.year,
            )
            .firstOrNull;
        final awaiting = current?.status == PaymentStatus.pending &&
            current?.transactionReference != null;
        final (pill, bg, fg) = switch (current?.status) {
          PaymentStatus.approved => (
              l10n.t('paid'),
              BrandColors.mint,
              BrandColors.paid,
            ),
          PaymentStatus.rejected => (
              l10n.t('rejected'),
              BrandColors.urgentBg,
              BrandColors.urgent,
            ),
          PaymentStatus.pending when awaiting => (
              l10n.t('pending_verification'),
              BrandColors.pendingBg,
              BrandColors.pendingInk,
            ),
          _ => (
              l10n.t('pending'),
              BrandColors.urgentBg,
              BrandColors.urgent,
            ),
        };
        final showPay = onPay != null && current?.status != PaymentStatus.approved;

        return _contributionShell(
          title: title,
          amount: current?.amountDue ?? amount,
          pill: pill,
          pillBg: bg,
          pillFg: fg,
          onPay: showPay ? onPay : null,
          l10n: l10n,
        );
      },
    );
  }

  Widget _contributionShell({
    required String title,
    required double amount,
    required String pill,
    required Color pillBg,
    required Color pillFg,
    required VoidCallback? onPay,
    required AppLocalizations l10n,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: BrandColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BrandColors.border),
        boxShadow: [
          BoxShadow(
            color: BrandColors.teal.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
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
                  pill,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: pillFg,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '\$${amount.toStringAsFixed(amount == amount.roundToDouble() ? 0 : 2)}',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: BrandColors.teal,
                  height: 1,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                l10n.t('per_month_suffix'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: BrandColors.muted,
                ),
              ),
            ],
          ),
          if (onPay != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: onPay,
                style: FilledButton.styleFrom(
                  backgroundColor: BrandColors.gold,
                  foregroundColor: BrandColors.onGold,
                  textStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.phone_in_talk_rounded, size: 20),
                label: Text(l10n.t('pay_now')),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickLinksRow extends StatelessWidget {
  const _QuickLinksRow({
    required this.l10n,
    this.onTree,
    this.onHistory,
  });

  final AppLocalizations l10n;
  final VoidCallback? onTree;
  final VoidCallback? onHistory;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickLinkCard(
            icon: Icons.account_tree_outlined,
            label: l10n.t('quick_family_tree'),
            onTap: onTree,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickLinkCard(
            icon: Icons.bar_chart_rounded,
            label: l10n.t('payment_history'),
            onTap: onHistory,
          ),
        ),
      ],
    );
  }
}

class _QuickLinkCard extends StatelessWidget {
  const _QuickLinkCard({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BrandColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: BrandColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: BrandColors.mint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: BrandColors.teal, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: BrandColors.ink,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FamilyStatusCard extends ConsumerWidget {
  const _FamilyStatusCard({
    required this.l10n,
    required this.memberCountAsync,
    required this.membersAsync,
    required this.showPaidStat,
  });

  final AppLocalizations l10n;
  final AsyncValue<int> memberCountAsync;
  final AsyncValue<List<Profile>> membersAsync;
  final bool showPaidStat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = membersAsync.valueOrNull ?? const <Profile>[];
    final households =
        members.where((p) => p.maritalStatus == MaritalStatus.married).length;
    final memberCount = memberCountAsync.valueOrNull ?? members.length;

    String paidLabel = '…';
    if (showPaidStat) {
      final report = ref.watch(monthlyPaymentReportProvider).valueOrNull;
      if (report != null) paidLabel = '${report.paidCount}';
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: BrandColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BrandColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.t('family_status'),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: BrandColors.ink,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  value: '$memberCount',
                  label: l10n.t('members_count_label'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  value: '$households',
                  label: l10n.t('households_count_label'),
                ),
              ),
              if (showPaidStat) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: _MiniStat(
                    value: paidLabel,
                    label: l10n.t('paid_this_month_label'),
                    onTap: () {
                      final now = DateTime.now();
                      ref.read(selectedBillingPeriodProvider.notifier).state =
                          BillingPeriod(month: now.month, year: now.year);
                      ref
                          .read(selectedPaymentReportFilterProvider.notifier)
                          .state = PaymentReportFilter.paid;
                      Navigator.pushNamed(context, '/payments-report');
                    },
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.value,
    required this.label,
    this.onTap,
  });

  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BrandColors.linen,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: BrandColors.teal,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: BrandColors.muted,
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return child;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: child,
      ),
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
      color: BrandColors.teal,
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
                      style: TextStyle(
                        color: BrandColors.linen.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    balanceAsync.when(
                      loading: () => const Text(
                        '…',
                        style: TextStyle(
                          color: BrandColors.linen,
                          fontWeight: FontWeight.w700,
                          fontSize: 28,
                        ),
                      ),
                      error: (_, _) => const Text(
                        '—',
                        style: TextStyle(
                          color: BrandColors.linen,
                          fontWeight: FontWeight.w700,
                          fontSize: 28,
                        ),
                      ),
                      data: (balance) => Text(
                        '\$${balance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: BrandColors.linen,
                          fontWeight: FontWeight.w800,
                          fontSize: 28,
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
                  color: BrandColors.linen.withValues(alpha: 0.7),
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
      color: BrandColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: count > 0 ? () => setState(() => _expanded = !_expanded) : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
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
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.description,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: BrandColors.muted,
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
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: widget.color,
                                  height: 1,
                                ),
                      ),
                      Text(
                        widget.l10n.t('households_label'),
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: BrandColors.muted,
                                ),
                      ),
                    ],
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 4),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      color: BrandColors.muted,
                    ),
                  ],
                ],
              ),
              if (_expanded && count > 0) ...[
                const SizedBox(height: 14),
                const Divider(height: 1, color: BrandColors.border),
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
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: BrandColors.muted,
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
                                color: BrandColors.muted,
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
                            color: BrandColors.muted,
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
