import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/lineage_registration.dart';
import '../providers/providers.dart';
import '../utils/phone_utils.dart';
import 'claim_profile_picker.dart';
import 'widgets.dart';

class LineageSelectionForm extends ConsumerStatefulWidget {
  const LineageSelectionForm({
    super.key,
    required this.selection,
    required this.l10n,
    required this.onChanged,
    this.nameController,
    this.phoneController,
    this.showNameAndPhone = true,
  });

  final LineageSelection selection;
  final AppLocalizations l10n;
  final VoidCallback onChanged;
  final TextEditingController? nameController;
  final TextEditingController? phoneController;
  final bool showNameAndPhone;

  @override
  ConsumerState<LineageSelectionForm> createState() =>
      _LineageSelectionFormState();
}

class _LineageSelectionFormState extends ConsumerState<LineageSelectionForm> {
  @override
  void initState() {
    super.initState();
    widget.selection.type = LineageRegistrationType.claimExisting;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClaimProfilePicker(
          selection: widget.selection,
          l10n: l10n,
          onChanged: () {
            setState(() {});
            widget.onChanged();
          },
        ),
        if (widget.showNameAndPhone) ...[
          const SizedBox(height: 20),
          Text(
            l10n.t('confirm_your_details'),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: widget.nameController,
            onChanged: (_) => widget.onChanged(),
            decoration: InputDecoration(labelText: l10n.t('full_name')),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: widget.phoneController,
            onChanged: (_) => widget.onChanged(),
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: l10n.t('mobile'),
              hintText: l10n.t('phone_hint'),
            ),
          ),
        ],
      ],
    );
  }
}
