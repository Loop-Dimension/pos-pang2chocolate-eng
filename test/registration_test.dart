import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Sign Up / Registration Validation Tests', () {
    test('Business registration number format and validation', () {
      // Valid raw: 10 digits
      const validRaw = '1234567890';
      final clean = validRaw.replaceAll(RegExp(r'[^0-9]'), '');
      expect(clean.length, equals(10));
      final formatted = '${clean.substring(0, 3)}-${clean.substring(3, 5)}-${clean.substring(5)}';
      expect(formatted, equals('123-45-67890'));

      // Invalid: 8 digits
      const invalidRaw = '12345678';
      expect(invalidRaw.replaceAll(RegExp(r'[^0-9]'), '').length, isNot(equals(10)));
    });

    test('Phone number validation', () {
      const validPhone = '01012345678';
      final clean = validPhone.replaceAll(RegExp(r'[^0-9]'), '');
      expect(clean.length >= 10, isTrue);

      const invalidPhone = '010';
      expect(invalidPhone.replaceAll(RegExp(r'[^0-9]'), '').length >= 10, isFalse);
    });

    test('Email format regex validation', () {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

      expect(emailRegex.hasMatch('test_merchant@pangi.com'), isTrue);
      expect(emailRegex.hasMatch('cafe.gangnam@domain.co.kr'), isTrue);
      expect(emailRegex.hasMatch('invalid-email'), isFalse);
      expect(emailRegex.hasMatch('test@'), isFalse);
      expect(emailRegex.hasMatch('@pangi.com'), isFalse);
    });

    test('Password requirements (alphanumeric, 8+ characters)', () {
      final passRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$');

      expect(passRegex.hasMatch('Password123!'), isTrue);
      expect(passRegex.hasMatch('pass1234'), isTrue);
      expect(passRegex.hasMatch('short1'), isFalse); // < 8 chars
      expect(passRegex.hasMatch('onlyletters'), isFalse); // no digit
      expect(passRegex.hasMatch('12345678'), isFalse); // no letter
    });

    test('Merchant Registration Mock Payload Structure', () {
      final mockData = {
        'storeLink': 'https://map.naver.com/v5/entry/place/12345678',
        'exclusionItems': '두바이초콜릿, 피스타치오 케이크',
        'discountRate': '3% ~',
        'businessRegistrationNumber': '123-45-67890',
        'companyName': '(주)팽이카페 강남점',
        'representativeName': '홍길동',
        'businessAddress': '서울특별시 강남구 테헤란로 123',
        'phone': '010-1234-5678',
        'email': 'mock_merchant_test@pangi.com',
        'settlementAccount': '110-123-456789 (신한은행)',
        'storeName': '팽이카페 강남본점',
        'storePhone': '02-1234-5678',
        'status': 'pending',
        'howDidYouHear': '인스타그램 제휴 추천',
      };

      expect(mockData['status'], equals('pending'));
      expect(mockData['email'], contains('@'));
      expect(mockData['businessRegistrationNumber'], equals('123-45-67890'));
      expect(mockData['discountRate'], equals('3% ~'));
    });
  });
}
