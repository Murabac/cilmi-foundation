import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/phone_utils.dart';
import '../../widgets/widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    for (final c in [_phoneCtrl, _passwordCtrl, _nameCtrl]) {
      c.addListener(_onFormChanged);
    }
  }

  void _onFormChanged() => setState(() {});

  @override
  void dispose() {
    for (final c in [_phoneCtrl, _passwordCtrl, _nameCtrl]) {
      c.removeListener(_onFormChanged);
      c.dispose();
    }
    super.dispose();
  }

  bool get _canRegister {
    final name = _nameCtrl.text.trim();
    return _phoneCtrl.text.trim().isNotEmpty &&
        _passwordCtrl.text.length >= 6 &&
        name.isNotEmpty;
  }

  Future<void> _submit(AppLocalizations l10n) async {
    if (!_canRegister) {
      setState(() => _error = l10n.t('signup_fields_required'));
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final auth = ref.read(authServiceProvider);
      final phoneInput = _phoneCtrl.text.trim();
      final phoneError = validatePhoneForSignup(phoneInput);
      if (phoneError != null) {
        setState(() => _error = phoneError);
        return;
      }

      final phone = normalizePhone(phoneInput);
      final password = _passwordCtrl.text;
      final name = _nameCtrl.text.trim();

      final hasSession = await auth.signUp(phone, password, name);

      if (hasSession) {
        ref.invalidate(currentProfileProvider);
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.t('confirm_phone_then_login')),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() => _error = authErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10nAsync = ref.watch(localizationsProvider);

    return l10nAsync.when(
      loading: () => const Scaffold(
        backgroundColor: BrandColors.teal,
        body: LoadingView(),
      ),
      error: (_, _) => const Scaffold(
        backgroundColor: BrandColors.teal,
        body: ErrorView(message: 'Error'),
      ),
      data: (l10n) => Scaffold(
        backgroundColor: BrandColors.teal,
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: BrandColors.linen,
                  tooltip: l10n.t('already_have_account'),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - 8,
                        ),
                        child: Column(
                          children: [
                            const AppLogo(
                              height: 96,
                              variant: AppLogoVariant.stackedReversed,
                            ),
                            const SizedBox(height: 14),
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
                            const SizedBox(height: 28),
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
                                    l10n.t('signup'),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: BrandColors.teal,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    l10n.t('register_subtitle_claim'),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: BrandColors.muted,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  TextField(
                                    controller: _nameCtrl,
                                    textInputAction: TextInputAction.next,
                                    textCapitalization: TextCapitalization.words,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: BrandColors.ink,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: l10n.t('full_name'),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
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
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _passwordCtrl,
                                    obscureText: true,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) {
                                      if (!_loading && _canRegister) {
                                        _submit(l10n);
                                      }
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
                                    const SizedBox(height: 16),
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
                                    onPressed: _loading || !_canRegister
                                        ? null
                                        : () => _submit(l10n),
                                    child: _loading
                                        ? const SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(l10n.t('signup')),
                                  ),
                                  const SizedBox(height: 12),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text(l10n.t('already_have_account')),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
