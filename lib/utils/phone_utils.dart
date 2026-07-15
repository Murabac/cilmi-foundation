/// Domain used internally so users sign in with phone while Supabase uses email auth.
/// Must be a domain Supabase Auth accepts (DNS/MX validation). No real mail is sent —
/// disable email confirmation in Supabase Auth settings.
const authEmailDomain = 'hotmail.com';

/// Local-part prefix before normalized digits (avoids collisions on shared domains).
const authEmailLocalPrefix = 'rsy.';

/// Legacy domain from earlier builds (rejected by Supabase DNS validation).
const legacyAuthEmailDomain = 'phone.reershyoonis.app';

/// Digits-only Somalia phone id: 252 + 9-digit national number (12 digits total).
String normalizePhoneDigits(String input) {
  var digits = input.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return digits;

  while (digits.startsWith('252252')) {
    digits = digits.substring(3);
  }

  if (digits.startsWith('252')) return digits;
  if (digits.startsWith('0')) return '252${digits.substring(1)}';
  return '252$digits';
}

/// Normalizes a phone number for storage and auth (E.164-style).
String normalizePhone(String input) {
  final digits = normalizePhoneDigits(input);
  if (digits.isEmpty) return '';
  return '+$digits';
}

/// True when input looks like a Somalia mobile (252 + 9 digits).
bool isValidSomaliaMobile(String input) {
  final digits = normalizePhoneDigits(input);
  return digits.length == 12 && digits.startsWith('252');
}

/// Auth email used for new signups.
String phoneToAuthEmail(String normalizedPhone) {
  final digits = normalizePhoneDigits(normalizedPhone);
  return '$authEmailLocalPrefix$digits@$authEmailDomain';
}

/// Sign-in attempts: current format first, then older app builds.
List<String> authEmailsForPhone(String normalizedPhone) {
  final digits = normalizePhoneDigits(normalizedPhone);
  return [
    '$authEmailLocalPrefix$digits@$authEmailDomain',
    'p$digits@$legacyAuthEmailDomain',
    '$digits@$legacyAuthEmailDomain',
  ];
}

/// Display-friendly phone label.
String displayPhone(String? phone) {
  if (phone == null || phone.isEmpty) return '';
  return phone;
}

/// User-facing auth error text.
String authErrorMessage(Object error) {
  final text = error.toString();
  if (text.contains('Invalid login credentials') ||
      text.contains('invalid_credentials')) {
    return 'Wrong phone number or password.';
  }
  if (text.contains('User already registered') ||
      text.contains('user_already_exists') ||
      text.contains('already been registered')) {
    return 'This phone number is already registered. Sign in instead.';
  }
  if (text.contains('Email not confirmed') ||
      text.contains('email_not_confirmed')) {
    return 'Account not active yet. In Supabase go to Authentication → Providers → Email and turn off "Confirm email", then try again.';
  }
  if (text.contains('phone_provider_disabled') ||
      text.contains('Phone provider')) {
    return 'Phone sign-in is not enabled on the server.';
  }
  if (text.contains('phone_not_confirmed')) {
    return 'Please confirm your phone number first.';
  }
  if (text.contains('weak_password')) {
    return 'Password is too weak. Use at least 6 characters.';
  }
  if (text.contains('SocketException') ||
      text.contains('Failed host lookup') ||
      text.contains('No address associated with hostname') ||
      text.contains('Network is unreachable')) {
    return 'No internet connection. Check mobile data or Wi‑Fi and try again.';
  }
  if (text.contains('invalid_email') || text.contains('is invalid')) {
    return 'Could not create account. Please try again or contact support.';
  }
  if (text.contains('insufficient_pool_balance')) {
    return 'insufficient_pool_balance';
  }
  return text;
}

/// User-facing profile claim error text.
String claimErrorMessage(Object error, dynamic l10n) {
  final text = error.toString();
  if (text.contains('pending_request_exists')) {
    return l10n.t('claim_pending_exists');
  }
  if (text.contains('profile_not_available')) {
    return l10n.t('claim_profile_unavailable');
  }
  if (text.contains('profile_pending_claim')) {
    return l10n.t('claim_profile_taken');
  }
  if (text.contains('already_linked')) {
    return l10n.t('claim_already_linked');
  }
  if (text.contains('unauthorized')) {
    return l10n.t('claim_super_admin_only');
  }
  if (text.contains('name_required')) {
    return l10n.t('add_member_name_required');
  }
  return authErrorMessage(error);
}

String? validatePhoneForSignup(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return 'Enter your mobile number.';
  if (!isValidSomaliaMobile(trimmed)) {
    return 'Use a Somalia mobile number (e.g. 0634448591 or 252634448591).';
  }
  return null;
}
