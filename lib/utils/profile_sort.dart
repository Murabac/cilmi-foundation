import '../models/lineage_tree.dart';
import '../models/models.dart';

/// CSV sibling order: lower [Profile.birthOrder] = older (listed first in CSV).
int compareProfilesByAge(Profile a, Profile b) {
  final order = a.birthOrder.compareTo(b.birthOrder);
  if (order != 0) return order;
  return a.fullName.compareTo(b.fullName);
}

void sortProfilesByAge(List<Profile> profiles) {
  profiles.sort(compareProfilesByAge);
}

/// Depth-first tree walk: patriarch branch order, then oldest→youngest siblings.
List<Profile> sortProfilesInTreeAgeOrder(List<Profile> profiles) {
  if (profiles.length <= 1) return profiles;

  final root = buildLineageTree(profiles);
  if (root == null) {
    final copy = profiles.toList();
    sortProfilesByAge(copy);
    return copy;
  }

  final ordered = <Profile>[root.profile];
  void walk(TreeNode node) {
    for (final child in node.children) {
      ordered.add(child.profile);
      walk(child);
    }
  }
  walk(root);

  final seen = ordered.map((p) => p.id).toSet();
  for (final p in profiles) {
    if (!seen.contains(p.id)) ordered.add(p);
  }
  return ordered;
}
