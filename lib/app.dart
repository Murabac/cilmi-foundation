import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        title: 'CILMI FOUNDATION',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
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
                'Add env.json with your Supabase URL and anon key, then run:',
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
                  'flutter run --dart-define-from-file=env.json\n'
                  '# or: .\\scripts\\run.ps1',
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

  void _setLocale(String code) {
    ref.read(localeProvider.notifier).state = code;
  }

  @override
  Widget build(BuildContext context) {
    final l10nAsync = ref.watch(localizationsProvider);
    final locale = ref.watch(localeProvider);

    return l10nAsync.when(
      loading: () => const Scaffold(
        backgroundColor: BrandColors.teal,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
      error: (_, _) => const Scaffold(
        backgroundColor: BrandColors.teal,
        body: Center(child: Text('Failed to load translations')),
      ),
      data: (l10n) => Scaffold(
        backgroundColor: BrandColors.teal,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 48, 28, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 24),
                  child: Column(
                    children: [
                      const AppLogo(
                        height: 120,
                        variant: AppLogoVariant.stackedReversed,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: 32,
                        height: 2,
                        color: BrandColors.gold,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.t('login_tagline'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: BrandColors.onTealMuted,
                        ),
                      ),
                      SizedBox(height: constraints.maxHeight > 700 ? 48 : 28),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: BrandColors.linen,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              l10n.t('welcome'),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: BrandColors.teal,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              l10n.t('login_subtitle'),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: BrandColors.muted,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _phoneCtrl,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: BrandColors.ink,
                              ),
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
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) {
                                if (!_loading) _submit(l10n);
                              },
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: BrandColors.ink,
                              ),
                              decoration: InputDecoration(
                                labelText: l10n.t('password'),
                              ),
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                _error!,
                                style: const TextStyle(
                                  color: BrandColors.urgent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                            FilledButton(
                              onPressed: _loading ? null : () => _submit(l10n),
                              child: _loading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(l10n.t('login')),
                            ),
                            const SizedBox(height: 14),
                            Text.rich(
                              TextSpan(
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: BrandColors.muted,
                                  fontWeight: FontWeight.w500,
                                ),
                                children: [
                                  TextSpan(text: '${l10n.t('dont_have_account')} '),
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.baseline,
                                    baseline: TextBaseline.alphabetic,
                                    child: GestureDetector(
                                      onTap: _openRegister,
                                      child: Text(
                                        l10n.t('signup'),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: BrandColors.tealMid,
                                          decoration: TextDecoration.underline,
                                          decorationColor: BrandColors.tealMid,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _LanguageSwitch(
                        locale: locale,
                        l10n: l10n,
                        onSelect: _setLocale,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LanguageSwitch extends StatelessWidget {
  const _LanguageSwitch({
    required this.locale,
    required this.l10n,
    required this.onSelect,
  });

  final String locale;
  final AppLocalizations l10n;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final isSo = locale == 'so';
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => onSelect('en'),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Text(
              l10n.t('english'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSo ? FontWeight.w500 : FontWeight.w700,
                color: isSo ? BrandColors.onTealMuted : BrandColors.linen,
              ),
            ),
          ),
        ),
        Text(
          '·',
          style: TextStyle(
            fontSize: 13,
            color: BrandColors.onTealMuted.withValues(alpha: 0.8),
          ),
        ),
        GestureDetector(
          onTap: () => onSelect('so'),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Text(
              l10n.t('somali'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSo ? FontWeight.w700 : FontWeight.w500,
                color: isSo ? BrandColors.linen : BrandColors.onTealMuted,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
