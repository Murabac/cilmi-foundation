import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../utils/branch_filter.dart';
import '../../utils/lineage_name.dart';
import '../../utils/profile_sort.dart';
import '../../utils/somali_search.dart';
import '../../widgets/member_edit_sheet.dart';
import '../../widgets/member_status_fields.dart';
import '../../widgets/widgets.dart';

/// One member's status in the selected month.
class _Row {
  const _Row(this.profile, this.status, this.occupation, this.marital);
  final Profile profile;
  final LifeStatus? status; // null = not updated that month
  final String? occupation;
  final MaritalStatus? marital;
}

/// Monthly report: how many family members are in school, at university,
/// working (and as what), unemployed, married… with filters by reer.
class StatusReportScreen extends ConsumerStatefulWidget {
  const StatusReportScreen({super.key});

  @override
  ConsumerState<StatusReportScreen> createState() => _StatusReportScreenState();
}

class _StatusReportScreenState extends ConsumerState<StatusReportScreen> {
  String? _branchId;
  LifeStatus? _statusFilter;
  var _onlyNotUpdated = false;
  var _onlyMarried = false;

  void _shiftMonth(int delta) {
    final m = ref.read(selectedStatusMonthProvider);
    final next = DateTime(m.year, m.month + delta);
    final now = DateTime.now();
    if (next.isAfter(DateTime(now.year, now.month))) return;
    ref.read(selectedStatusMonthProvider.notifier).state = next;
  }

  List<_Row> _buildRows(
    List<Profile> profiles,
    List<MemberStatusEntry> history,
    DateTime month,
  ) {
    final byProfile = {for (final h in history) h.profileId: h};
    final now = DateTime.now();
    final isCurrent = month.year == now.year && month.month == now.month;
    return profiles
        .where((p) => p.maritalStatus != MaritalStatus.deceased)
        .map((p) {
      final h = byProfile[p.id];
      if (h != null) {
        return _Row(p, h.lifeStatus, h.occupation, h.maritalStatus);
      }
      if (isCurrent && !p.statusIsStale) {
        return _Row(p, p.lifeStatus, p.occupation, p.maritalStatus);
      }
      return _Row(p, null, null, p.maritalStatus);
    }).toList();
  }

  String _shareText(
    AppLocalizations l10n,
    String monthLabel,
    List<_Row> rows,
    String scope,
  ) {
    final b = StringBuffer()
      ..writeln('*${l10n.t('status_report_title')} — $monthLabel*')
      ..writeln(scope)
      ..writeln();
    for (final s in LifeStatus.values) {
      final n = rows.where((r) => r.status == s).length;
      if (n > 0) b.writeln('${l10n.t(s.labelKey)}: $n');
    }
    final married = rows.where((r) => r.marital == MaritalStatus.married).length;
    b
      ..writeln('${l10n.t('marital_married')}: $married')
      ..writeln('${l10n.t('status_not_updated')}: ${rows.where((r) => r.status == null).length}')
      ..writeln()
      ..writeln('*${l10n.t('total_members')}: ${rows.length}*');
    return b.toString().trim();
  }

