import '../models/models.dart';
import 'patriarch_resolver.dart';

/// How many father-links from [profile] up to the patriarch (0 = patriarch).
int? generationsFromPatriarch(Profile profile, List<Profile> allProfiles) {
  final patriarch = findPatriarchProfile(allProfiles);
  if (patriarch == null) return null;
  if (profile.id == patriarch.id) return 0;

  final byId = {for (final p in allProfiles) p.id: p};
  var depth = 0;
  String? currentFatherId = profile.fatherId;
  final visited = <String>{profile.id};

  while (currentFatherId != null && !visited.contains(currentFatherId)) {
    visited.add(currentFatherId);
    depth++;
    if (currentFatherId == patriarch.id) return depth;
    final parent = byId[currentFatherId];
    if (parent == null) return null;
    currentFatherId = parent.fatherId;
  }
  return null;
}

bool _isChildOfSheekhYonisDaughter(Profile profile, List<Profile> allProfiles) {
  final fatherId = profile.fatherId;
  if (fatherId == null) return false;
  final byId = {for (final p in allProfiles) p.id: p};
  final parent = byId[fatherId];
  if (parent == null) return false;
  final sheekh = findSheekhYonisProfile(allProfiles);
  if (sheekh == null) return false;
  return isPatriarchDaughter(parent, sheekh.id);
}

/// Depth of Sheekh Yonis from the foundation root (0 when he is root).
int _sheekhDepthFromPatriarch(List<Profile> allProfiles) {
  final sheekh = findSheekhYonisProfile(allProfiles);
  if (sheekh == null) return 0;
  return generationsFromPatriarch(sheekh, allProfiles) ?? 0;
}

/// Automatic exemption (ignores [Profile.billingOverride]).
bool isAutomaticallyPaymentExempt(
  Profile profile, {
  required List<Profile> allProfiles,
}) {
  if (profile.demographic.isPaymentExempt) return true;
  if (profile.maritalStatus == MaritalStatus.deceased) return true;

  final generations = generationsFromPatriarch(profile, allProfiles);
  final sheekhDepth = _sheekhDepthFromPatriarch(allProfiles);
  // Cilmi/Ahmed/Sheekh|Aadan + their sons (uncles); or legacy Sheekh + sons.
  if (generations != null && generations <= sheekhDepth + 1) return true;
  if (_isChildOfSheekhYonisDaughter(profile, allProfiles)) return true;
  // Below Sheekh-grandchild generation.
  if (generations != null && generations >= sheekhDepth + 3) return true;

  return false;
}

/// Patriarch, uncles/aunties, daughter-branch kids, students/children, and anyone
/// below the grandchild generation are exempt — unless admin override says otherwise.
bool isProfilePaymentExempt(Profile profile, {required List<Profile> allProfiles}) {
  switch (profile.billingOverride) {
    case BillingOverride.exempt:
      return true;
    case BillingOverride.billable:
      return false;
    case null:
      return isAutomaticallyPaymentExempt(profile, allProfiles: allProfiles);
  }
}
