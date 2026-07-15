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
  test('buildLineageTree connects all profiles under patriarch', () {
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
