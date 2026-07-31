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
  // Legacy fixture: Sheekh as root (pre-Cilmi migration).
  final legacyProfiles = [
    _p('patriarch', 'SHEEKH YONIS'),
    _p('uncle', 'MIRE', fatherId: 'patriarch'),
    _p('grandchild', 'NIMCO', fatherId: 'uncle'),
    _p('below_gc', 'AMIIN', fatherId: 'grandchild'),
    _p('student', 'ALI', fatherId: 'uncle', demographic: Demographic.student),
    _p('orphan', 'EXTRA'),
    _p('daughter', 'KHADRA SHEEKH', fatherId: 'patriarch'),
    _p('daughter_kid', 'SAYNAB ISMAIL', fatherId: 'daughter'),
  ];

  // Cilmi → Ahmed → Sheekh | Aadan
  final cilmiProfiles = [
    _p('cilmi', 'CILMI'),
    _p('ahmed', 'AHMED', fatherId: 'cilmi'),
    _p('sheekh', 'SHEEKH YONIS', fatherId: 'ahmed'),
    _p('aadan', 'AADAN', fatherId: 'ahmed'),
    _p('uncle', 'MIRE', fatherId: 'sheekh'),
    _p('grandchild', 'NIMCO', fatherId: 'uncle'),
    _p('below_gc', 'AMIIN', fatherId: 'grandchild'),
    _p('daughter', 'KHADRA SHEEKH', fatherId: 'sheekh'),
    _p('daughter_kid', 'SAYNAB ISMAIL', fatherId: 'daughter'),
    _p('aadan_son', 'MOHAMED', fatherId: 'aadan'),
  ];

  test('findPatriarchProfile prefers named root', () {
    expect(findPatriarchProfile(legacyProfiles)?.id, 'patriarch');
    expect(findPatriarchProfile(cilmiProfiles)?.id, 'cilmi');
  });

  test('branch filters use Ahmed children under Cilmi', () {
    final index = BranchFilterIndex.fromProfiles(cilmiProfiles);
    expect(index.branches.map((b) => b.id).toSet(), {'sheekh', 'aadan'});
  });

  test('isProfilePaymentExempt covers patriarch uncles and below-grandchild', () {
    expect(
      isProfilePaymentExempt(_p('patriarch', 'SHEEKH YONIS'),
          allProfiles: legacyProfiles),
      isTrue,
    );
    expect(
      isProfilePaymentExempt(_p('uncle', 'MIRE', fatherId: 'patriarch'),
          allProfiles: legacyProfiles),
      isTrue,
    );
    expect(
      isProfilePaymentExempt(_p('grandchild', 'NIMCO', fatherId: 'uncle'),
          allProfiles: legacyProfiles),
      isFalse,
    );
    expect(
      isProfilePaymentExempt(_p('below_gc', 'AMIIN', fatherId: 'grandchild'),
          allProfiles: legacyProfiles),
      isTrue,
    );
    expect(
      isProfilePaymentExempt(
          _p('student', 'ALI',
              fatherId: 'uncle', demographic: Demographic.student),
          allProfiles: legacyProfiles),
      isTrue,
    );
  });

  test('Cilmi ancestry keeps Sheekh-grandchild billable and uncles exempt', () {
    expect(
      isProfilePaymentExempt(_p('cilmi', 'CILMI'), allProfiles: cilmiProfiles),
      isTrue,
    );
    expect(
      isProfilePaymentExempt(_p('ahmed', 'AHMED', fatherId: 'cilmi'),
          allProfiles: cilmiProfiles),
      isTrue,
    );
    expect(
      isProfilePaymentExempt(_p('sheekh', 'SHEEKH YONIS', fatherId: 'ahmed'),
          allProfiles: cilmiProfiles),
      isTrue,
    );
    expect(
      isProfilePaymentExempt(_p('uncle', 'MIRE', fatherId: 'sheekh'),
          allProfiles: cilmiProfiles),
      isTrue,
    );
    expect(
      isProfilePaymentExempt(_p('grandchild', 'NIMCO', fatherId: 'uncle'),
          allProfiles: cilmiProfiles),
      isFalse,
    );
    expect(
      isProfilePaymentExempt(_p('below_gc', 'AMIIN', fatherId: 'grandchild'),
          allProfiles: cilmiProfiles),
      isTrue,
    );
  });

  test('daughter and daughter children are exempt', () {
    expect(
      isProfilePaymentExempt(
        _p('daughter', 'KHADRA SHEEKH', fatherId: 'patriarch'),
        allProfiles: legacyProfiles,
      ),
      isTrue,
    );
    expect(
      isProfilePaymentExempt(
        _p('daughter_kid', 'SAYNAB ISMAIL', fatherId: 'daughter'),
        allProfiles: legacyProfiles,
      ),
      isTrue,
    );
    expect(
      isProfilePaymentExempt(
        _p('daughter_kid', 'SAYNAB ISMAIL', fatherId: 'daughter'),
        allProfiles: cilmiProfiles,
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
      isProfilePaymentExempt(billableGrandchild, allProfiles: legacyProfiles),
      isTrue,
    );

    final forcedPayer = _p(
      'daughter_kid',
      'SAYNAB ISMAIL',
      fatherId: 'daughter',
    ).copyWith(billingOverride: BillingOverride.billable);
    expect(
      isProfilePaymentExempt(forcedPayer, allProfiles: legacyProfiles),
      isFalse,
    );
  });

  test('wouldCreateFatherCycle detects descendant as father', () {
    final index = BranchFilterIndex.fromProfiles(legacyProfiles);
    expect(index.wouldCreateFatherCycle('uncle', 'grandchild'), isTrue);
    expect(index.wouldCreateFatherCycle('grandchild', 'uncle'), isFalse);
    expect(index.wouldCreateFatherCycle('grandchild', 'grandchild'), isTrue);
  });
}
