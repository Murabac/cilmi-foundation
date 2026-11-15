import '../theme/app_theme.dart';

enum UserRole { superAdmin, treasury, manager, familyMember }

enum Demographic { adult, student, child }

enum MaritalStatus { single, married, deceased }

enum PaymentStatus { pending, approved, rejected }

/// Monthly member status (school, work, etc.) for family reports.
enum LifeStatus {
  school,
  university,
  working,
  business,
  unemployed,
  homemaker,
  retired,
  tooYoung,
}

extension LifeStatusX on LifeStatus {
  String get dbValue => switch (this) {
        LifeStatus.tooYoung => 'too_young',
        _ => name,
      };

  static LifeStatus? fromDb(String? v) => switch (v) {
        'school' => LifeStatus.school,
        'university' => LifeStatus.university,
        'working' => LifeStatus.working,
        'business' => LifeStatus.business,
        'unemployed' => LifeStatus.unemployed,
        'homemaker' => LifeStatus.homemaker,
        'retired' => LifeStatus.retired,
        'too_young' => LifeStatus.tooYoung,
        _ => null,
      };

  String get labelKey => 'life_$dbValue';

  /// Job title field applies to these statuses.
  bool get hasJob => this == LifeStatus.working || this == LifeStatus.business;
}

/// Admin force billing: null = follow automatic exemption rules.
enum BillingOverride { exempt, billable }

extension BillingOverrideX on BillingOverride {
  String get dbValue => name;

  static BillingOverride? fromDb(String? v) => switch (v) {
        'exempt' => BillingOverride.exempt,
        'billable' => BillingOverride.billable,
        _ => null,
      };
}

extension UserRoleX on UserRole {
  String get dbValue => switch (this) {
        UserRole.superAdmin => 'super_admin',
        UserRole.treasury => 'treasury',
        UserRole.manager => 'manager',
        UserRole.familyMember => 'family_member',
      };

  static UserRole fromDb(String? v) => switch (v) {
        'super_admin' => UserRole.superAdmin,
        'treasury' => UserRole.treasury,
        'manager' => UserRole.manager,
        _ => UserRole.familyMember,
      };

  bool get isSuperAdmin => this == UserRole.superAdmin;

  /// Care ratings (super admin, treasury officers, and admins).
  bool get canManageCare =>
      this == UserRole.superAdmin ||
      this == UserRole.treasury ||
      this == UserRole.manager;

  /// Payment report / mark paid (same staff as care).
  bool get canManagePayments => canManageCare;

  /// Pool donations, aid disbursement, and ledger (super admin + treasury).
  bool get canManageTreasury =>
      this == UserRole.superAdmin || this == UserRole.treasury;

  /// Any elevated staff role.
  bool get isElevated =>
      isSuperAdmin || this == UserRole.manager || this == UserRole.treasury;

  /// Backward-compatible alias for payment/care staff.
  bool get isAdminOrManager => canManagePayments;
}

extension DemographicX on Demographic {
  String get dbValue => name;

  static Demographic fromDb(String? v) => switch (v) {
        'student' => Demographic.student,
        'child' => Demographic.child,
        _ => Demographic.adult,
      };

  bool get isPaymentExempt =>
      this == Demographic.student || this == Demographic.child;
}

extension MaritalStatusX on MaritalStatus {
  String get dbValue => name;

  static MaritalStatus? fromDb(String? v) => switch (v) {
        'married' => MaritalStatus.married,
        'single' => MaritalStatus.single,
        'deceased' => MaritalStatus.deceased,
        _ => null,
      };

  String labelKey() => switch (this) {
        MaritalStatus.single => 'marital_single',
        MaritalStatus.married => 'marital_married',
        MaritalStatus.deceased => 'marital_deceased',
      };
}

extension PaymentStatusX on PaymentStatus {
  String get dbValue => name;

  static PaymentStatus fromDb(String? v) => switch (v) {
        'approved' => PaymentStatus.approved,
        'rejected' => PaymentStatus.rejected,
        _ => PaymentStatus.pending,
      };
}

