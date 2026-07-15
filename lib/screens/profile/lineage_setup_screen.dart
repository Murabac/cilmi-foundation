import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../models/lineage_registration.dart';
import '../../providers/providers.dart';
import '../../utils/phone_utils.dart';
import '../../widgets/lineage_selection_form.dart';
import '../../widgets/widgets.dart';

class LineageSetupScreen extends ConsumerStatefulWidget {
  const LineageSetupScreen({super.key});

  @override
  ConsumerState<LineageSetupScreen> createState() => _LineageSetupScreenState();
}

class _LineageSetupScreenState extends ConsumerState<LineageSetupScreen> {
  final _lineage = LineageSelection();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = ref.read(authServiceProvider).currentUser;
      final meta = user?.userMetadata;
      final name = meta?['full_name'] as String?;
      final phone = meta?['phone'] as String?;
      if (name != null && _nameCtrl.text.isEmpty) {
        _nameCtrl.text = name;
      }
      if (phone != null && _phoneCtrl.text.isEmpty) {
        _phoneCtrl.text = displayPhone(phone).replaceFirst('+', '');
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(AppLocalizations l10n) async {
    final name = _nameCtrl.text.trim();
    if (!_lineage.isComplete(fullName: name)) {
      setState(() => _error = l10n.t('lineage_required'));
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ref.read(profileServiceProvider).completeLineageSetup(
            selection: _lineage,
            fullName: name,
            phoneNumber:
                _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
            l10n: l10n,
          );

      ref.invalidate(currentProfileProvider);
      ref.invalidate(myPendingClaimProvider);
      ref.invalidate(allProfilesProvider);
      ref.invalidate(fullLineageTreeProvider);
      ref.invalidate(memberCountProvider);
      ref.invalidate(unclaimedProfilesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.t('claim_submitted'))),
        );
      }
    } catch (e) {
      setState(() => _error = claimErrorMessage(e, l10n));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10nAsync = ref.watch(localizationsProvider);

    return l10nAsync.when(
      loading: () => const Scaffold(body: LoadingView()),
      error: (_, __) => const Scaffold(body: ErrorView(message: 'Error')),
      data: (l10n) {
        final canSave =
            _lineage.isComplete(fullName: _nameCtrl.text.trim()) && !_loading;

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.t('link_lineage')),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => ref.read(authServiceProvider).signOut(),
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Icon(Icons.account_tree,
                    size: 48, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 12),
                Text(
                  l10n.t('link_lineage_subtitle'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.t('claim_admin_approval_hint'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.orange.shade800,
                      ),
                ),
                const SizedBox(height: 24),
                LineageSelectionForm(
                  selection: _lineage,
                  l10n: l10n,
                  nameController: _nameCtrl,
                  phoneController: _phoneCtrl,
                  onChanged: () => setState(() {}),
                ),
                if (_lineage.claimProfile == null) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.t('select_your_profile'),
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: 13,
                    ),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(_error!, style: TextStyle(color: Colors.red.shade700)),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: canSave ? () => _submit(l10n) : null,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.t('submit_for_approval')),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
