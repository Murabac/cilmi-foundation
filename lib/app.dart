import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'config/supabase_config.dart';
import 'l10n/app_localizations.dart';
import 'providers/providers.dart';
import 'screens/admin/payment_report_screen.dart';
import 'screens/admin/treasury_screen.dart';
import 'screens/admin/verification_queue_screen.dart';
import 'screens/home_shell.dart';
import 'screens/auth/register_screen.dart';
import 'utils/phone_utils.dart';
import 'screens/profile/claim_pending_screen.dart';
import 'screens/profile/lineage_setup_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/app_logo.dart';

class ReerShYoonisApp extends ConsumerWidget {
  const ReerShYoonisApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10nAsync = ref.watch(localizationsProvider);
    final locale = ref.watch(localeProvider);

    return l10nAsync.when(
      data: (_) => MaterialApp(
        title: 'Reer Sh Yoonis',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light().copyWith(
          textTheme: GoogleFonts.interTextTheme(AppTheme.light().textTheme),
        ),
        locale: Locale(locale),
        routes: {
          '/verification': (_) => const VerificationQueueScreen(),
          '/payments-report': (_) => const PaymentReportScreen(),
          '/treasury': (_) => const TreasuryScreen(),
          '/profile': (_) => const ProfileScreen(),
        },
        home: const AuthGate(),
      ),
      loading: () => MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (_, __) => MaterialApp(home: const AuthGate()),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!SupabaseConfig.isConfigured) {
      return const SetupRequiredScreen();
    }

    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (state) {
        if (state.session != null) {
          return const ProfileSetupGate();
        }
        return const LoginScreen();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const LoginScreen(),
    );
  }
}

class ProfileSetupGate extends ConsumerWidget {
  const ProfileSetupGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    final pendingAsync = ref.watch(myPendingClaimProvider);

    return profileAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      data: (profile) {
        return pendingAsync.when(
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
          data: (pending) {
            if (pending != null) {
              return const ClaimPendingScreen();
            }
            if (ref.read(profileServiceProvider).needsLineageSetup(profile)) {
              return const LineageSetupScreen();
            }
            return const HomeShell();
          },
        );
      },
    );
  }
}

class SetupRequiredScreen extends StatelessWidget {
  const SetupRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              const AppLogo(height: 80),
              const SizedBox(height: 16),
              const Text(
                'Copy env.json.example to env.json, fill in your Supabase values, then run:',
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const SelectableText(
                  'cp env.json.example env.json\n'
                  'flutter run --dart-define-from-file=env.json',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Then run supabase/migrations/001_initial_schema.sql in your Supabase SQL editor.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(AppLocalizations l10n) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ref.read(authServiceProvider).signIn(
            _phoneCtrl.text.trim(),
            _passwordCtrl.text,
          );
    } catch (e) {
      setState(() => _error = authErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10nAsync = ref.watch(localizationsProvider);

    return l10nAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => const Scaffold(body: Center(child: Text('Failed to load translations'))),
      data: (l10n) => Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              const SizedBox(height: 48),
              const AppLogo(height: 140),
              const SizedBox(height: 16),
              Text(
                l10n.t('login_subtitle'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: l10n.t('mobile'),
                    hintText: l10n.t('phone_hint'),
                    helperText: l10n.t('login_phone_hint'),
                    helperMaxLines: 2,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  decoration: InputDecoration(labelText: l10n.t('password')),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: TextStyle(color: Colors.red.shade700)),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _loading ? null : () => _submit(l10n),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.t('login')),
                ),
                TextButton(
                  onPressed: _openRegister,
                  child: Text(l10n.t('dont_have_account')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
