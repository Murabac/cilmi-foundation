import '../models/models.dart';

bool isPatriarchName(String fullName) =>
    fullName.toUpperCase().contains('SHEEKH YONIS');

/// Same rule as [reer_sh_yoonis.patriarch_profile_id] in migration 021.
Profile? findPatriarchProfile(Iterable<Profile> profiles) {
  final namedRoots = profiles
      .where((p) => p.fatherId == null && isPatriarchName(p.fullName))
      .toList();
  if (namedRoots.isNotEmpty) return namedRoots.first;

  final roots = profiles.where((p) => p.fatherId == null).toList();
  if (roots.length == 1) return roots.first;
  return roots.cast<Profile?>().firstOrNull;
}
