import 'package:flutter_test/flutter_test.dart';
import 'package:reer_sh_yoonis/models/models.dart';
import 'package:reer_sh_yoonis/utils/profile_sort.dart';

void main() {
  test('compareProfilesByAge sorts by birth_order oldest first', () {
    final older = Profile(
      id: '1',
      fullName: 'MOHAMED',
      role: UserRole.familyMember,
      demographic: Demographic.adult,
      careRating: 2,
      birthOrder: 0,
    );
    final younger = Profile(
      id: '2',
      fullName: 'CISMAAN',
      role: UserRole.familyMember,
      demographic: Demographic.adult,
      careRating: 2,
      birthOrder: 2,
    );

    expect(compareProfilesByAge(older, younger), lessThan(0));
  });
}
