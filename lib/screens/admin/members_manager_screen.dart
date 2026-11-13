import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../utils/branch_filter.dart';
import '../../utils/lineage_name.dart';
import '../../utils/phone_utils.dart';
import '../../utils/profile_sort.dart';
import '../../utils/somali_search.dart';
import '../../widgets/member_edit_sheet.dart';
import '../../widgets/member_status_fields.dart';
import '../../widgets/widgets.dart';

enum _QuickFilter { all, payers, needsStatus, noPhone }

/// Find any member fast (spelling-tolerant search, reer chips, quick filters)
/// and edit them in one sheet.
class MembersManagerScreen extends ConsumerStatefulWidget {
  const MembersManagerScreen({super.key});

  @override
  ConsumerState<MembersManagerScreen> createState() =>
      _MembersManagerScreenState();
}

class _MembersManagerScreenState extends ConsumerState<MembersManagerScreen> {
  final _searchCtrl = TextEditingController();
  var _query = '';
  String? _branchId;
  var _quick = _QuickFilter.all;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _quickLabel(AppLocalizations l10n, _QuickFilter f) => switch (f) {
        _QuickFilter.all => l10n.t('filter_all'),
        _QuickFilter.payers => l10n.t('filter_payers'),
        _QuickFilter.needsStatus => l10n.t('filter_needs_status'),
        _QuickFilter.noPhone => l10n.t('filter_no_phone'),
      };

  bool _matchesQuick(Profile p) => switch (_quick) {
        _QuickFilter.all => true,
        _QuickFilter.payers => p.isPayer,
        _QuickFilter.needsStatus =>
          p.maritalStatus != MaritalStatus.deceased && p.statusIsStale,
        _QuickFilter.noPhone => (p.phoneNumber ?? '').trim().isEmpty,
      };

  @override
  Widget build(BuildContext context) {
    final l10nAsync = ref.watch(localizationsProvider);
    final profilesAsync = ref.watch(allProfilesProvider);

    return l10nAsync.when(
      loading: () => const Scaffold(body: LoadingView()),
      error: (_, _) => const Scaffold(body: ErrorView(message: 'Error')),
      data: (l10n) => Scaffold(
        appBar: AppBar(title: Text(l10n.t('manage_members'))),
        body: profilesAsync.when(
          loading: () => LoadingView(message: l10n.t('loading')),
          error: (e, _) => ErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(allProfilesProvider),
          ),
          data: (all) {
            final profiles = sortProfilesInTreeAgeOrder(all);
            final byId = {for (final p in profiles) p.id: p};
            final index = BranchFilterIndex.fromProfiles(profiles);
            final lineage = {
              for (final p in profiles) p.id: buildFullMemberName(p, byId),
            };

            final results = profiles.where((p) {
              if (_branchId != null && !index.isInBranch(p.id, _branchId!)) {
                return false;
              }
              if (!_matchesQuick(p)) return false;
              return somaliSearchMatches(
                _query,
                lineage[p.id] ?? p.fullName,
                phone: p.phoneNumber,
              );
            }).toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: l10n.t('members_search_hint'),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: l10n.t('cancel'),
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _query = '');
                              },
                            ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(l10n.t('all_branches')),
                          selected: _branchId == null,
                          onSelected: (_) => setState(() => _branchId = null),
                        ),
                      ),
                      ...index.branches.map(
                        (b) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                              'Reer ${somaliTitleWord(b.fullName.split(' ').first)}',
                            ),
                            selected: _branchId == b.id,
                            onSelected: (_) =>
                                setState(() => _branchId = b.id),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: _QuickFilter.values
                        .map(
                          (f) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(_quickLabel(l10n, f)),
                              selected: _quick == f,
                              onSelected: (_) => setState(() => _quick = f),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n
                          .t('branch_members_count')
                          .replaceAll('{count}', '${results.length}'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                    ),
                  ),
                ),
                Expanded(
                  child: results.isEmpty
                      ? Center(child: Text(l10n.t('no_search_results')))
                      : RefreshIndicator(
                          onRefresh: () async =>
                              ref.invalidate(allProfilesProvider),
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                            itemCount: results.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 6),
                            itemBuilder: (ctx, i) => _MemberRow(
                              profile: results[i],
                              lineage: lineage[results[i].id],
                              l10n: l10n,
                              onTap: () => showMemberEditSheet(
                                context,
                                ref,
                                results[i],
                                lineageName: lineage[results[i].id],
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.profile,
    required this.l10n,
    required this.onTap,
    this.lineage,
  });

  final Profile profile;
  final String? lineage;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = profile;
    final initials = p.fullName
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0])
        .join();
    final phone = p.phoneNumber?.trim();

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  initials,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    if (lineage != null && lineage != p.fullName)
                      Text(
                        lineage!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        LifeStatusChip(status: p.lifeStatus, l10n: l10n),
                        if (p.isPayer)
                          _Tag(
                            text: '\$${p.monthlyAmount!.toStringAsFixed(0)}/${l10n.t('per_month_short')}',
                            color: const Color(0xFF8A6A00),
                          ),
                        if (p.maritalStatus == MaritalStatus.married)
                          _Tag(
                            text: l10n.t('marital_married'),
                            color: const Color(0xFF5F6B6A),
                          ),
                        if (phone != null && phone.isNotEmpty)
                          _Tag(
                            text: displayPhone(phone),
                            color: const Color(0xFF1F6F6B),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.edit_outlined),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      );
}