class Profile {
  const Profile({
    required this.id,
    this.authUserId,
    required this.fullName,
    this.email,
    this.phoneNumber,
    required this.role,
    required this.demographic,
    required this.careRating,
    this.birthOrder = 0,
    this.fatherId,
    this.motherId,
    this.spouseId,
    this.createdAt,
    this.fatherName,
    this.maritalStatus,
    this.occupation,
    this.city,
    this.avatarUrl,
    this.billingOverride,
    this.monthlyAmount,
    this.lifeStatus,
    this.statusUpdatedAt,
  });

  final String id;
  final String? authUserId;
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final UserRole role;
  final Demographic demographic;
  final int careRating;
  final int birthOrder;
  final String? fatherId;
  final String? motherId;
  final String? spouseId;
  final DateTime? createdAt;

  /// Resolved from [fatherId] for display (e.g. claim profile picker).
  final String? fatherName;
  final MaritalStatus? maritalStatus;
  final String? occupation;
  final String? city;
  final String? avatarUrl;
  final BillingOverride? billingOverride;

  /// Monthly contribution in USD. Null or 0 = not on the payers list.
  final double? monthlyAmount;
  final LifeStatus? lifeStatus;
  final DateTime? statusUpdatedAt;

  bool get isPayer => (monthlyAmount ?? 0) > 0;

