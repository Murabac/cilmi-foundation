import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'config/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Somali month names for Bixi / reports (DateFormat with locale 'so').
  await initializeDateFormatting('so');
  await initializeDateFormatting('en');

  await SupabaseConfig.loadFromAssetsIfNeeded();

  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey, // ignore: deprecated_member_use
    );
  }

  runApp(
    const ProviderScope(
      child: ReerShYoonisApp(),
    ),
  );
}
