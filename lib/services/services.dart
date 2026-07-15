import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../l10n/app_localizations.dart';
import '../models/lineage_registration.dart';
import '../models/models.dart';
import '../models/payment_report.dart';
import '../utils/lineage_name.dart';
import '../utils/payment_exempt.dart';
import '../utils/profile_sort.dart';
import '../utils/phone_utils.dart';

SupabaseQuerySchema _db(SupabaseClient client) =>
    client.schema(SupabaseConfig.schema);

class AuthService {
  AuthService(this._client);

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<void> signIn(String login, String password) async {
    final trimmed = login.trim();

    // Legacy: accounts created with real email before phone login.
    if (trimmed.contains('@')) {
      await _client.auth.signInWithPassword(
        email: trimmed,
        password: password,
      );
      return;
    }

    final phoneError = validatePhoneForSignup(trimmed);
    if (phoneError != null) {
      throw AuthException(phoneError);
    }

    final normalized = normalizePhone(trimmed);
    AuthException? lastError;

    for (final email in authEmailsForPhone(normalized)) {
      try {
        await _client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        return;
      } on AuthException catch (e) {
        lastError = e;
        // Wrong password is the same for every synthetic email — stop early.
        if (_isInvalidCredentials(e)) throw e;
      }
    }

    throw lastError ?? AuthException('Login failed');
  }

  bool _isInvalidCredentials(AuthException e) {
    final message = e.message.toLowerCase();
    return message.contains('invalid login credentials') ||
        message.contains('invalid_credentials');
  }

  /// Returns true when a session is created immediately (no confirmation step).
  Future<bool> signUp(String phone, String password, String fullName) async {
    final phoneError = validatePhoneForSignup(phone);
    if (phoneError != null) {
      throw AuthException(phoneError);
    }

    final normalized = normalizePhone(phone);
    final response = await _client.auth.signUp(
      email: phoneToAuthEmail(normalized),
      password: password,
      data: {
        'app': 'reer_sh_yoonis',
        'full_name': fullName,
        'phone': normalized,
      },
    );
    return response.session != null;
  }

  Future<void> signOut() => _client.auth.signOut();
}

class ProfileService {
  ProfileService(this._client);

  final SupabaseClient _client;

  /// [profile_claim_requests] also references [profiles] via reviewed_by.
  static const _claimRequestSelect =
      '*, profiles!profile_claim_requests_profile_id_fkey(full_name)';

  Future<Profile?> getCurrentProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final data = await _db(_client)
        .from('profiles')
        .select()
        .eq('auth_user_id', user.id)
        .maybeSingle();

