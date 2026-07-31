import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/app_localizations.dart';
import '../models/lineage_tree.dart';
import '../models/models.dart';
import '../utils/payment_exempt.dart';
import '../models/payment_report.dart';
import '../services/services.dart';
import '../utils/lineage_name.dart';

final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

final authServiceProvider = Provider(
  (ref) => AuthService(ref.watch(supabaseClientProvider)),
);

final profileServiceProvider = Provider(
  (ref) => ProfileService(ref.watch(supabaseClientProvider)),
);

final settingsServiceProvider = Provider(
  (ref) => SettingsService(ref.watch(supabaseClientProvider)),
);

final contributionServiceProvider = Provider(
  (ref) => ContributionService(ref.watch(supabaseClientProvider)),
);

final treasuryServiceProvider = Provider(
  (ref) => TreasuryService(ref.watch(supabaseClientProvider)),
);

final adminServiceProvider = Provider(
  (ref) => AdminService(ref.watch(supabaseClientProvider)),
);

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentProfileProvider = FutureProvider<Profile?>((ref) async {
  ref.watch(authStateProvider);
  return ref.watch(profileServiceProvider).getCurrentProfile();
});

final unclaimedProfilesProvider = FutureProvider<List<Profile>>((ref) async {
  ref.watch(authStateProvider);
  return ref.watch(profileServiceProvider).getUnclaimedProfiles();
});

final sonsOfPatriarchProvider = FutureProvider<List<Profile>>((ref) async {
  ref.watch(authStateProvider);
  return ref.watch(profileServiceProvider).getSonsOfPatriarch();
});

final profileChildrenProvider =
    FutureProvider.family<List<Profile>, String>((ref, parentId) async {
  return ref.watch(profileServiceProvider).getChildren(parentId);
});

final profileLineageNameProvider =
    FutureProvider.family<String, String>((ref, profileId) async {
  ref.watch(authStateProvider);
  return ref.watch(profileServiceProvider).buildFullLineageName(profileId);
});

final profileLineageDisplayProvider =
    FutureProvider.family<LineageDisplayInfo, String>((ref, profileId) async {
  ref.watch(authStateProvider);
  return ref.watch(profileServiceProvider).getLineageDisplayInfo(profileId);
});

final currentUserFatherProvider = FutureProvider<Profile?>((ref) async {
  final profile = await ref.watch(currentProfileProvider.future);
  if (profile?.fatherId == null) return null;
  return ref.watch(profileServiceProvider).getProfileById(profile!.fatherId!);
});

final globalSettingsProvider = FutureProvider<GlobalSettings>((ref) async {
  final settings = await ref.watch(settingsServiceProvider).getSettings();
  ref.read(localeProvider.notifier).state = settings.appLanguage;
  return settings;
});

final allProfilesProvider = FutureProvider<List<Profile>>((ref) async {
  ref.watch(authStateProvider);
  return ref.watch(profileServiceProvider).getAllProfilesSortedByCare();
});

final memberCountProvider = FutureProvider<int>((ref) async {
  ref.watch(authStateProvider);
  return ref.watch(profileServiceProvider).getMemberCount();
});

final carePriorityProvider = FutureProvider<List<Profile>>((ref) async {
  ref.watch(authStateProvider);
  return ref.watch(profileServiceProvider).getCarePriorityProfiles();
});

final poolBalanceProvider = FutureProvider<double>((ref) async {
  final profile = await ref.watch(currentProfileProvider.future);
  if (profile == null) return 0;
  return ref.watch(treasuryServiceProvider).getPoolBalance();
});

final urgentCountProvider = FutureProvider<int>((ref) async {
  final profile = await ref.watch(currentProfileProvider.future);
  if (profile == null || !profile.role.canManageCare) return 0;
  return ref.watch(profileServiceProvider).countUrgentProfiles();
});

final pendingContributionsProvider =
    FutureProvider<List<Contribution>>((ref) async {
  final profile = await ref.watch(currentProfileProvider.future);
  if (profile == null || !profile.role.canManagePayments) return [];
  return ref.watch(contributionServiceProvider).getPendingContributions();
});

