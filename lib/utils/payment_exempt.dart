import '../models/models.dart';
import 'patriarch_resolver.dart';

/// Patriarch and direct sons (uncles / branch heads) are exempt from monthly contributions.
bool isProfilePaymentExempt(Profile profile, {required List<Profile> allProfiles}) {
  if (profile.demographic.isPaymentExempt) return true;
  final patriarch = findPatriarchProfile(allProfiles);
  if (patriarch != null && profile.id == patriarch.id) return true;
  if (patriarch != null && profile.fatherId == patriarch.id) return true;
  return false;
}