    if (data == null) return null;
    return Profile.fromJson(data);
  }

  bool needsLineageSetup(Profile? profile) {
    if (profile == null) return true;
    if (profile.fatherId != null) return false;
    return !profile.fullName.toUpperCase().contains('SHEEKH YONIS');
  }

  Future<List<Profile>> getUnclaimedProfiles() async {
    final rows = await _db(_client)
        .from('profiles')
        .select()
        .filter('auth_user_id', 'is', null)
        .order('birth_order')
        .order('full_name');

    final nameRows =
        await _db(_client).from('profiles').select('id, full_name');
    final nameById = {
      for (final r in nameRows as List)
        r['id'] as String: r['full_name'] as String,
    };

    return (rows as List).map((e) {
      final profile = Profile.fromJson(e);
      if (profile.fatherId == null) return profile;
      final fatherName = nameById[profile.fatherId];
      if (fatherName == null) return profile;
      return profile.copyWith(fatherName: fatherName);
    }).toList();
  }

  Future<List<Profile>> getSonsOfPatriarch() async {
    final root = await getRootProfile();
    if (root == null) return [];
    return getChildren(root.id);
  }

  Future<Profile> claimExistingProfile(
    String profileId, {
    String? phoneNumber,
  }) async {
    throw UnsupportedError(
      'Direct profile claims are disabled. Use submitProfileClaim.',
    );
  }

  Future<String> submitProfileClaim({
    required String profileId,
    required String requesterName,
    String? phoneNumber,
  }) async {
    final result = await _db(_client).rpc(
      'submit_profile_claim',
      params: {
        'p_profile_id': profileId,
        'p_requester_name': requesterName.trim(),
        'p_requester_phone': phoneNumber?.trim(),
      },
    );
    return result as String;
  }

  Future<ProfileClaimRequest?> getMyPendingClaimRequest() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final data = await _db(_client)
        .from('profile_claim_requests')
        .select(_claimRequestSelect)
        .eq('auth_user_id', user.id)
        .eq('status', 'pending')
        .maybeSingle();

    if (data == null) return null;
    return ProfileClaimRequest.fromJson(data);
  }

  Future<List<ProfileClaimRequest>> getPendingClaimRequests() async {
    final rows = await _db(_client)
        .from('profile_claim_requests')
        .select(_claimRequestSelect)
        .eq('status', 'pending')
        .order('created_at');

    return (rows as List)
        .map((e) => ProfileClaimRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> approveProfileClaim(String requestId) async {
    await _db(_client).rpc(
      'approve_profile_claim',
      params: {'p_request_id': requestId},
    );
  }

  Future<void> rejectProfileClaim(String requestId, {String? reason}) async {
    await _db(_client).rpc(
      'reject_profile_claim',
      params: {
        'p_request_id': requestId,
        'p_reason': reason,
      },
    );
  }

  Future<Profile> createLinkedProfile({
    required String fullName,
    required String fatherId,
    String? phoneNumber,
  }) async {
    final user = _client.auth.currentUser!;
    await _removeOrphanAuthProfile(user.id);

    final existing = await _db(_client)
        .from('profiles')
        .select()
        .eq('auth_user_id', user.id)
        .maybeSingle();

    if (existing != null) {
      final data = await _db(_client)
          .from('profiles')
          .update({
            'full_name': fullName,
            'father_id': fatherId,
            if (phoneNumber != null) 'phone_number': phoneNumber,
          })
          .eq('auth_user_id', user.id)
          .select()
          .single();
      return Profile.fromJson(data);
    }

    final data = await _db(_client)
        .from('profiles')
        .insert({
          'auth_user_id': user.id,
          'full_name': fullName,
          'father_id': fatherId,
          if (phoneNumber != null) 'phone_number': phoneNumber,
        })
        .select()
        .single();

    return Profile.fromJson(data);
  }

  /// Admin: add an unclaimed member to the family tree (no login account).
  Future<Profile> createFamilyMember({
    required String fullName,
    required String fatherId,
    Demographic demographic = Demographic.adult,
    String? phoneNumber,
    int careRating = 2,
  }) async {
    final trimmedName = fullName.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('full_name_required');
    }

    final insert = <String, dynamic>{
      'full_name': trimmedName,
      'father_id': fatherId,
      'demographic': demographic.dbValue,
      'care_rating': careRating,
    };

    if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
      insert['phone_number'] = normalizePhone(phoneNumber.trim());
    }

    final siblings = await _db(_client)
        .from('profiles')
        .select('birth_order')
        .eq('father_id', fatherId);
    var nextOrder = 0;
    for (final row in siblings as List) {
      final order = (row['birth_order'] as num?)?.toInt() ?? 0;
      if (order >= nextOrder) nextOrder = order + 1;
    }
    insert['birth_order'] = nextOrder;

    final data = await _db(_client)
        .from('profiles')
        .insert(insert)
        .select()
        .single();

    return Profile.fromJson(data);
  }

  Future<void> completeLineageSetup({
    required LineageSelection selection,
    required String fullName,
    String? phoneNumber,
    required AppLocalizations l10n,
  }) async {
    if (selection.type != LineageRegistrationType.claimExisting) {
      throw Exception(l10n.t('claim_only_registration'));
    }
    if (selection.claimProfile == null) {
      throw Exception(l10n.t('select_your_profile'));
    }

    await submitProfileClaim(
      profileId: selection.claimProfile!.id,
      requesterName: fullName.trim(),
      phoneNumber: phoneNumber,
    );
  }

  Future<void> updatePhone(String profileId, String? phone) async {
    await _db(_client)
        .from('profiles')
        .update({'phone_number': phone}).eq('id', profileId);
  }

  Future<void> _removeOrphanAuthProfile(String userId) async {
    await _db(_client)
        .from('profiles')
        .delete()
        .eq('auth_user_id', userId)
        .filter('father_id', 'is', null);
  }

  Future<Profile?> getRootProfile() async {
    final rows = await _db(_client)
        .from('profiles')
        .select()
        .filter('father_id', 'is', null)
        .ilike('full_name', '%SHEEKH YONIS%')
        .order('full_name')
        .limit(1);
    final list = rows as List;
    if (list.isNotEmpty) return Profile.fromJson(list.first);

    final fallback = await _db(_client)
        .from('profiles')
        .select()
        .filter('father_id', 'is', null)
        .order('full_name')
        .limit(1);
    final fallbackList = fallback as List;
    if (fallbackList.isEmpty) return null;
    return Profile.fromJson(fallbackList.first);
  }

  Future<int> getMemberCount() async {
    final rows = await _db(_client).from('profiles').select('id');
    return (rows as List).length;
  }

  Future<List<Profile>> getAllProfiles() async {
    final rows = await _db(_client).from('profiles').select();
    final list = (rows as List).map((e) => Profile.fromJson(e)).toList();
    return sortProfilesInTreeAgeOrder(list);
  }

  Future<String> buildFullLineageName(String profileId) async {
    final all = await getAllProfiles();
    final byId = {for (final p in all) p.id: p};
    final profile = byId[profileId];
    if (profile == null) return '';
    return buildPatrilinealDisplayName(profile, byId);
  }

  Future<Profile?> getProfileById(String id) async {
    final data =
        await _db(_client).from('profiles').select().eq('id', id).maybeSingle();
    if (data == null) return null;
    return Profile.fromJson(data);
  }

  Future<List<Profile>> getChildren(String parentId) async {
    final rows = await _db(_client)
        .from('profiles')
        .select()
        .or('father_id.eq.$parentId,mother_id.eq.$parentId')
        .order('birth_order')
        .order('full_name');
    final list = (rows as List).map((e) => Profile.fromJson(e)).toList();
    sortProfilesByAge(list);
    return list;
  }

  Future<List<Profile>> getSiblings(Profile profile) async {
    if (profile.fatherId == null && profile.motherId == null) return [];

    var query = _db(_client).from('profiles').select().neq('id', profile.id);
    if (profile.fatherId != null && profile.motherId != null) {
      query = query.or(
        'and(father_id.eq.${profile.fatherId},mother_id.eq.${profile.motherId})',
      );
    } else if (profile.fatherId != null) {
      query = query.eq('father_id', profile.fatherId!);
    } else {
      query = query.eq('mother_id', profile.motherId!);
    }

    final rows = await query.order('birth_order').order('full_name');
    final list = (rows as List).map((e) => Profile.fromJson(e)).toList();
    sortProfilesByAge(list);
    return list;
  }

  Future<List<Profile>> getCarePriorityProfiles() async {
    final rows = await _db(_client)
        .from('profiles')
        .select()
        .gte('care_rating', 3);
    final list = (rows as List).map((e) => Profile.fromJson(e)).toList();
    list.sort((a, b) {
      final byCare = b.careRating.compareTo(a.careRating);
      if (byCare != 0) return byCare;
      return compareProfilesByAge(a, b);
    });
    return list;
  }

  Future<List<Profile>> getAllProfilesSortedByCare() async {
    final rows = await _db(_client).from('profiles').select();
    final list = (rows as List).map((e) => Profile.fromJson(e)).toList();
    list.sort((a, b) {
      final byCare = b.careRating.compareTo(a.careRating);
      if (byCare != 0) return byCare;
      return compareProfilesByAge(a, b);
    });
    return list;
  }

  Future<int> countUrgentProfiles() async {
    final rows = await _db(_client)
        .from('profiles')
        .select('id')
        .gte('care_rating', 4);
    return (rows as List).length;
  }

  List<String> _selfAndDescendantIds(String profileId, List<Profile> all) {
    final childrenByFather = <String, List<String>>{};
    for (final p in all) {
      if (p.fatherId != null) {
        childrenByFather.putIfAbsent(p.fatherId!, () => []).add(p.id);
      }
    }
    final ids = <String>[profileId];
    void walk(String id) {
      for (final childId in childrenByFather[id] ?? []) {
        ids.add(childId);
        walk(childId);
      }
    }
    walk(profileId);
    return ids;
  }

  int descendantCount(String profileId, List<Profile> all) {
    return _selfAndDescendantIds(profileId, all).length - 1;
  }

  Future<void> updateCareRating(String profileId, int rating) async {
    final all = await getAllProfiles();
    final ids = _selfAndDescendantIds(profileId, all);
    await _db(_client)
        .from('profiles')
        .update({'care_rating': rating}).inFilter('id', ids);
  }

  Future<void> updateRole(String profileId, UserRole role) async {
    await _db(_client)
        .from('profiles')
        .update({'role': role.dbValue}).eq('id', profileId);
  }

  Future<void> updateDemographic(String profileId, Demographic demo) async {
    await _db(_client)
        .from('profiles')
        .update({'demographic': demo.dbValue}).eq('id', profileId);
  }

  Future<Profile> updateMemberProfileAdmin({
    required String profileId,
    String? phoneNumber,
    MaritalStatus? maritalStatus,
    String? occupation,
    String? city,
    int? careRating,
    String? avatarUrl,
    String? fullName,
    String? fatherId,
    bool clearFatherId = false,
    int? birthOrder,
  }) async {
    final updates = <String, dynamic>{};
    if (phoneNumber != null) updates['phone_number'] = phoneNumber;
    if (maritalStatus != null) {
      updates['marital_status'] = maritalStatus.dbValue;
    }
    if (occupation != null) updates['occupation'] = occupation;
    if (city != null) updates['city'] = city;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (fullName != null) updates['full_name'] = fullName.trim();
    if (clearFatherId) {
      updates['father_id'] = null;
    } else if (fatherId != null) {
      updates['father_id'] = fatherId;
    }
    if (birthOrder != null) updates['birth_order'] = birthOrder;

    if (careRating != null) {
      await updateCareRating(profileId, careRating);
    }

    if (updates.isEmpty) {
      final data = await _db(_client)
          .from('profiles')
          .select()
          .eq('id', profileId)
          .single();
      return Profile.fromJson(data);
    }

    final data = await _db(_client)
        .from('profiles')
        .update(updates)
        .eq('id', profileId)
        .select()
        .single();

    return Profile.fromJson(data);
  }

  Future<String> uploadAvatar(
    String profileId,
    Uint8List bytes,
    String ext,
  ) async {
    final path = '$profileId/avatar.$ext';
    await _client.storage.from(SupabaseConfig.avatarBucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: ext == 'png' ? 'image/png' : 'image/jpeg',
          ),
        );
    return _client.storage.from(SupabaseConfig.avatarBucket).getPublicUrl(path);
  }
}