class BillingPeriod {
  const BillingPeriod({required this.month, required this.year});
  final int month;
  final int year;
}

final selectedBillingPeriodProvider = StateProvider<BillingPeriod>((ref) {
  final now = DateTime.now();
  return BillingPeriod(month: now.month, year: now.year);
});

/// Status chip on the payment report (All / Paid / Unpaid / …).
final selectedPaymentReportFilterProvider =
    StateProvider<PaymentReportFilter>((ref) => PaymentReportFilter.all);

final monthlyPaymentReportProvider =
    FutureProvider<MonthlyPaymentReport>((ref) async {
  final profile = await ref.watch(currentProfileProvider.future);
  if (profile == null || !profile.role.canManagePayments) {
    throw Exception('Unauthorized');
  }
  final period = ref.watch(selectedBillingPeriodProvider);
  return ref.read(contributionServiceProvider).getMonthlyPaymentReport(
        month: period.month,
        year: period.year,
      );
});

final myContributionsProvider = FutureProvider<List<Contribution>>((ref) async {
  final profile = await ref.watch(currentProfileProvider.future);
  if (profile == null) return [];
  final allProfiles = await ref.watch(allProfilesProvider.future);
  if (isProfilePaymentExempt(profile, allProfiles: allProfiles)) return [];
  return ref
      .watch(contributionServiceProvider)
      .getMyContributions(profile.id);
});

final auditLedgerProvider = FutureProvider<List<LedgerEntry>>((ref) async {
  final profile = await ref.watch(currentProfileProvider.future);
  if (profile == null || !profile.role.canManageTreasury) return [];
  return ref.watch(treasuryServiceProvider).getAuditLedger();
});

final myPendingClaimProvider = FutureProvider<ProfileClaimRequest?>((ref) async {
  ref.watch(authStateProvider);
  return ref.watch(profileServiceProvider).getMyPendingClaimRequest();
});

final pendingClaimRequestsProvider =
    FutureProvider<List<ProfileClaimRequest>>((ref) async {
  final profile = await ref.watch(currentProfileProvider.future);
  if (profile == null || profile.role != UserRole.superAdmin) return [];
  return ref.watch(profileServiceProvider).getPendingClaimRequests();
});

final focusedProfileIdProvider = StateProvider<String?>((ref) => null);

final focusedProfileProvider = FutureProvider<Profile?>((ref) async {
  final id = ref.watch(focusedProfileIdProvider);
  final service = ref.watch(profileServiceProvider);

  if (id != null) {
    return service.getProfileById(id);
  }

  final current = await ref.watch(currentProfileProvider.future);
  if (current != null) return current;

  // Default to patriarch so the tree works even before auth profile is linked.
  return service.getRootProfile();
});

final fullLineageTreeProvider = FutureProvider<TreeNode?>((ref) async {
  ref.watch(authStateProvider);
  final profiles = await ref.watch(profileServiceProvider).getAllProfiles();
  return buildLineageTree(profiles);
});

final familyTreeContextProvider =
    FutureProvider<FamilyTreeContext?>((ref) async {
  final focused = await ref.watch(focusedProfileProvider.future);
  if (focused == null) return null;

  final service = ref.watch(profileServiceProvider);
  final father =
      focused.fatherId != null ? await service.getProfileById(focused.fatherId!) : null;
  final mother =
      focused.motherId != null ? await service.getProfileById(focused.motherId!) : null;
  final spouse = focused.spouseId != null
      ? await service.getProfileById(focused.spouseId!)
      : null;
  final siblings = await service.getSiblings(focused);
  final children = await service.getChildren(focused.id);

  return FamilyTreeContext(
    focused: focused,
    father: father,
    mother: mother,
    spouse: spouse,
    siblings: siblings,
    children: children,
  );
});

class FamilyTreeContext {
  const FamilyTreeContext({
    required this.focused,
    this.father,
    this.mother,
    this.spouse,
    required this.siblings,
    required this.children,
  });

  final Profile focused;
  final Profile? father;
  final Profile? mother;
  final Profile? spouse;
  final List<Profile> siblings;
  final List<Profile> children;
}
