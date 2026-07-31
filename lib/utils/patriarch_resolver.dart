import '../models/lineage_tree.dart';
import '../models/models.dart';

/// Foundation root (Cilmi).
bool isPatriarchName(String fullName) {
  final upper = fullName.toUpperCase().trim();
  return upper == 'CILMI' || upper.startsWith('CILMI ');
}

bool isSheekhYonisName(String fullName) =>
    fullName.toUpperCase().contains('SHEEKH YONIS');

/// Daughters of a given father named e.g. KHADRA SHEEKH (Sheekh Yonis line).
bool isPatriarchDaughter(Profile profile, String fatherId) {
  if (profile.fatherId != fatherId) return false;
  final upper = profile.fullName.toUpperCase().trim();
  if (isSheekhYonisName(upper)) return false;
  return upper.endsWith(' SHEEKH') || upper.endsWith(' SHEEK');
}

Profile? findSheekhYonisProfile(Iterable<Profile> profiles) {
  final matches =
      profiles.where((p) => isSheekhYonisName(p.fullName)).toList();
  if (matches.isEmpty) return null;
  if (matches.length == 1) return matches.first;

  final childCount = <String, int>{};
  for (final p in profiles) {
    final fatherId = p.fatherId;
    if (fatherId != null) {
      childCount[fatherId] = (childCount[fatherId] ?? 0) + 1;
    }
  }

  matches.sort((a, b) {
    final byKids =
        (childCount[b.id] ?? 0).compareTo(childCount[a.id] ?? 0);
    if (byKids != 0) return byKids;
    final byFather = (b.fatherId != null ? 1 : 0)
        .compareTo(a.fatherId != null ? 1 : 0);
    if (byFather != 0) return byFather;
    return a.id.compareTo(b.id);
  });
  return matches.first;
}

/// Same rule as [reer_sh_yoonis.patriarch_profile_id] (CILMI root).
Profile? findPatriarchProfile(Iterable<Profile> profiles) {
  final namedRoots = profiles
      .where((p) => p.fatherId == null && isPatriarchName(p.fullName))
      .toList();
  if (namedRoots.isNotEmpty) return namedRoots.first;

  // Legacy trees before Cilmi ancestry was added.
  final sheekhRoots = profiles
      .where((p) => p.fatherId == null && isSheekhYonisName(p.fullName))
      .toList();
  if (sheekhRoots.isNotEmpty) return sheekhRoots.first;

  final roots = profiles.where((p) => p.fatherId == null).toList();
  if (roots.length == 1) return roots.first;
  return roots.cast<Profile?>().firstOrNull;
}

/// When patriarch has a single child who has descendants (Ahmed under Cilmi),
/// use that child as the branch parent so filters show Sheekh Yonis + Aadan.
Profile? findBranchParentProfile(
  Iterable<Profile> profiles,
  Profile? patriarch,
) {
  if (patriarch == null) return null;
  final kids =
      profiles.where((p) => p.fatherId == patriarch.id).toList();
  if (kids.length != 1) return patriarch;
  final only = kids.first;
  final hasGrandkids = profiles.any((p) => p.fatherId == only.id);
  return hasGrandkids ? only : patriarch;
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

/// Foundation view: keep Ahmed under Cilmi; hoist Sheekh Yonis daughters aside.
///
/// Returned [TreeNode]s may be display-only clones (Sheekh without daughters).
/// Use the original lineage [root] for counts and identity lookups.
({List<TreeNode> sons, List<TreeNode> daughters}) splitFoundationBranches(
  TreeNode root,
) {
  if (root.children.length == 1 && root.children.first.children.isNotEmpty) {
    final intermediate = root.children.first;
    final branchSons = <TreeNode>[];
    final daughters = <TreeNode>[];

    for (final child in intermediate.children) {
      if (isSheekhYonisName(child.profile.fullName)) {
        final split = splitPatriarchChildren(child);
        branchSons.add(
          TreeNode(profile: child.profile, children: split.sons),
        );
        daughters.addAll(split.daughters);
      } else {
        branchSons.add(child);
      }
    }

    return (
      sons: [
        TreeNode(profile: intermediate.profile, children: branchSons),
      ],
      daughters: daughters,
    );
  }

  return splitPatriarchChildren(root);
}

/// Top-level filter/list branches (Sheekh Yonis + Aadan), unwrapping Ahmed.
List<TreeNode> foundationBranchNodes(TreeNode root) {
  final split = splitFoundationBranches(root);
  if (split.sons.length == 1 &&
      split.sons.first.children.isNotEmpty &&
      !isSheekhYonisName(split.sons.first.profile.fullName)) {
    return split.sons.first.children;
  }
  return split.sons;
}
