import '../models/lineage_tree.dart';
import '../models/models.dart';
import 'patriarch_resolver.dart';

/// Whether a leaf member should render as a compact chip in the list tree.
///
/// Chips are for little kids — not unmarried adults who simply have no children:
/// - demographic child/student
/// - kids of Sheekh Yonis daughters (mother named … SHEEKH)
/// - generation under grandchildren (depth >= 2, e.g. kids of Hodan)
bool showsAsLeafChip(
  TreeNode node,
  int depth, {
  Profile? parent,
}) {
  if (node.children.isNotEmpty) return false;

  final demo = node.profile.demographic;
  if (demo == Demographic.child || demo == Demographic.student) return true;

  if (parent != null) {
    final upper = parent.fullName.toUpperCase().trim();
    if ((upper.endsWith(' SHEEKH') || upper.endsWith(' SHEEK')) &&
        !isSheekhYonisName(upper)) {
      return true;
    }
  }

  return depth >= 2;
}
