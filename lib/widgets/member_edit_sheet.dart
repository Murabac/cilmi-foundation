import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/phone_utils.dart';
import 'member_business_card.dart';
import 'member_status_fields.dart';

/// One screen to edit the things admins change most: name, phone, city,
/// monthly contribution and this month's status.
Future<void> showMemberEditSheet(
  BuildContext context,
  WidgetRef ref,
  Profile profile, {
  String? lineageName,
}) async {
  final l10n = await ref.read(localizationsProvider.future);
  final me = await ref.read(currentProfileProvider.future);
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.94,
      maxChildSize: 0.94,
      minChildSize: 0.5,
      builder: (ctx, scroll) => _MemberEditSheet(
        profile: profile,
        l10n: l10n,
        lineageName: lineageName,
        canEditMoney: me?.role.canManagePayments ?? false,
        scrollController: scroll,
      ),
    ),
  );
}

class _MemberEditSheet extends ConsumerStatefulWidget {
  const _MemberEditSheet({
    required this.profile,
    required this.l10n,
    required this.canEditMoney,
    required this.scrollController,
    this.lineageName,
  });

  final Profile profile;
  final AppLocalizations l10n;
  final bool canEditMoney;
  final ScrollController scrollController;
  final String? lineageName;

  @override
  ConsumerState<_MemberEditSheet> createState() => _MemberEditSheetState();
}

class _MemberEditSheetState extends ConsumerState<_MemberEditSheet> {
  late final _nameCtrl = TextEditingController(text: widget.profile.fullName);
  late final _phoneCtrl =
      TextEditingController(text: widget.profile.phoneNumber ?? '');
  late final _cityCtrl = TextEditingController(text: widget.profile.city ?? '');
  late final _amountCtrl = TextEditingController(
    text: _fmt(widget.profile.monthlyAmount),
  );
  late var _pays = widget.profile.isPayer;
  late var _status = MemberStatusValue.fromProfile(widget.profile);
  var _saving = false;

  static String _fmt(double? v) {
    if (v == null || v <= 0) return '';
    return v == v.roundToDouble() ? v.toStringAsFixed(0) : '$v';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  bool get _statusChanged {
    final before = MemberStatusValue.fromProfile(widget.profile);
    return _status.lifeStatus != null &&
        (_status.lifeStatus != before.lifeStatus ||
            _status.occupation.trim() != before.occupation.trim() ||
            _status.maritalStatus != before.maritalStatus);
  }

  Future<void> _save() async {
    final l10n = widget.l10n;
    final p = widget.profile;
    final amount = _pays ? double.tryParse(_amountCtrl.text.trim()) : null;
    if (_pays && (amount == null || amount <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('invalid_amount'))),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final profiles = ref.read(profileServiceProvider);
      final name = _nameCtrl.text.trim();
      final phone = _phoneCtrl.text.trim();
      final city = _cityCtrl.text.trim();
      await profiles.updateMemberProfileAdmin(
        profileId: p.id,
        fullName: name.isNotEmpty && name != p.fullName ? name : null,
        phoneNumber: phone != (p.phoneNumber ?? '')
            ? (phone.isEmpty ? '' : normalizePhone(phone))
            : null,
        city: city != (p.city ?? '') ? city : null,
      );

      if (widget.canEditMoney && amount != p.monthlyAmount) {
        final now = DateTime.now();
        await ref.read(contributionServiceProvider).setMonthlyAmount(
              profileId: p.id,
              amount: amount,
              ensureBillingMonth: now.month,
              ensureBillingYear: now.year,
            );
      }

      if (_statusChanged) {
        await profiles.updateMemberStatus(
          profileId: p.id,
          lifeStatus: _status.lifeStatus!,
          occupation: _status.occupation,
          maritalStatus: _status.maritalStatus,
        );
      }

      ref.invalidate(allProfilesProvider);
      ref.invalidate(currentProfileProvider);
      ref.invalidate(monthlyPaymentReportProvider);
      ref.invalidate(statusHistoryProvider);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.t('member_saved'))),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final theme = Theme.of(context);
    final p = widget.profile;
    final initials = p.fullName
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0])
        .join();

    Widget section(String title, List<Widget> children) => Padding(
          padding: const EdgeInsets.only(top: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 10),
              ...children,
            ],
          ),
        );

    return Column(
      children: [
        Expanded(
          child: ListView(
            controller: widget.scrollController,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.fullName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (widget.lineageName != null)
                          Text(
                            widget.lineageName!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              section(l10n.t('member_basic_info'), [
                TextField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: l10n.t('full_name'),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: l10n.t('mobile'),
                    hintText: l10n.t('phone_hint'),
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _cityCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: l10n.t('city'),
                    prefixIcon: const Icon(Icons.location_on_outlined),
                  ),
                ),
              ]),
              if (widget.canEditMoney)
                section(l10n.t('monthly_contribution'), [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _pays,
                    onChanged: (v) => setState(() => _pays = v),
                    title: Text(
                      l10n.t('on_payers_list'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      _pays
                          ? l10n.t('on_payers_list_hint')
                          : l10n.t('billing_status_exempt'),
                    ),
                  ),
                  if (_pays) ...[
                    Wrap(
                      spacing: 8,
                      children: [5, 10, 20, 50].map((v) {
                        return ChoiceChip(
                          label: Text('\$$v'),
                          selected: _amountCtrl.text.trim() == '$v',
                          onSelected: (_) =>
                              setState(() => _amountCtrl.text = '$v'),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _amountCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: l10n.t('monthly_amount_usd'),
                        prefixText: '\$ ',
                      ),
                    ),
                  ],
                ]),
              section(l10n.t('status_this_month'), [
                MemberStatusFields(
                  l10n: l10n,
                  value: _status,
                  onChanged: (v) => setState(() => _status = v),
                ),
              ]),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () => showMemberBusinessCard(context, ref, p),
                icon: const Icon(Icons.account_tree_outlined),
                label: Text(l10n.t('edit_lineage_more')),
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              12 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : Text(l10n.t('save')),
            ),
          ),
        ),
      ],
    );
  }
}