class SettingsService {
  SettingsService(this._client);

  final SupabaseClient _client;

  Future<GlobalSettings> getSettings() async {
    final data = await _db(_client)
        .from('global_settings')
        .select()
        .eq('id', 1)
        .single();
    return GlobalSettings.fromJson(data);
  }

  Future<void> updateSettings({
    double? adultRate,
    String? language,
    String? paymentMerchantId,
    String? ussdServiceCode,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (adultRate != null) updates['current_adult_rate'] = adultRate;
    if (language != null) updates['app_language'] = language;
    if (paymentMerchantId != null) {
      updates['payment_merchant_id'] = paymentMerchantId;
    }
    if (ussdServiceCode != null) updates['ussd_service_code'] = ussdServiceCode;

    await _db(_client).from('global_settings').update(updates).eq('id', 1);
  }
}

class ContributionService {
  ContributionService(this._client);

  final SupabaseClient _client;

  Future<List<Contribution>> getMyContributions(String userId) async {
    final rows = await _db(_client)
        .from('contributions')
        .select()
        .eq('user_id', userId)
        .order('billing_year', ascending: false)
        .order('billing_month', ascending: false);
    return (rows as List).map((e) => Contribution.fromJson(e)).toList();
  }

  Future<List<Contribution>> getPendingContributions() async {
    final profileRows = await _db(_client).from('profiles').select();
    final profiles = (profileRows as List)
        .map((e) => Profile.fromJson(e))
        .toList();

    final rows = await _db(_client)
        .from('contributions')
        .select('*, profiles!contributions_user_id_fkey(full_name)')
        .eq('status', 'pending')
        .not('transaction_reference', 'is', null)
        .order('created_at', ascending: false);

    return (rows as List).map((e) {
      final profile = e['profiles'] as Map<String, dynamic>?;
      return Contribution.fromJson({
        ...e,
        'profile_name': profile?['full_name'],
      });
    }).where((c) {
      final member = profiles.where((p) => p.id == c.userId).firstOrNull;
      if (member == null) return true;
      return !isProfilePaymentExempt(member, allProfiles: profiles);
    }).toList();
  }

