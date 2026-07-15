import '../models/models.dart';

/// Walks [father_id] from [profile] upward and returns names oldest-last.
List<String> collectPatrilinealNames(
  Profile profile,
  Map<String, Profile> byId,
) {
  final names = <String>[profile.fullName];
  final visited = <String>{profile.id};
  var current = profile;

  while (current.fatherId != null && !visited.contains(current.fatherId)) {
    visited.add(current.fatherId!);
    final father = byId[current.fatherId!];
    if (father == null) break;
    names.add(father.fullName);
    current = father;
  }

  return names;
}

/// e.g. "AHMED MOHAMED YOONIS SHEEKH YONIS"
String formatPatrilinealName(List<String> names) {
  if (names.isEmpty) return '';
  return names.join(' ');
}

String buildPatrilinealDisplayName(
  Profile profile,
  Map<String, Profile> byId,
) {
  return formatPatrilinealName(collectPatrilinealNames(profile, byId));
}

/// Generations below the patriarch along the father chain.
/// Patriarch = 0, sons = 1, their children = 2, grandchildren = 3.
int? generationsBelowPatriarch(
  Profile profile,
  Map<String, Profile> byId,
  String patriarchId,
) {
  if (profile.id == patriarchId) return 0;

  var depth = 0;
  var current = profile;
  final visited = <String>{profile.id};

  while (current.fatherId != null) {
    depth++;
    if (current.fatherId == patriarchId) return depth;
    if (!visited.add(current.fatherId!)) return null;
    final father = byId[current.fatherId!];
    if (father == null) return null;
    current = father;
  }
  return null;
}

/// Fathers when adding a member: exclude the youngest generation (no families yet).
/// Allows patriarch's sons through great-grandsons (depth 1–3).
bool canSelectAsFatherForNewMember(
  Profile profile,
  Map<String, Profile> byId,
  String? patriarchId,
) {
  if (patriarchId == null) return false;
  final depth = generationsBelowPatriarch(profile, byId, patriarchId);
  if (depth == null) return false;
  return depth < 4;
}
