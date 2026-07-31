import 'package:flutter_test/flutter_test.dart';

import 'package:reer_sh_yoonis/models/lineage_tree.dart';
import 'package:reer_sh_yoonis/models/models.dart';

Profile _p(String id, String name, {String? fatherId}) => Profile(
      id: id,
      fullName: name,
      role: UserRole.familyMember,
      demographic: Demographic.adult,
      careRating: 2,
      fatherId: fatherId,
    );

void main() {
  test('buildLineageTree connects all profiles under Cilmi root', () {
    final profiles = [
      _p('cilmi', 'CILMI'),
      _p('ahmed', 'AHMED', fatherId: 'cilmi'),
      _p('sheekh', 'SHEEKH YONIS', fatherId: 'ahmed'),
      _p('aadan', 'AADAN', fatherId: 'ahmed'),
      _p('son', 'CABDIQADIR', fatherId: 'sheekh'),
      _p('gc', 'MOHAMED', fatherId: 'son'),
    ];

    final tree = buildLineageTree(profiles);
    expect(tree, isNotNull);
    expect(tree!.profile.id, 'cilmi');
    expect(countTreeMembers(tree), 6);
  });

  test('buildLineageTree still supports legacy Sheekh root', () {
    final profiles = [
      _p('root', 'SHEEKH YONIS'),
      _p('son', 'CABDIQADIR', fatherId: 'root'),
      _p('gc', 'MOHAMED', fatherId: 'son'),
    ];

    final tree = buildLineageTree(profiles);
    expect(tree, isNotNull);
    expect(countTreeMembers(tree), 3);
  });

  test('orphan profiles are excluded from tree count', () {
    final profiles = [
      _p('root', 'SHEEKH YONIS'),
      _p('son', 'CABDIQADIR', fatherId: 'root'),
      _p('orphan', 'EXTRA PERSON'),
    ];

    final tree = buildLineageTree(profiles);
    expect(tree, isNotNull);
    expect(countTreeMembers(tree), 2);
    expect(profiles.length, 3);
  });
}
