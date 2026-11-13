import 'package:flutter/material.dart';

import '../models/models.dart';
import 'app_theme.dart';

/// Member life/family status colours for display.
///
/// Palette aligned with [lifeStatusColor] in `member_status_fields.dart`
/// (tealMid, plum, olive, slate, blue) — no Material pink / old blue.
class MemberStatusTheme {
  static const single = Color(0xFF2F6FB0); // blue
  static const married = BrandColors.tealMid; // #1F6F6B
  static const deceased = Color(0xFF5F6B6A); // slate
  static const child = Color(0xFF9A4B6E); // plum

  /// Child demographic wins; otherwise marital status.
  static Color? colorFor({
    required Demographic demographic,
    MaritalStatus? maritalStatus,
  }) {
    if (demographic == Demographic.child) return child;
    return switch (maritalStatus) {
      MaritalStatus.single => single,
      MaritalStatus.married => married,
      MaritalStatus.deceased => deceased,
      null => null,
    };
  }

  static String? labelKey({
    required Demographic demographic,
    MaritalStatus? maritalStatus,
  }) {
    if (demographic == Demographic.child) return 'demographic_child';
    return maritalStatus?.labelKey();
  }
}