  /// True when the member has not updated their status this calendar month.
  bool get statusIsStale {
    final at = statusUpdatedAt;
    if (at == null) return true;
    final now = DateTime.now();
    final local = at.toLocal();
    return local.year != now.year || local.month != now.month;
  }

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json['id'] as String,
        authUserId: json['auth_user_id'] as String?,
        fullName: json['full_name'] as String,
        email: json['email'] as String?,
        phoneNumber: json['phone_number'] as String?,
        role: UserRoleX.fromDb(json['role'] as String?),
        demographic: DemographicX.fromDb(json['demographic'] as String?),
        careRating:
            CareRatingTheme.normalize(json['care_rating'] as int? ?? 1),
        birthOrder: json['birth_order'] as int? ?? 0,
        fatherId: json['father_id'] as String?,
        motherId: json['mother_id'] as String?,
        spouseId: json['spouse_id'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
        fatherName: _parseEmbeddedName(json['father'], 'full_name'),
        maritalStatus: MaritalStatusX.fromDb(json['marital_status'] as String?),
        occupation: json['occupation'] as String?,
        city: json['city'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        billingOverride:
            BillingOverrideX.fromDb(json['billing_override'] as String?),
        monthlyAmount: (json['monthly_amount'] as num?)?.toDouble(),
        lifeStatus: LifeStatusX.fromDb(json['life_status'] as String?),
        statusUpdatedAt: json['status_updated_at'] != null
            ? DateTime.parse(json['status_updated_at'] as String)
            : null,
      );

  static String? _parseEmbeddedName(dynamic embedded, String field) {
    if (embedded is Map<String, dynamic>) {
      return embedded[field] as String?;
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'auth_user_id': authUserId,
        'full_name': fullName,
        'email': email,
        'phone_number': phoneNumber,
        'role': role.dbValue,
        'demographic': demographic.dbValue,
        'care_rating': careRating,
        'birth_order': birthOrder,
        'father_id': fatherId,
        'mother_id': motherId,
        'spouse_id': spouseId,
        if (maritalStatus != null) 'marital_status': maritalStatus!.dbValue,
        if (occupation != null) 'occupation': occupation,
        if (city != null) 'city': city,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        'billing_override': billingOverride?.dbValue,
        'monthly_amount': monthlyAmount,
        'life_status': lifeStatus?.dbValue,
        if (statusUpdatedAt != null)
          'status_updated_at': statusUpdatedAt!.toIso8601String(),
      };

  Profile copyWith({
    String? fullName,
    String? phoneNumber,
    UserRole? role,
    Demographic? demographic,
    int? careRating,
    int? birthOrder,
    String? fatherId,
    String? motherId,
    String? spouseId,
    String? fatherName,
    MaritalStatus? maritalStatus,
    String? occupation,
    String? city,
    String? avatarUrl,
    BillingOverride? billingOverride,
    bool clearBillingOverride = false,
    double? monthlyAmount,
    bool clearMonthlyAmount = false,
    LifeStatus? lifeStatus,
    DateTime? statusUpdatedAt,
  }) =>
      Profile(
        id: id,
        authUserId: authUserId,
        fullName: fullName ?? this.fullName,
        email: email,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        role: role ?? this.role,
        demographic: demographic ?? this.demographic,
        careRating: careRating ?? this.careRating,
        birthOrder: birthOrder ?? this.birthOrder,
        fatherId: fatherId ?? this.fatherId,
        motherId: motherId ?? this.motherId,
        spouseId: spouseId ?? this.spouseId,
        createdAt: createdAt,
        fatherName: fatherName ?? this.fatherName,
        maritalStatus: maritalStatus ?? this.maritalStatus,
        occupation: occupation ?? this.occupation,
        city: city ?? this.city,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        billingOverride: clearBillingOverride
            ? null
            : (billingOverride ?? this.billingOverride),
        monthlyAmount:
            clearMonthlyAmount ? null : (monthlyAmount ?? this.monthlyAmount),
        lifeStatus: lifeStatus ?? this.lifeStatus,
        statusUpdatedAt: statusUpdatedAt ?? this.statusUpdatedAt,
      );
}

enum ClaimRequestStatus { pending, approved, rejected }

extension ClaimRequestStatusX on ClaimRequestStatus {
  String get dbValue => name;

  static ClaimRequestStatus fromDb(String? v) => switch (v) {
        'approved' => ClaimRequestStatus.approved,
        'rejected' => ClaimRequestStatus.rejected,
        _ => ClaimRequestStatus.pending,
      };
}

class ProfileClaimRequest {
  const ProfileClaimRequest({
    required this.id,
    required this.profileId,
    required this.authUserId,
    required this.requesterName,
    this.requesterPhone,
    required this.status,
    this.profileFullName,
    this.createdAt,
    this.rejectionReason,
  });

  final String id;
  final String profileId;
  final String authUserId;
  final String requesterName;
  final String? requesterPhone;
  final ClaimRequestStatus status;
  final String? profileFullName;
  final DateTime? createdAt;
  final String? rejectionReason;

  factory ProfileClaimRequest.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    return ProfileClaimRequest(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      authUserId: json['auth_user_id'] as String,
      requesterName: json['requester_name'] as String,
      requesterPhone: json['requester_phone'] as String?,
      status: ClaimRequestStatusX.fromDb(json['status'] as String?),
      profileFullName: profile?['full_name'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      rejectionReason: json['rejection_reason'] as String?,
    );
  }
}

class Contribution {
  const Contribution({
    required this.id,
    required this.userId,
    required this.billingMonth,
    required this.billingYear,
    required this.amountDue,
    required this.amountPaid,
    required this.status,
    this.transactionReference,
    this.receiptUrl,
    this.verifiedBy,
    this.verifiedAt,
    this.createdAt,
    this.profileName,
  });

  final String id;
  final String userId;
  final int billingMonth;
  final int billingYear;
  final double amountDue;
  final double amountPaid;
  final PaymentStatus status;
  final String? transactionReference;
  final String? receiptUrl;
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final DateTime? createdAt;
  final String? profileName;

  factory Contribution.fromJson(Map<String, dynamic> json) => Contribution(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        billingMonth: json['billing_month'] as int,
        billingYear: json['billing_year'] as int,
        amountDue: (json['amount_due'] as num).toDouble(),
        amountPaid: (json['amount_paid'] as num?)?.toDouble() ?? 0,
        status: PaymentStatusX.fromDb(json['status'] as String?),
        transactionReference: json['transaction_reference'] as String?,
        receiptUrl: json['receipt_url'] as String?,
        verifiedBy: json['verified_by'] as String?,
        verifiedAt: json['verified_at'] != null
            ? DateTime.parse(json['verified_at'] as String)
            : null,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
        profileName: json['profile_name'] as String?,
      );
}

class GlobalSettings {
  const GlobalSettings({
    required this.currentAdultRate,
    required this.appLanguage,
    required this.paymentMerchantId,
    required this.ussdServiceCode,
    required this.edahabMerchantId,
    required this.edahabUssdServiceCode,
    required this.familyTreeView,
    this.whatsappGroupTitle = 'AHMED CILMI GROUP',
    this.updatedAt,
  });

  final double currentAdultRate;
  final String appLanguage;

  /// ZAAD merchant / till number.
  final String paymentMerchantId;
  final String ussdServiceCode;

  /// e-Dahab merchant / till number.
  final String edahabMerchantId;
  final String edahabUssdServiceCode;

  final FamilyTreeViewMode familyTreeView;

  /// Group line in the WhatsApp contributions message.
  final String whatsappGroupTitle;
  final DateTime? updatedAt;

  factory GlobalSettings.fromJson(Map<String, dynamic> json) => GlobalSettings(
        currentAdultRate: (json['current_adult_rate'] as num).toDouble(),
        appLanguage: json['app_language'] as String? ?? 'so',
        paymentMerchantId: json['payment_merchant_id'] as String? ?? '484594',
        ussdServiceCode: json['ussd_service_code'] as String? ?? '883',
        edahabMerchantId: json['edahab_merchant_id'] as String? ?? '764043',
        edahabUssdServiceCode:
            json['edahab_ussd_service_code'] as String? ?? '789',
        familyTreeView: FamilyTreeViewMode.fromDb(
          json['family_tree_view'] as String?,
        ),
        whatsappGroupTitle:
            json['whatsapp_group_title'] as String? ?? 'AHMED CILMI GROUP',
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : null,
      );
}

enum FamilyTreeViewMode {
  chart,
  list;

  String get dbValue => switch (this) {
        FamilyTreeViewMode.chart => 'chart',
        FamilyTreeViewMode.list => 'list',
      };

  static FamilyTreeViewMode fromDb(String? value) =>
      value == 'list' ? FamilyTreeViewMode.list : FamilyTreeViewMode.chart;
}

class TreasuryOutflow {
  const TreasuryOutflow({
    required this.id,
    this.beneficiaryId,
    required this.amount,
    required this.reason,
    this.approvedBy,
    this.createdAt,
    this.beneficiaryName,
  });

  final String id;
  final String? beneficiaryId;
  final double amount;
  final String reason;
  final String? approvedBy;
  final DateTime? createdAt;
  final String? beneficiaryName;

  factory TreasuryOutflow.fromJson(Map<String, dynamic> json) =>
      TreasuryOutflow(
        id: json['id'] as String,
        beneficiaryId: json['beneficiary_id'] as String?,
        amount: (json['amount'] as num).toDouble(),
        reason: json['reason'] as String,
        approvedBy: json['approved_by'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
        beneficiaryName: json['beneficiary_name'] as String?,
      );
}

class LedgerEntry {
  const LedgerEntry({
    required this.date,
    required this.isInflow,
    required this.amount,
    required this.description,
    this.verifiedByName,
    this.id,
    this.source,
  });

  final DateTime date;
  final bool isInflow;
  final double amount;
  final String description;
  final String? verifiedByName;

  /// Row id when this entry can be deleted by a super admin.
  final String? id;
  final LedgerSource? source;

  bool get canDelete => id != null && source != null;
}

enum LedgerSource { contribution, treasuryInflow, treasuryOutflow }

/// One member's status for one month (from member_status_history).
class MemberStatusEntry {
  const MemberStatusEntry({
    required this.profileId,
    required this.period,
    this.lifeStatus,
    this.occupation,
    this.maritalStatus,
    this.updatedAt,
  });

  final String profileId;
  final DateTime period;
  final LifeStatus? lifeStatus;
  final String? occupation;
  final MaritalStatus? maritalStatus;
  final DateTime? updatedAt;

  factory MemberStatusEntry.fromJson(Map<String, dynamic> json) =>
      MemberStatusEntry(
        profileId: json['profile_id'] as String,
        period: DateTime.parse(json['period'] as String),
        lifeStatus: LifeStatusX.fromDb(json['life_status'] as String?),
        occupation: json['occupation'] as String?,
        maritalStatus: MaritalStatusX.fromDb(json['marital_status'] as String?),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : null,
      );
}
