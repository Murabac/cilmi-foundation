import '../models/models.dart';
import 'lineage_name.dart';
import 'patriarch_resolver.dart';
import 'profile_sort.dart';

/// Patriarch sons (branches) and helpers to filter profiles by branch.
class BranchFilterIndex {
  BranchFilterIndex({
    required this.byId,
    required this.branches,
    required this.patriarchId,
  });

  final Map<String, Profile> byId;
  final List<Profile> branches;
  final String? patriarchId;

  static BranchFilterIndex fromProfiles(List<Profile> profiles) {
    final byId = {for (final p in profiles) p.id: p};
    final patriarch = findPatriarchProfile(profiles);
    final branchParent = findBranchParentProfile(profiles, patriarch);
    final sheekh = findSheekhYonisProfile(profiles);

    final branchList = branchParent == null
        ? <Profile>[]
        : profiles
            .where((p) {
              if (p.fatherId != branchParent.id) return false;
              // Keep Sheekh Yonis daughters out of the top-level branch list.
              if (sheekh != null && isPatriarchDaughter(p, sheekh.id)) {
                return false;
              }
              return true;
            })
            .toList();
    sortProfilesByAge(branchList);

    return BranchFilterIndex(
      byId: byId,
      branches: branchList,
      patriarchId: patriarch?.id,
    );
  }

  bool isInBranch(String profileId, String branchId) {
    if (profileId == branchId) return true;
    var current = byId[profileId];
    final visited = <String>{};
    while (current != null) {
      if (current.id == branchId) return true;
      if (current.fatherId == null) return false;
      if (!visited.add(current.fatherId!)) return false;
      current = byId[current.fatherId!];
    }
    return false;
  }

  List<T> filterByBranch<T>(
    Iterable<T> items,
    String? branchId, {
    required String Function(T item) profileId,
  }) {
    if (branchId == null) return items.toList();
    return items.where((item) => isInBranch(profileId(item), branchId)).toList();
  }

  bool isDescendantOf(String profileId, String ancestorId) {
    if (profileId == ancestorId) return true;
    var current = byId[profileId];
    final visited = <String>{};
    while (current != null) {
      if (current.id == ancestorId) return true;
      if (current.fatherId == null) return false;
      if (!visited.add(current.fatherId!)) return false;
      current = byId[current.fatherId!];
    }
    return false;
  }

  /// Direct children of a top-level branch (e.g. sons of Sheekh Yonis).
  List<Profile> subBranchesOf(String branchId) {
    final sheekh = findSheekhYonisProfile(byId.values);
    final kids = byId.values.where((p) {
      if (p.fatherId != branchId) return false;
      // Keep Sheekh daughters out of the sub-branch list (own section).
      if (sheekh != null &&
          branchId == sheekh.id &&
          isPatriarchDaughter(p, sheekh.id)) {
        return false;
      }
      return true;
    }).toList();
    sortProfilesByAge(kids);
    return kids;
  }

  /// Generations below [ancestorId] (0 = self, 1 = child, 2 = grandchild).
  int? depthBelow(String profileId, String ancestorId) {
    if (profileId == ancestorId) return 0;
    var depth = 0;
    var current = byId[profileId];
    final visited = <String>{};
    while (current != null) {
      depth++;
      final fatherId = current.fatherId;
      if (fatherId == null) return null;
      if (fatherId == ancestorId) return depth;
      if (!visited.add(fatherId)) return null;
      current = byId[fatherId];
    }
    return null;
  }

  /// Closest generation to [scopeId] first, then birth order within a generation.
  void sortByGeneration(List<Profile> profiles, String? scopeId) {
    if (scopeId == null) {
      sortProfilesByAge(profiles);
      return;
    }
    profiles.sort((a, b) {
      final da = depthBelow(a.id, scopeId) ?? 999;
      final db = depthBelow(b.id, scopeId) ?? 999;
      if (da != db) return da.compareTo(db);
      return compareProfilesByAge(a, b);
    });
  }

