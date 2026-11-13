import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import 'member_status_fields.dart';

/// Monthly status update for [profile] (the member themself, or an admin).
Future<bool> showStatusUpdateSheet(
  BuildContext context,
  WidgetRef ref,
  Profile profile,
) async {
  final l10n = await ref.read(localizationsProvider.future);
  if (!context.mounted) return false;
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _StatusUpdateSheet(profile: profile, l10n: l10n),
  );
  return saved ?? false;
}

class _StatusUpdateSheet extends ConsumerStatefulWidget {
  const _StatusUpdateSheet({required this.profile, required this.l10n});

  final Profile profile;
  final AppLocalizations l10n;

  @override
  ConsumerState<_StatusUpdateSheet> createState() => _StatusUpdateSheetState();
}

class _StatusUpdateSheetState extends ConsumerState<_StatusUpdateSheet> {
  late var _value = MemberStatusValue.fromProfile(widget.profile);
  var _saving = false;

  Future<void> _save() async {
    final status = _value.lifeStatus;
    if (status == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.l10n.t('status_pick_one'))),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(profileServiceProvider).updateMemberStatus(
            profileId: widget.profile.id,
            lifeStatus: status,
            occupation: _value.occupation,
            maritalStatus: _value.maritalStatus,
          );
      ref.invalidate(currentProfileProvider);
      ref.invalidate(allProfilesProvider);
      ref.invalidate(statusHistoryProvider);
      if (mounted) Navigator.pop(context, true);
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
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.t('status_update_title'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.profile.fullName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
            ),
            const SizedBox(height: 18),
            MemberStatusFields(
              l10n: l10n,
              value: _value,
              onChanged: (v) => setState(() => _value = v),
            ),
            const SizedBox(height: 22),
            FilledButton(
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
          ],
        ),
      ),
    );
  }
}
