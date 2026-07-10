import 'models.dart';
import '../utils/profile_sort.dart';

class TreeNode {
  const TreeNode({required this.profile, required this.children});

  final Profile profile;
  final List<TreeNode> children;

  int get descendantCount {
    var count = children.length;
    for (final child in children) {
      count += child.descendantCount;
    }
    return count;
  }
}

TreeNode? buildLineageTree(List<Profile> profiles) {
  if (profiles.isEmpty) return null;

  final childrenByFather = <String, List<Profile>>{};
  for (final profile in profiles) {
    final fatherId = profile.fatherId;
    if (fatherId != null) {
      childrenByFather.putIfAbsent(fatherId, () => []).add(profile);
    }
  }

  for (final entry in childrenByFather.entries) {
    sortProfilesByAge(entry.value);
  }

  Profile? root;
  for (final profile in profiles) {
    if (profile.fullName.toUpperCase().contains('SHEEKH YONIS')) {
      root = profile;
      break;
    }
  }

  root ??= profiles.where((p) => p.fatherId == null).firstOrNull;
  if (root == null) return null;

  TreeNode buildNode(Profile profile) {
    final children = childrenByFather[profile.id] ?? const [];
    return TreeNode(
      profile: profile,
      children: children.map(buildNode).toList(),
    );
  }

  return buildNode(root);
}

int countTreeMembers(TreeNode? root) {
  if (root == null) return 0;
  return 1 + root.descendantCount;
}

bool treeNodeMatchesSearch(TreeNode node, String query) {
  if (query.trim().isEmpty) return true;
  final q = query.trim().toLowerCase();
  if (node.profile.fullName.toLowerCase().contains(q)) return true;
  return node.children.any((child) => treeNodeMatchesSearch(child, q));
}

List<TreeNode> filterSonBranches(List<TreeNode> sons, String query) {
  if (query.trim().isEmpty) return sons;
  return sons.where((son) => treeNodeMatchesSearch(son, query)).toList();
}

bool profileNameMatchesSearch(Profile profile, String query) {
  if (query.trim().isEmpty) return true;
  return profile.fullName.toLowerCase().contains(query.trim().toLowerCase());
}
