import 'package:flutter_test/flutter_test.dart';

import 'package:reer_sh_yoonis/models/models.dart';
import 'package:reer_sh_yoonis/utils/branch_filter.dart';
import 'package:reer_sh_yoonis/utils/patriarch_resolver.dart';
import 'package:reer_sh_yoonis/utils/payment_exempt.dart';

Profile _p(
  String id,
  String name, {
  String? fatherId,
  Demographic demographic = Demographic.adult,
}) =>
    Profile(
      id: id,
      fullName: name,
      role: UserRole.familyMember,
      demographic: demographic,
      careRating: 2,
      fatherId: fatherId,
    );

void main() {
  final profiles = [
    _p('patriarch', 'SHEEKH YONIS'),
    _p('uncle', 'MIRE', fatherId: 'patriarch'),
    _p('grandchild', 'NIMCO', fatherId: 'uncle'),
    _p('below_gc', 'AMIIN', fatherId: 'grandchild'),
    _p('student', 'ALI', fatherId: 'uncle', demographic: Demographic.student),
    _p('orphan', 'EXTRA'),
    _p('daughter', 'KHADRA SHEEKH', fatherId: 'patriarch'),
    _p('daughter_kid', 'SAYNAB ISMAIL', fatherId: 'daughter'),
  ];

  test('findPatriarchProfile prefers named root', () {
    expect(findPatriarchProfile(profiles)?.id, 'patriarch');
  });

  test('isProfilePaymentExempt covers patriarch uncles and below-grandchild', () {
    expect(
      isProfilePaymentExempt(_p('patriarch', 'SHEEKH YONIS'), allProfiles: profiles),
      isTrue,
    );
    expect(
      isProfilePaymentExempt(_p('uncle', 'MIRE', fatherId: 'patriarch'),
          allProfiles: profiles),
      isTrue,
    );
    expect(
      isProfilePaymentExempt(_p('grandchild', 'NIMCO', fatherId: 'uncle'),
          allProfiles: profiles),
      isFalse,
    );
    expect(
      isProfilePaymentExempt(_p('below_gc', 'AMIIN', fatherId: 'grandchild'),
          allProfiles: profiles),
      isTrue,
    );
    expect(
      isProfilePaymentExempt(_p('student', 'ALI', fatherId: 'uncle',
              demographic: Demographic.student),
          allProfiles: profiles),
      isTrue,
    );
  });

  test('daughter and daughter children are exempt', () {
    expect(
      isProfilePaymentExempt(
        _p('daughter', 'KHADRA SHEEKH', fatherId: 'patriarch'),
        allProfiles: profiles,
      ),
      isTrue,
    );
    expect(
      isProfilePaymentExempt(
        _p('daughter_kid', 'SAYNAB ISMAIL', fatherId: 'daughter'),
        allProfiles: profiles,
      ),
      isTrue,
    );
  });

  test('billing override can force exempt or billable', () {
    final billableGrandchild = _p(
      'grandchild',
      'NIMCO',
      fatherId: 'uncle',
    ).copyWith(billingOverride: BillingOverride.exempt);
    expect(
      isProfilePaymentExempt(billableGrandchild, allProfiles: profiles),
      isTrue,
    );

    final forcedPayer = _p(
      'daughter_kid',
      'SAYNAB ISMAIL',
      fatherId: 'daughter',
    ).copyWith(billingOverride: BillingOverride.billable);
    expect(
      isProfilePaymentExempt(forcedPayer, allProfiles: profiles),
      isFalse,
    );
  });

  test('wouldCreateFatherCycle detects descendant as father', () {
    final index = BranchFilterIndex.fromProfiles(profiles);
    expect(index.wouldCreateFatherCycle('uncle', 'grandchild'), isTrue);
    expect(index.wouldCreateFatherCycle('grandchild', 'uncle'), isFalse);
    expect(index.wouldCreateFatherCycle('grandchild', 'grandchild'), isTrue);
  });
}
