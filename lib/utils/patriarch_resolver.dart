import '../models/lineage_tree.dart';
import '../models/models.dart';

bool isPatriarchName(String fullName) =>
    fullName.toUpperCase().contains('SHEEKH YONIS');

/// Direct daughters of Sheekh Yonis (named e.g. KHADRA SHEEKH).
bool isPatriarchDaughter(Profile profile, String patriarchId) {
  if (profile.fatherId != patriarchId) return false;
  final upper = profile.fullName.toUpperCase().trim();
  if (isPatriarchName(upper)) return false;
  return upper.endsWith(' SHEEKH') || upper.endsWith(' SHEEK');
}

({List<TreeNode> sons, List<TreeNode> daughters}) splitPatriarchChildren(
  TreeNode patriarchNode,
) {
  final sons = <TreeNode>[];
  final daughters = <TreeNode>[];
  for (final child in patriarchNode.children) {
    if (isPatriarchDaughter(child.profile, patriarchNode.profile.id)) {
      daughters.add(child);
    } else {
      sons.add(child);
    }
  }
  return (sons: sons, daughters: daughters);
}

/// Same rule as [reer_sh_yoonis.patriarch_profile_id] in migration 021.
Profile? findPatriarchProfile(Iterable<Profile> profiles) {
  final namedRoots = profiles
      .where((p) => p.fatherId == null && isPatriarchName(p.fullName))
      .toList();
  if (namedRoots.isNotEmpty) return namedRoots.first;

  final roots = profiles.where((p) => p.fatherId == null).toList();
  if (roots.length == 1) return roots.first;
  return roots.cast<Profile?>().firstOrNull;
}