  Future<Contribution?> getCurrentMonthContribution(String userId) async {
    final now = DateTime.now();
    final data = await _db(_client)
        .from('contributions')
        .select()
        .eq('user_id', userId)
        .eq('billing_month', now.month)
        .eq('billing_year', now.year)
        .maybeSingle();
    if (data == null) return null;
    return Contribution.fromJson(data);
  }

  Future<void> logPayment({
    required String userId,
    required String reference,
    String? receiptUrl,
    double? amountDue,
  }) async {
    final profileRows = await _db(_client).from('profiles').select();
    final profiles = (profileRows as List)
        .map((e) => Profile.fromJson(e))
        .toList();
    final payer = profiles.where((p) => p.id == userId).firstOrNull;
    if (payer != null && isProfilePaymentExempt(payer, allProfiles: profiles)) {
      throw Exception('payment_exempt');
    }

    final settings = await SettingsService(_client).getSettings();
    final due = amountDue ?? settings.currentAdultRate;

    final now = DateTime.now();
    final existing = await getCurrentMonthContribution(userId);

    if (existing != null) {
      await _db(_client).from('contributions').update({
        'transaction_reference': reference,
        'receipt_url': receiptUrl,
        'amount_paid': due,
        'amount_due': due,
        'status': 'pending',
      }).eq('id', existing.id);
    } else {
      await _db(_client).from('contributions').insert({
        'user_id': userId,
        'billing_month': now.month,
        'billing_year': now.year,
        'amount_due': due,
        'amount_paid': due,
        'transaction_reference': reference,
        'receipt_url': receiptUrl,
        'status': 'pending',
      });
    }
  }