  @override
  Widget build(BuildContext context) {
    final l10nAsync = ref.watch(localizationsProvider);
    final profilesAsync = ref.watch(allProfilesProvider);
    final historyAsync = ref.watch(statusHistoryProvider);
    final month = ref.watch(selectedStatusMonthProvider);

    return l10nAsync.when(
      loading: () => const Scaffold(body: LoadingView()),
      error: (_, _) => const Scaffold(body: ErrorView(message: 'Error')),
      data: (l10n) {
        final monthLabel = DateFormat('MMMM yyyy').format(month);
        final loading = profilesAsync.isLoading || historyAsync.isLoading;
        final error = profilesAsync.error ?? historyAsync.error;

        Widget body;
        if (loading) {
          body = LoadingView(message: l10n.t('loading'));
        } else if (error != null) {
          body = ErrorView(
            message: error.toString(),
            onRetry: () {
              ref.invalidate(allProfilesProvider);
              ref.invalidate(statusHistoryProvider);
            },
          );
        } else {
          final profiles = sortProfilesInTreeAgeOrder(profilesAsync.value!);
          final byId = {for (final p in profiles) p.id: p};
          final index = BranchFilterIndex.fromProfiles(profiles);
          final allRows = _buildRows(profiles, historyAsync.value!, month);
          final scoped = _branchId == null
              ? allRows
              : allRows
                  .where((r) => index.isInBranch(r.profile.id, _branchId!))
                  .toList();
          final list = scoped.where((r) {
            if (_onlyNotUpdated) return r.status == null;
            if (_onlyMarried && r.marital != MaritalStatus.married) {
              return false;
            }
            if (_statusFilter != null && r.status != _statusFilter) {
              return false;
            }
            return true;
          }).toList();
          final branchName = _branchId == null
              ? l10n.t('all_branches')
              : 'Reer ${somaliTitleWord(byId[_branchId!]!.fullName.split(' ').first)}';

          int count(LifeStatus s) => scoped.where((r) => r.status == s).length;
          final notUpdated = scoped.where((r) => r.status == null).length;
          final married =
              scoped.where((r) => r.marital == MaritalStatus.married).length;

          Widget tile({
            required String label,
            required int n,
            required IconData icon,
            required Color color,
            required bool selected,
            required VoidCallback onTap,
          }) =>
              Material(
                color: selected ? color : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: selected ? color : const Color(0xFFE3DDD0),
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(icon,
                                size: 18,
                                color: selected ? Colors.white : color),
                            const Spacer(),
                            Text(
                              '$n',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: selected ? Colors.white : color,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: selected ? Colors.white : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );

          final tiles = [
            ...LifeStatus.values.map(
              (s) => tile(
                label: l10n.t(s.labelKey),
                n: count(s),
                icon: lifeStatusIcon(s),
                color: lifeStatusColor(s),
                selected: _statusFilter == s && !_onlyNotUpdated,
                onTap: () => setState(() {
                  _onlyNotUpdated = false;
                  _onlyMarried = false;
                  _statusFilter = _statusFilter == s ? null : s;
                }),
              ),
            ),
            tile(
              label: l10n.t('marital_married'),
              n: married,
              icon: Icons.favorite_outline,
              color: const Color(0xFF9A4B6E),
              selected: _onlyMarried,
              onTap: () => setState(() {
                _onlyNotUpdated = false;
                _statusFilter = null;
                _onlyMarried = !_onlyMarried;
              }),
            ),
            tile(
              label: l10n.t('status_not_updated'),
              n: notUpdated,
              icon: Icons.update,
              color: const Color(0xFF8A8F98),
              selected: _onlyNotUpdated,
              onTap: () => setState(() {
                _statusFilter = null;
                _onlyMarried = false;
                _onlyNotUpdated = !_onlyNotUpdated;
              }),
            ),
          ];

          body = RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(allProfilesProvider);
              ref.invalidate(statusHistoryProvider);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                Row(
                  children: [
                    IconButton.filledTonal(
                      tooltip: l10n.t('previous_month'),
                      onPressed: () => _shiftMonth(-1),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Expanded(
                      child: Text(
                        monthLabel,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    IconButton.filledTonal(
                      tooltip: l10n.t('next_month'),
                      onPressed: () => _shiftMonth(1),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
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
                            onSelected: (_) => setState(() => _branchId = b.id),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.1,
                  children: tiles,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1E7A4C),
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: () async {
                    final text =
                        _shareText(l10n, monthLabel, scoped, branchName);
                    final ok = await launchUrl(
                      Uri.parse(
                        'whatsapp://send?text=${Uri.encodeComponent(text)}',
                      ),
                      mode: LaunchMode.externalApplication,
                    );
                    if (!ok) {
                      await Clipboard.setData(ClipboardData(text: text));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.t('copied'))),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.share),
                  label: Text(l10n.t('share_report_whatsapp')),
                ),
                const SizedBox(height: 18),
                Text(
                  '${list.length} ${l10n.t('members_label')}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ...list.map(
                  (r) => Card(
                    margin: const EdgeInsets.only(bottom: 6),
                    child: ListTile(
                      onTap: () => showMemberEditSheet(
                        context,
                        ref,
                        r.profile,
                        lineageName: buildFullMemberName(r.profile, byId),
                      ),
                      title: Text(
                        r.profile.fullName,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        [
                          if ((r.occupation ?? '').trim().isNotEmpty)
                            r.occupation!.trim(),
                          if (r.marital != null) l10n.t(r.marital!.labelKey()),
                        ].join(' · '),
                      ),
                      trailing: LifeStatusChip(status: r.status, l10n: l10n),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(l10n.t('status_report_title'))),
          body: body,
        );
      },
    );
  }
}
