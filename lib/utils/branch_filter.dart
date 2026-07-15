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

    final branchList = patriarch == null
        ? <Profile>[]
        : profiles.where((p) => p.fatherId == patriarch.id).toList();
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

  /// Profiles in [branchId] who have at least one child in the tree.
  List<Profile> fathersWithChildren({String? branchId}) {
    final childCounts = <String, int>{};
    for (final p in byId.values) {
      final fatherId = p.fatherId;
      if (fatherId != null) {
        childCounts[fatherId] = (childCounts[fatherId] ?? 0) + 1;
      }
    }

    final fathers = byId.values.where((p) {
      if ((childCounts[p.id] ?? 0) == 0) return false;
      if (branchId == null) return true;
      if (p.id == branchId) return false;
      return isInBranch(p.id, branchId);
    }).toList();
    sortProfilesByAge(fathers);
    return fathers;
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