  Future<void> verifyContribution({
    required String contributionId,
    required String verifierId,
    required bool approve,
  }) async {
    await _db(_client).from('contributions').update({
      'status': approve ? 'approved' : 'rejected',
      'verified_by': verifierId,
      'verified_at': DateTime.now().toIso8601String(),
    }).eq('id', contributionId);
  }

  Future<Contribution?> getContributionForPeriod({
    required String userId,
    required int month,
    required int year,
  }) async {
    final data = await _db(_client)
        .from('contributions')
        .select()
        .eq('user_id', userId)
        .eq('billing_month', month)
        .eq('billing_year', year)
        .maybeSingle();
    if (data == null) return null;
    return Contribution.fromJson(data);
  }

  /// Admin records payment received by phone or marks member unpaid for a month.
  Future<void> adminSetPaymentStatus({
    required String userId,
    required int month,
    required int year,
    required String verifierId,
    required double adultRate,
    required bool markPaid,
    String? reference,
  }) async {
    final profileRows = await _db(_client).from('profiles').select();
    final profiles = (profileRows as List)
        .map((e) => Profile.fromJson(e))
        .toList();
    final member = profiles.where((p) => p.id == userId).firstOrNull;
    if (member != null && isProfilePaymentExempt(member, allProfiles: profiles)) {
      throw Exception('payment_exempt');
    }

    final existing = await getContributionForPeriod(
      userId: userId,
      month: month,
      year: year,
    );
    final now = DateTime.now().toIso8601String();

    if (markPaid) {
      final refNote = (reference?.trim().isNotEmpty ?? false)
          ? reference!.trim()
          : 'Phone payment (admin)';

      if (existing != null) {
        await _db(_client).from('contributions').update({
          'status': 'approved',
          'amount_due': adultRate,
          'amount_paid': adultRate,
          'transaction_reference':
              existing.transactionReference ?? refNote,
          'verified_by': verifierId,
          'verified_at': now,
        }).eq('id', existing.id);
      } else {
        await _db(_client).from('contributions').insert({
          'user_id': userId,
          'billing_month': month,
          'billing_year': year,
          'amount_due': adultRate,
          'amount_paid': adultRate,
          'transaction_reference': refNote,
          'status': 'approved',
          'verified_by': verifierId,
          'verified_at': now,
        });
      }
      return;
    }

    if (existing == null) return;

    await _db(_client).from('contributions').update({
      'status': 'pending',
      'amount_paid': 0,
      'verified_by': null,
      'verified_at': null,
    }).eq('id', existing.id);
  }

