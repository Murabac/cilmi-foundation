import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';
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
          SnackBar(content: Text(l10n.t('confirm_phone_then_login'))),
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
      loading: () => const Scaffold(body: LoadingView()),
      error: (_, __) => const Scaffold(body: ErrorView(message: 'Error')),
      data: (l10n) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.t('signup')),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const AppLogo(height: 100),
              const SizedBox(height: 8),
              Text(
                l10n.t('register_subtitle_claim'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(labelText: l10n.t('full_name')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: l10n.t('mobile'),
                  hintText: l10n.t('phone_hint'),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: InputDecoration(labelText: l10n.t('password')),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: TextStyle(color: Colors.red.shade700)),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _loading || !_canRegister ? null : () => _submit(l10n),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.t('signup')),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.t('already_have_account')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