  void sortItemsByGeneration<T>(
    List<T> items,
    String? scopeId, {
    required String Function(T item) profileId,
  }) {
    if (scopeId == null) return;
    items.sort((a, b) {
      final da = depthBelow(profileId(a), scopeId) ?? 999;
      final db = depthBelow(profileId(b), scopeId) ?? 999;
      if (da != db) return da.compareTo(db);
      final pa = byId[profileId(a)];
      final pb = byId[profileId(b)];
      if (pa != null && pb != null) return compareProfilesByAge(pa, pb);
      return 0;
    });
  }

  /// People to offer in the parent/line filter under [branchId].
  ///
  /// Direct children of the scope are listed first (including unmarried /
  /// childless ones), then deeper descendants who themselves have children.
  List<Profile> fathersWithChildren({String? branchId}) {
    final counts = childCounts();

    if (branchId == null) {
      final fathers = byId.values
          .where((p) => (counts[p.id] ?? 0) > 0)
          .toList();
      sortProfilesByAge(fathers);
      return fathers;
    }

    if (!byId.containsKey(branchId)) return const [];

    final seen = <String>{};
    final result = <Profile>[];

    // 1) Mire's own kids first — easy to find even if unmarried / no kids yet.
    final directKids =
        byId.values.where((p) => p.fatherId == branchId).toList();
    sortProfilesByAge(directKids);
    for (final p in directKids) {
      if (seen.add(p.id)) result.add(p);
    }

    // 2) Deeper parents after that (grandkids who have their own kids, etc.).
    final deeperParents = byId.values.where((p) {
      if (p.id == branchId) return false;
      if (p.fatherId == branchId) return false;
      if ((counts[p.id] ?? 0) == 0) return false;
      return isInBranch(p.id, branchId);
    }).toList();
    sortByGeneration(deeperParents, branchId);
    for (final p in deeperParents) {
      if (seen.add(p.id)) result.add(p);
    }

    return result;
  }

  List<T> filterByAncestor<T>(
    Iterable<T> items,
    String? ancestorId, {
    required String Function(T item) profileId,
    bool includeAncestor = true,
  }) {
    if (ancestorId == null) return items.toList();
    return items.where((item) {
      final id = profileId(item);
      if (includeAncestor && id == ancestorId) return true;
      return isDescendantOf(id, ancestorId);
    }).toList();
  }

  /// Number of direct children per profile id.
  Map<String, int> childCounts() {
    final counts = <String, int>{};
    for (final p in byId.values) {
      final fatherId = p.fatherId;
      if (fatherId != null) {
        counts[fatherId] = (counts[fatherId] ?? 0) + 1;
      }
    }
    return counts;
  }

  bool wouldCreateFatherCycle(String profileId, String newFatherId) {
    if (profileId == newFatherId) return true;
    return isDescendantOf(newFatherId, profileId);
  }

  List<Profile> fatherCandidatesFor(String profileId) {
    final counts = childCounts();
    final candidates = byId.values.where((p) {
      if (p.id == profileId) return false;
      if (wouldCreateFatherCycle(profileId, p.id)) return false;
      if (patriarchId != null && p.id == patriarchId) return true;
      if ((counts[p.id] ?? 0) > 0) return true;
      if (branches.any((b) => b.id == p.id)) return true;
      return canSelectAsFatherForNewMember(p, byId, patriarchId);
    }).toList();
    sortProfilesByAge(candidates);
    return candidates;
  }

  /// Depth-first tree order for auditing a branch or subtree.
  List<Profile> orderedMembers({String? branchId, String? ancestorId}) {
    final rootId = ancestorId ?? branchId ?? patriarchId;
    if (rootId == null) return [];

    final result = <Profile>[];
    final visited = <String>{};

    void walk(String id) {
      if (!visited.add(id)) return;
      final profile = byId[id];
      if (profile == null) return;
      result.add(profile);
      final children = byId.values.where((p) => p.fatherId == id).toList();
      sortProfilesByAge(children);
      for (final child in children) {
        walk(child.id);
      }
    }

    walk(rootId);
    return result;
  }
}
