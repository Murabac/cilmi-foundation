import '../models/models.dart';

enum LineageRegistrationType {
  claimExisting,
  sonOfSheekh,
  childOfSon,
  grandchild,
}

class LineageSelection {
  LineageRegistrationType type = LineageRegistrationType.claimExisting;
  Profile? claimProfile;
  Profile? selectedSon;
  Profile? selectedChild;

  bool isComplete({required String fullName}) {
    switch (type) {
      case LineageRegistrationType.claimExisting:
        return claimProfile != null;
      case LineageRegistrationType.sonOfSheekh:
        return fullName.trim().isNotEmpty;
      case LineageRegistrationType.childOfSon:
        return fullName.trim().isNotEmpty && selectedSon != null;
      case LineageRegistrationType.grandchild:
        return fullName.trim().isNotEmpty && selectedChild != null;
    }
  }
}
