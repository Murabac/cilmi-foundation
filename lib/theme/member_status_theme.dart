import 'package:flutter/material.dart';

import '../models/models.dart';

/// Member life/family status colors for display.
class MemberStatusTheme {
  static const single = Color(0xFF2563EB); // blue
  static const married = Color(0xFF16A34A); // green
  static const deceased = Color(0xFFDC2626); // red
  static const child = Color(0xFFDB2777); // pink

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
