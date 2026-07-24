import 'package:flutter_test/flutter_test.dart';
import 'package:reer_sh_yoonis/theme/app_theme.dart';

void main() {
  test('normalize maps legacy 4–5 to level 3', () {
    expect(CareRatingTheme.normalize(1), 1);
    expect(CareRatingTheme.normalize(2), 2);
    expect(CareRatingTheme.normalize(3), 3);
    expect(CareRatingTheme.normalize(4), 3);
    expect(CareRatingTheme.normalize(5), 3);
  });

  test('only three selectable values', () {
    expect(CareRatingTheme.values, [1, 2, 3]);
  });

  test('urgent is level 3 only', () {
    expect(CareRatingTheme.isUrgent(2), isFalse);
    expect(CareRatingTheme.isUrgent(3), isTrue);
    expect(CareRatingTheme.isUrgent(5), isTrue);
  });
}
