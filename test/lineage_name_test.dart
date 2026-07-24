import 'package:flutter_test/flutter_test.dart';
import 'package:reer_sh_yoonis/models/models.dart';
import 'package:reer_sh_yoonis/utils/lineage_name.dart';

Profile _p(
  String id,
  String name, {
  String? fatherId,
}) =>
    Profile(
      id: id,
      fullName: name,
      email: null,
      role: UserRole.familyMember,
      demographic: Demographic.adult,
      careRating: 2,
      fatherId: fatherId,
    );

void main() {
  const patriarchId = 'patriarch';
  const khadraId = 'khadra';
  const childId = 'saynab';

  final daughterBranch = {
    patriarchId: _p(patriarchId, 'SHEEKH YONIS'),
    khadraId: _p(khadraId, 'KHADRA SHEEKH', fatherId: patriarchId),
    childId: _p(childId, 'SAYNAB ISMAIL', fatherId: khadraId),
  };

  test('daughter child shows full name with born-to-mother subtitle', () {
    final info = buildLineageDisplayInfo(daughterBranch[childId]!, daughterBranch);

    expect(info.displayName, 'SAYNAB ISMAIL');
    expect(info.subtitleKind, LineageSubtitleKind.bornToMother);
    expect(info.subtitleText, 'KHADRA SHEEKH');
  });

  test('grandchild shows own name with son-of ancestor chain', () {
    const mireId = 'mire';
    const hodanId = 'hodan';
    const amiinId = 'amiin';

    final byId = {
      patriarchId: _p(patriarchId, 'SHEEKH YONIS'),
      mireId: _p(mireId, 'MIRE', fatherId: patriarchId),
      hodanId: _p(hodanId, 'HODAN', fatherId: mireId),
      amiinId: _p(amiinId, 'AMIIN', fatherId: hodanId),
    };

    final info = buildLineageDisplayInfo(byId[amiinId]!, byId);

    expect(info.displayName, 'AMIIN');
    expect(info.subtitleKind, LineageSubtitleKind.sonOf);
    expect(info.subtitleText, 'HODAN MIRE SHEEKH YONIS');
    expect(
      buildFullMemberName(byId[amiinId]!, byId),
      'AMIIN HODAN MIRE SHEEKH YONIS',
    );
  });

  test('son branch member shows own name with son-of subtitle', () {
    const sonId = 'ahmed';
    final byId = {
      patriarchId: _p(patriarchId, 'SHEEKH YONIS'),
      sonId: _p(sonId, 'AHMED YOONIS', fatherId: patriarchId),
    };

    final info = buildLineageDisplayInfo(byId[sonId]!, byId);

    expect(info.displayName, 'AHMED YOONIS');
    expect(info.subtitleKind, LineageSubtitleKind.sonOf);
    expect(info.subtitleText, 'SHEEKH YONIS');
  });

  test('patriarch has no subtitle', () {
    final byId = {patriarchId: _p(patriarchId, 'SHEEKH YONIS')};
    final info = buildLineageDisplayInfo(byId[patriarchId]!, byId);

    expect(info.displayName, 'SHEEKH YONIS');
    expect(info.subtitleKind, isNull);
    expect(info.subtitleText, isNull);
  });
}
