/// Supabase credentials — replace with your project values.
/// Pass via `--dart-define` at build time.
class SupabaseConfig {
  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'YOUR_SUPABASE_URL',
  );

  static const anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY',
  );

  /// Postgres schema for this app (multi-app Supabase project).
  static const schema = String.fromEnvironment(
    'SUPABASE_SCHEMA',
    defaultValue: 'reer_sh_yoonis',
  );

  static const storageBucket = 'reer-sh-yoonis-receipts';
  static const avatarBucket = 'reer-sh-yoonis-avatars';

  static bool get isConfigured =>
      !url.contains('YOUR_SUPABASE') && !anonKey.contains('YOUR_SUPABASE');
}
