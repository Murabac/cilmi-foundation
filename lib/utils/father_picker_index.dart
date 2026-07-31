import '../models/models.dart';
import 'branch_filter.dart';
import 'lineage_name.dart';
import 'profile_sort.dart';

/// Branch/father-filtered father candidates for add-member and edit-lineage flows.
class FatherPickerIndex {
  FatherPickerIndex({
    required this.branchIndex,
    required this.lineageById,
  });

  final BranchFilterIndex branchIndex;
  final Map<String, String> lineageById;

  static FatherPickerIndex fromProfiles(List<Profile> profiles) {
    final branchIndex = BranchFilterIndex.fromProfiles(profiles);
    final lineageById = {
      for (final p in profiles)
        p.id: buildLineageDisplayInfo(p, branchIndex.byId).displayName,
    };

    return FatherPickerIndex(
      branchIndex: branchIndex,
      lineageById: lineageById,
    );
  }

  /// [editingProfileId] excludes self and descendants to prevent tree cycles.
  List<Profile> candidates({
    String? branchId,
    String? subBranchId,
    String? fatherFilterId,
    String? editingProfileId,
  }) {
    final sorted = branchIndex.byId.values.toList();
    sortProfilesByAge(sorted);
    final scopeId = subBranchId ?? branchId;
    var results = sorted.where((p) {
      if (editingProfileId != null) {
        if (p.id == editingProfileId) return false;
        if (branchIndex.wouldCreateFatherCycle(editingProfileId, p.id)) {
          return false;
        }
      }
      if (!canSelectAsFatherForNewMember(
        p,
        branchIndex.byId,
        branchIndex.patriarchId,
      )) {
        return false;
      }
      if (scopeId != null && !branchIndex.isInBranch(p.id, scopeId)) {
        return false;
      }
      return true;
    });
    results = branchIndex.filterByAncestor(
      results,
      fatherFilterId,
      profileId: (p) => p.id,
    );
    final list = results.toList();
    final genScope = fatherFilterId ?? scopeId;
    branchIndex.sortByGeneration(list, genScope);
    return list;
  }

  void applyInitialBranchForFather(
    Profile father,
    void Function(String? branchId) setBranchId, {
    void Function(String? subBranchId)? setSubBranchId,
  }) {
    for (final branch in branchIndex.branches) {
      if (!branchIndex.isInBranch(father.id, branch.id)) continue;
      setBranchId(branch.id);
      if (setSubBranchId != null) {
        for (final sub in branchIndex.subBranchesOf(branch.id)) {
          if (father.id == sub.id ||
              branchIndex.isInBranch(father.id, sub.id)) {
            setSubBranchId(sub.id);
            break;
          }
        }
      }
      return;
    }
  }
}