  Future<String?> uploadReceipt(String userId, Uint8List bytes, String ext) async {
    final path = '$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _client.storage
        .from(SupabaseConfig.storageBucket)
        .uploadBinary(path, bytes);
    return path;
  }

  Future<int> generateMonthlyBilling() async {
    final result = await _db(_client).rpc('generate_monthly_billing');
    return result as int? ?? 0;
  }

  Future<MonthlyPaymentReport> getMonthlyPaymentReport({
    required int month,
    required int year,
  }) async {
    await _db(_client).rpc('purge_exempt_contributions');

    final settings = await SettingsService(_client).getSettings();
    final profileRows = await _db(_client).from('profiles').select();
    final profiles = sortProfilesInTreeAgeOrder(
      (profileRows as List).map((e) => Profile.fromJson(e)).toList(),
    );

    final contributionRows = await _db(_client)
        .from('contributions')
        .select()
        .eq('billing_month', month)
        .eq('billing_year', year);

    final byUserId = <String, Contribution>{};
    for (final row in contributionRows as List) {
      final c = Contribution.fromJson(row);
      byUserId[c.userId] = c;
    }

    final rows = profiles
        .where((p) => !isProfilePaymentExempt(p, allProfiles: profiles))
        .map(
          (p) => MemberPaymentRow(
            profile: p,
            contribution: byUserId[p.id],
          ),
        )
        .toList();

    return MonthlyPaymentReport(
      month: month,
      year: year,
      rows: rows,
      adultRate: settings.currentAdultRate,
    );
  }
}

class TreasuryService {
  TreasuryService(this._client);

  final SupabaseClient _client;

  Future<double> getPoolBalance() async {
    final inflows = await _db(_client)
        .from('contributions')
        .select('amount_paid')
        .eq('status', 'approved');

    final outflows =
        await _db(_client).from('treasury_outflows').select('amount');

    double totalIn = 0;
    for (final row in inflows as List) {
      totalIn += (row['amount_paid'] as num?)?.toDouble() ?? 0;
    }

    double totalOut = 0;
    for (final row in outflows as List) {
      totalOut += (row['amount'] as num).toDouble();
    }

    return totalIn - totalOut;
  }

