import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/add_family_member_dialog.dart';
import '../../widgets/member_business_card.dart';
import '../../widgets/widgets.dart';

class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  final _rateCtrl = TextEditingController();
  final _merchantCtrl = TextEditingController();
  final _ussdCtrl = TextEditingController();
  String _language = 'en';
  bool _saving = false;
  bool _resetting = false;
  bool _releasingClaims = false;
  bool _initialized = false;

  @override
  void dispose() {
    _rateCtrl.dispose();
    _merchantCtrl.dispose();
    _ussdCtrl.dispose();
    super.dispose();
  }

  void _initFromSettings(GlobalSettings settings) {
    if (_initialized) return;
    _rateCtrl.text = settings.currentAdultRate.toStringAsFixed(2);
    _merchantCtrl.text = settings.paymentMerchantId;
    _ussdCtrl.text = settings.ussdServiceCode;
    _language = settings.appLanguage;
    _initialized = true;
  }

  String? _paymentValidationError(AppLocalizations l10n) {
    final merchant = _merchantCtrl.text.trim();
    final ussd = _ussdCtrl.text.trim();
    if (merchant.isEmpty || !RegExp(r'^\d+$').hasMatch(merchant)) {
      return l10n.t('payment_merchant_invalid');
    }
    if (ussd.isEmpty || !RegExp(r'^\d+$').hasMatch(ussd)) {
      return l10n.t('ussd_service_code_invalid');
    }
    return null;
  }

  Future<void> _save(AppLocalizations l10n) async {
    final validationError = _paymentValidationError(l10n);
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final rate = double.tryParse(_rateCtrl.text.trim());
      await ref.read(settingsServiceProvider).updateSettings(
            adultRate: rate,
            language: _language,
            paymentMerchantId: _merchantCtrl.text.trim(),
            ussdServiceCode: _ussdCtrl.text.trim(),
          );
      ref.read(localeProvider.notifier).state = _language;
      ref.invalidate(globalSettingsProvider);
      ref.invalidate(localizationsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.t('save'))),
        );
      }
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

  Future<void> _resetOperationalData(AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.t('reset_operational_data')),
        content: Text(l10n.t('reset_operational_data_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.t('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade700,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.t('reset_operational_data')),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _resetting = true);
    try {
      await ref.read(adminServiceProvider).resetOperationalData();
      ref.invalidate(allProfilesProvider);
      ref.invalidate(carePriorityProvider);
      ref.invalidate(fullLineageTreeProvider);
      ref.invalidate(poolBalanceProvider);
      ref.invalidate(auditLedgerProvider);
      ref.invalidate(monthlyPaymentReportProvider);
      ref.invalidate(pendingContributionsProvider);
      ref.invalidate(myContributionsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.t('reset_operational_data_done'))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _resetting = false);
    }
  }

  Future<void> _releaseStaleProfileClaims(AppLocalizations l10n) async {
    setState(() => _releasingClaims = true);
    try {
      final count =
          await ref.read(adminServiceProvider).releaseStaleProfileClaims();
      ref.invalidate(allProfilesProvider);
      ref.invalidate(unclaimedProfilesProvider);
      ref.invalidate(fullLineageTreeProvider);
      ref.invalidate(memberCountProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n
                  .t('release_stale_claims_done')
                  .replaceAll('{count}', '$count'),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _releasingClaims = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10nAsync = ref.watch(localizationsProvider);
    final settingsAsync = ref.watch(globalSettingsProvider);
    final profilesAsync = ref.watch(allProfilesProvider);

    return l10nAsync.when(
      loading: () => const LoadingView(),
      error: (_, __) => const ErrorView(message: 'Error'),
      data: (l10n) {
        settingsAsync.whenData(_initFromSettings);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l10n.t('settings'), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.t('adult_rate'), style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _rateCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(prefixText: '\$ '),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.t('payment_settings'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.t('payment_merchant_hint'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _merchantCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.t('payment_merchant_id'),
                        hintText: '123456',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _ussdCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.t('ussd_service_code'),
                        hintText: '883',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.t('app_language'), style: Theme.of(context).textTheme.titleMedium),
                    RadioListTile<String>(
                      title: Text(l10n.t('english')),
                      value: 'en',
                      groupValue: _language,
                      onChanged: (v) => setState(() => _language = v!),
                    ),
                    RadioListTile<String>(
                      title: Text(l10n.t('somali')),
                      value: 'so',
                      groupValue: _language,
                      onChanged: (v) => setState(() => _language = v!),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: _saving ? null : () => _save(l10n),
                      child: _saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.t('save')),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: () async {
                try {
                  final count =
                      await ref.read(contributionServiceProvider).generateMonthlyBilling();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Generated $count billing entries')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                }
              },
              icon: const Icon(Icons.calendar_month),
              label: Text(l10n.t('generate_billing')),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.t('release_stale_claims'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.t('release_stale_claims_hint'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade800,
                          ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _releasingClaims
                          ? null
                          : () => _releaseStaleProfileClaims(l10n),
                      icon: _releasingClaims
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.link_off),
                      label: Text(l10n.t('release_stale_claims')),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.t('reset_operational_data'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.t('reset_operational_data_hint'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade800,
                          ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade800,
                        side: BorderSide(color: Colors.red.shade300),
                      ),
                      onPressed: _resetting ? null : () => _resetOperationalData(l10n),
                      icon: _resetting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.restart_alt),
                      label: Text(l10n.t('reset_operational_data')),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.t('manage_members'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: () async {
                    final added = await showAddFamilyMemberDialog(context, ref);
                    if (added && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.t('add_member_success'))),
                      );
                    }
                  },
                  icon: const Icon(Icons.person_add_outlined, size: 18),
                  label: Text(l10n.t('add_family_member')),
                ),
              ],
            ),
            const SizedBox(height: 8),
            profilesAsync.when(
              loading: () => LoadingView(message: l10n.t('loading')),
              error: (_, __) => ErrorView(message: l10n.t('error_generic')),
              data: (profiles) => Column(
                children: profiles.map((p) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(p.fullName),
                      subtitle: Row(
                        children: [
                          RoleBadge(role: p.role, l10n: l10n),
                          const SizedBox(width: 8),
                          DemographicBadge(demographic: p.demographic, l10n: l10n),
                        ],
                      ),
                      onTap: () => showMemberBusinessCard(context, ref, p),
                      trailing: PopupMenuButton<String>(
                        onSelected: (action) => _handleMemberAction(action, p, l10n),
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'edit_card',
                            child: Text(l10n.t('edit_member')),
                          ),
                          if (p.authUserId != null)
                            PopupMenuItem(
                              value: 'release_claim',
                              child: Text(l10n.t('release_profile_claim')),
                            ),
                          if (p.role != UserRole.manager)
                            PopupMenuItem(
                              value: 'promote',
                              child: Text(l10n.t('promote_manager')),
                            ),
                          if (p.role == UserRole.manager)
                            PopupMenuItem(
                              value: 'demote',
                              child: Text(l10n.t('demote_member')),
                            ),
                          PopupMenuItem(
                            value: 'adult',
                            child: Text(l10n.t('demographic_adult')),
                          ),
                          PopupMenuItem(
                            value: 'student',
                            child: Text(l10n.t('demographic_student')),
                          ),
                          PopupMenuItem(
                            value: 'child',
                            child: Text(l10n.t('demographic_child')),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleMemberAction(
    String action,
    Profile profile,
    AppLocalizations l10n,
  ) async {
    if (action == 'edit_card') {
      if (mounted) showMemberBusinessCard(context, ref, profile);
      return;
    }

    if (action == 'release_claim') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.t('release_profile_claim')),
          content: Text(
            l10n
                .t('release_profile_claim_confirm')
                .replaceAll('{name}', profile.fullName),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.t('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.t('release_profile_claim')),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;

      try {
        await ref.read(adminServiceProvider).releaseProfileClaim(profile.id);
        ref.invalidate(allProfilesProvider);
        ref.invalidate(unclaimedProfilesProvider);
        ref.invalidate(fullLineageTreeProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.t('release_profile_claim_done'))),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
      return;
    }

    final service = ref.read(profileServiceProvider);
    switch (action) {
      case 'promote':
        await service.updateRole(profile.id, UserRole.manager);
      case 'demote':
        await service.updateRole(profile.id, UserRole.familyMember);
      case 'adult':
        await service.updateDemographic(profile.id, Demographic.adult);
      case 'student':
        await service.updateDemographic(profile.id, Demographic.student);
      case 'child':
        await service.updateDemographic(profile.id, Demographic.child);
    }
    ref.invalidate(allProfilesProvider);
  }
}
