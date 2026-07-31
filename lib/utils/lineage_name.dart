import '../models/models.dart';
import 'patriarch_resolver.dart';

enum LineageSubtitleKind { sonOf, bornToMother }

class LineageDisplayInfo {
  const LineageDisplayInfo({
    required this.displayName,
    this.subtitleKind,
    this.subtitleText,
  });

  final String displayName;
  final LineageSubtitleKind? subtitleKind;
  final String? subtitleText;
}

/// When a Sheekh Yonis daughter's child is linked via [father_id] for the tree.
Profile? treeMotherLink(Profile profile, Map<String, Profile> byId) {
  final parentId = profile.fatherId;
  if (parentId == null) return null;
  final parent = byId[parentId];
  if (parent == null) return null;
  final sheekh = findSheekhYonisProfile(byId.values);
  if (sheekh == null) return null;
  if (!isPatriarchDaughter(parent, sheekh.id)) return null;
  return parent;
}

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

/// Full chain for lists/reports (e.g. "FADXIYA CABDIQADIR SHEEKH YONIS").
/// Daughter-branch children keep [Profile.fullName] (external father already in it).
String buildFullMemberName(Profile profile, Map<String, Profile> byId) {
  if (treeMotherLink(profile, byId) != null) return profile.fullName;
  return buildPatrilinealDisplayName(profile, byId);
}

LineageDisplayInfo buildLineageDisplayInfo(
  Profile profile,
  Map<String, Profile> byId,
) {
  final mother = treeMotherLink(profile, byId);
  if (mother != null) {
    return LineageDisplayInfo(
      displayName: profile.fullName,
      subtitleKind: LineageSubtitleKind.bornToMother,
      subtitleText: mother.fullName,
    );
  }

  final names = collectPatrilinealNames(profile, byId);
  if (names.length <= 1) {
    return LineageDisplayInfo(displayName: profile.fullName);
  }

  return LineageDisplayInfo(
    displayName: profile.fullName,
    subtitleKind: LineageSubtitleKind.sonOf,
    subtitleText: formatPatrilinealName(names.sublist(1)),
  );
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
/// Allows through Sheekh Yonis great-grandsons (relative depth < sheekhDepth + 4).
bool canSelectAsFatherForNewMember(
  Profile profile,
  Map<String, Profile> byId,
  String? patriarchId,
) {
  if (patriarchId == null) return false;
  final depth = generationsBelowPatriarch(profile, byId, patriarchId);
  if (depth == null) return false;
  final sheekh = findSheekhYonisProfile(byId.values);
  final sheekhDepth = sheekh == null
      ? 0
      : generationsBelowPatriarch(sheekh, byId, patriarchId) ?? 0;
  return depth < sheekhDepth + 4;
}
