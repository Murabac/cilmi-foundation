import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppLocalizations {
  AppLocalizations(this._strings);

  final Map<String, String> _strings;

  String t(String key) => _strings[key] ?? key;

  static Future<AppLocalizations> load(String locale) async {
    final code = locale == 'so' ? 'so' : 'en';
    final json = await rootBundle.loadString('assets/l10n/$code.json');
    final map = Map<String, String>.from(jsonDecode(json) as Map);
    return AppLocalizations(map);
  }
}

final localeProvider = StateProvider<String>((ref) => 'en');

final localizationsProvider = FutureProvider<AppLocalizations>((ref) async {
  final locale = ref.watch(localeProvider);
  return AppLocalizations.load(locale);
});

extension L10nContext on String {
  String l10n(AppLocalizations l) => l.t(this);
}
