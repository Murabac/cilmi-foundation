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
    _p('uncle', 'CABDIQADIR', fatherId: 'patriarch'),
    _p('cousin', 'MOHAMED', fatherId: 'uncle'),
    _p('student', 'ALI', fatherId: 'uncle', demographic: Demographic.student),
    _p('orphan', 'EXTRA'),
  ];

  test('findPatriarchProfile prefers named root', () {
    expect(findPatriarchProfile(profiles)?.id, 'patriarch');
  });

  test('isProfilePaymentExempt covers patriarch uncles students', () {
    expect(
      isProfilePaymentExempt(_p('patriarch', 'SHEEKH YONIS'), allProfiles: profiles),
      isTrue,
    );
    expect(
      isProfilePaymentExempt(_p('uncle', 'CABDIQADIR', fatherId: 'patriarch'),
          allProfiles: profiles),
      isTrue,
    );
    expect(
      isProfilePaymentExempt(_p('cousin', 'MOHAMED', fatherId: 'uncle'),
          allProfiles: profiles),
      isFalse,
    );
    expect(
      isProfilePaymentExempt(_p('student', 'ALI', fatherId: 'uncle',
              demographic: Demographic.student),
          allProfiles: profiles),
      isTrue,
    );
  });

  test('wouldCreateFatherCycle detects descendant as father', () {
    final index = BranchFilterIndex.fromProfiles(profiles);
    expect(index.wouldCreateFatherCycle('uncle', 'cousin'), isTrue);
    expect(index.wouldCreateFatherCycle('cousin', 'uncle'), isFalse);
    expect(index.wouldCreateFatherCycle('cousin', 'cousin'), isTrue);
  });
}
