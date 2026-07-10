import 'package:flutter_test/flutter_test.dart';
import 'package:reer_sh_yoonis/utils/phone_utils.dart';

void main() {
  group('normalizePhoneDigits', () {
    test('strips non-digits and adds 252 for local 0-prefix', () {
      expect(normalizePhoneDigits('0634448591'), '252634448591');
    });

    test('keeps existing 252 prefix', () {
      expect(normalizePhoneDigits('252634448591'), '252634448591');
    });

    test('removes duplicated 252 country code', () {
      expect(normalizePhoneDigits('252252634448591'), '252634448591');
    });
  });

  group('normalizePhone', () {
    test('returns E.164-style value', () {
      expect(normalizePhone('0634448591'), '+252634448591');
    });
  });

  group('isValidSomaliaMobile', () {
    test('accepts local and international formats', () {
      expect(isValidSomaliaMobile('0634448591'), isTrue);
      expect(isValidSomaliaMobile('252634448591'), isTrue);
    });

    test('rejects too-short numbers', () {
      expect(isValidSomaliaMobile('06344'), isFalse);
    });
  });

  group('auth emails', () {
    test('signup uses hotmail domain with rsy prefix', () {
      expect(
        phoneToAuthEmail('+252634448591'),
        'rsy.252634448591@hotmail.com',
      );
    });

    test('sign-in tries current then legacy formats', () {
      expect(
        authEmailsForPhone('+252634448591'),
        [
          'rsy.252634448591@hotmail.com',
          'p252634448591@phone.reershyoonis.app',
          '252634448591@phone.reershyoonis.app',
        ],
      );
    });
  });
}
