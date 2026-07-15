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
        p.id: buildPatrilinealDisplayName(p, branchIndex.byId),
    };

    return FatherPickerIndex(
      branchIndex: branchIndex,
      lineageById: lineageById,
    );
  }

  /// [editingProfileId] excludes self and descendants to prevent tree cycles.
  List<Profile> candidates({
    String? branchId,
    String? fatherFilterId,
    String? editingProfileId,
  }) {
    final sorted = branchIndex.byId.values.toList();
    sortProfilesByAge(sorted);
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
      if (branchId != null && !branchIndex.isInBranch(p.id, branchId)) {
        return false;
      }
      return true;
    });
    results = branchIndex.filterByAncestor(
      results,
      fatherFilterId,
      profileId: (p) => p.id,
    );
    return results.toList();
  }

  void applyInitialBranchForFather(
    Profile father,
    void Function(String? branchId) setBranchId,
  ) {
    for (final branch in branchIndex.branches) {
      if (branchIndex.isInBranch(father.id, branch.id)) {
        setBranchId(branch.id);
        return;
      }
    }
  }
}
