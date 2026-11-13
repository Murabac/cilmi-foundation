/// Somali-aware name search and short display names.
///
/// Spelling varies a lot ("C/qaadir", "Cabdiqadir", "Abdiqadir"; "Cismaan",
/// "Cisman"; "Maxamed", "Mohamed"), so both the query and the names are
/// normalised the same way before comparing. Mirrors
/// reer_sh_yoonis.norm_somali_name in the database.
library;

final _cSlash = RegExp(r'c\s*/\s*');
final _nonLetters = RegExp(r'[^a-z]');
final _repeats = RegExp(r'(.)\1+');
final _mohamed = RegExp(r'^(maxamed|muhamed|mohamad|maxamad|mohamud)$');

/// Normalises one word (or a whole name with spaces removed).
String normSomaliWord(String input) {
  var s = input.toLowerCase().replaceAll(_cSlash, 'cabdi');
  s = s.replaceAll(_nonLetters, '');
  s = s.replaceAllMapped(_repeats, (m) => m.group(1)!);
  if (s.startsWith('abd')) s = 'c$s';
  if (_mohamed.hasMatch(s)) s = 'mohamed';
  if (s == 'axmed') s = 'ahmed';
  return s;
}

/// Normalises a full name word by word, joined by single spaces.
String normSomaliName(String input) => input
    .replaceAll(_cSlash, ' cabdi')
    .split(RegExp(r'\s+'))
    .map(normSomaliWord)
    .where((w) => w.isNotEmpty)
    .join(' ')
    .replaceAll('cabdi ', 'cabdi');

String _digits(String s) => s.replaceAll(RegExp(r'\D'), '');

/// True when every word of [query] appears in [name] (spelling-tolerant), or
/// when [query] is mostly digits and matches the [phone] number.
bool somaliSearchMatches(String query, String name, {String? phone}) {
  final q = query.trim();
  if (q.isEmpty) return true;

  final qDigits = _digits(q);
  if (qDigits.length >= 3 && qDigits.length >= q.replaceAll(' ', '').length - 1) {
    final p = _digits(phone ?? '');
    return p.contains(qDigits) ||
        (qDigits.startsWith('0') && p.contains(qDigits.substring(1)));
  }

  final hay = normSomaliName(name);
  final hayJoined = hay.replaceAll(' ', '');
  for (final word in q.split(RegExp(r'\s+'))) {
    final w = normSomaliWord(word);
    if (w.isEmpty) continue;
    if (!hay.contains(w) && !hayJoined.contains(w)) return false;
  }
  return true;
}

/// "CABDIRAHMAN" -> "C/rahman", "CISMAAN" -> "Cismaan", "c/qaadir" -> "C/qaadir".
String somaliTitleWord(String word) {
  final w = word.trim();
  if (w.isEmpty) return w;
  final lower = w.toLowerCase();
  if (lower.contains('/')) {
    final parts = lower.split('/');
    final head = parts.first.isEmpty
        ? ''
        : parts.first[0].toUpperCase() + parts.first.substring(1);
    return '$head/${parts.sublist(1).join('/')}';
  }
  if (lower.startsWith('cabdi') && lower.length > 6) {
    return 'C/${lower.substring(5)}';
  }
  return lower[0].toUpperCase() + lower.substring(1);
}

/// First name + father's first name, e.g. "Cismaan C/qaadir".
String shortSomaliName(String fullName, {String? fatherFullName}) {
  final first = fullName.trim().split(RegExp(r'\s+')).first;
  final own = somaliTitleWord(first);
  final rest = fullName.trim().split(RegExp(r'\s+')).skip(1).toList();
  if (fatherFullName != null && fatherFullName.trim().isNotEmpty) {
    final father = fatherFullName.trim().split(RegExp(r'\s+')).first;
    return '$own ${somaliTitleWord(father)}';
  }
  if (rest.isNotEmpty) return '$own ${somaliTitleWord(rest.first)}';
  return own;
}
