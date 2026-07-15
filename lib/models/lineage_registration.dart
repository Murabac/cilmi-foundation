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
    return type == LineageRegistrationType.claimExisting &&
        claimProfile != null;
  }
}