  Future<List<LedgerEntry>> getAuditLedger() async {
    final contributions = await _db(_client)
        .from('contributions')
        .select(
          'amount_paid, verified_at, created_at, profiles!contributions_user_id_fkey(full_name), verifier:profiles!contributions_verified_by_fkey(full_name)',
        )
        .eq('status', 'approved')
        .order('verified_at', ascending: false);

    final outflows = await _db(_client)
        .from('treasury_outflows')
        .select(
          'amount, reason, created_at, beneficiary:profiles!treasury_outflows_beneficiary_id_fkey(full_name)',
        )
        .order('created_at', ascending: false);

    final entries = <LedgerEntry>[];

    for (final c in contributions as List) {
      final member = c['profiles'] as Map<String, dynamic>?;
      final verifier = c['verifier'] as Map<String, dynamic>?;
      entries.add(LedgerEntry(
        date: DateTime.parse(
          (c['verified_at'] ?? c['created_at']) as String,
        ),
        isInflow: true,
        amount: (c['amount_paid'] as num).toDouble(),
        description: member?['full_name'] as String? ?? 'Member',
        verifiedByName: verifier?['full_name'] as String?,
      ));
    }

    for (final o in outflows as List) {
      final beneficiary = o['beneficiary'] as Map<String, dynamic>?;
      entries.add(LedgerEntry(
        date: DateTime.parse(o['created_at'] as String),
        isInflow: false,
        amount: (o['amount'] as num).toDouble(),
        description:
            '${beneficiary?['full_name'] ?? 'Member'} — ${o['reason']}',
      ));
    }

    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  Future<void> recordOutflow({
    required String beneficiaryId,
    required double amount,
    required String reason,
    required String approvedBy,
  }) async {
    if (amount <= 0) {
      throw TreasuryException('invalid_amount');
    }

    try {
      await _db(_client).rpc(
        'record_treasury_outflow',
        params: {
          'p_beneficiary_id': beneficiaryId,
          'p_amount': amount,
          'p_reason': reason,
          'p_approved_by': approvedBy,
        },
      );
    } catch (e) {
      if (e.toString().contains('insufficient_pool_balance')) {
        final balance = await getPoolBalance();
        throw InsufficientPoolBalanceException(
          available: balance,
          requested: amount,
        );
      }
      rethrow;
    }
  }
}

class TreasuryException implements Exception {
  TreasuryException(this.code);
  final String code;

  @override
  String toString() => code;
}

class InsufficientPoolBalanceException implements Exception {
  InsufficientPoolBalanceException({
    required this.available,
    required this.requested,
  });

  final double available;
  final double requested;

  @override
  String toString() => 'insufficient_pool_balance';
}

class AdminService {
  AdminService(this._client);

  final SupabaseClient _client;

  /// Clears monthly payments and treasury disbursements, then resets care ratings.
  Future<void> resetOperationalData() async {
    await _db(_client)
        .from('contributions')
        .delete()
        .gte('billing_year', 1970);
    await _db(_client)
        .from('treasury_outflows')
        .delete()
        .gte('created_at', '1970-01-01T00:00:00Z');
    await _db(_client).from('profiles').update({'care_rating': 2});

    final patriarch = await _db(_client)
        .from('profiles')
        .select('id')
        .ilike('full_name', 'SHEEKH YONIS')
        .maybeSingle();
    if (patriarch != null) {
      await _db(_client)
          .from('profiles')
          .update({'care_rating': 1})
          .eq('id', patriarch['id'] as String);
    }
  }

  /// Unlinks profiles whose auth account was deleted so they can be claimed again.
  Future<int> releaseStaleProfileClaims() async {
    final count = await _db(_client).rpc('release_stale_profile_claims');
    return (count as num).toInt();
  }

  Future<void> releaseProfileClaim(String profileId) async {
    await _db(_client).rpc(
      'release_profile_claim',
      params: {'p_profile_id': profileId},
    );
  }
}
