import 'package:ampere/core/storage/secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  group('SecureStorage', () {
    late SecureStorage secureStorage;
    const testKey = 'test_key';

    setUp(() {
      secureStorage = SecureStorage(key: testKey);
    });

    test('should have correct key', () {
      expect(secureStorage.key, testKey);
    });

    test('should create instance with FlutterSecureStorage', () {
      expect(secureStorage.secureStorage, isA<FlutterSecureStorage>());
    });
  });
}
