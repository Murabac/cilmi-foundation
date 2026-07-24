import 'dart:convert';

import 'package:flutter/services.dart';

/// Supabase credentials — compile-time via `--dart-define-from-file=env.json`,
/// or fallback from bundled `env.json` asset when defines are missing.
class SupabaseConfig {
  static const _compileUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'YOUR_SUPABASE_URL',
  );

  static const _compileAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY',
  );

  static const _compileSchema = String.fromEnvironment(
    'SUPABASE_SCHEMA',
    defaultValue: 'reer_sh_yoonis',
  );

  static String? _loadedUrl;
  static String? _loadedAnonKey;
  static String? _loadedSchema;
  static bool _loadAttempted = false;

  static String get url => _effective(_loadedUrl, _compileUrl);

  static String get anonKey => _effective(_loadedAnonKey, _compileAnonKey);

  static String get schema => _effective(_loadedSchema, _compileSchema);

  static const storageBucket = 'reer-sh-yoonis-receipts';
  static const avatarBucket = 'reer-sh-yoonis-avatars';

  static bool get isConfigured =>
      !url.contains('YOUR_SUPABASE') && !anonKey.contains('YOUR_SUPABASE');

  static String _effective(String? loaded, String compiled) {
    if (loaded != null && loaded.isNotEmpty && !loaded.contains('YOUR_SUPABASE')) {
      return loaded;
    }
    return compiled;
  }

  /// Loads project [env.json] bundled as a Flutter asset (see pubspec.yaml).
  static Future<void> loadFromAssetsIfNeeded() async {
    if (_loadAttempted || isConfigured) return;
    _loadAttempted = true;

    try {
      final raw = await rootBundle.loadString('env.json');
      final json = jsonDecode(raw) as Map<String, dynamic>;
      _loadedUrl = json['SUPABASE_URL'] as String?;
      _loadedAnonKey = json['SUPABASE_ANON_KEY'] as String?;
      _loadedSchema = json['SUPABASE_SCHEMA'] as String?;
    } catch (_) {
      // env.json not bundled or invalid — setup screen will explain.
    }
  }
}
