import 'dart:io';
import 'package:ampere/core/storage/hive_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  group('HiveClient', () {
    late HiveClient<String> hiveClient;
    late Directory testDirectory;
    const boxName = 'test_box';

    setUpAll(() {
      // Create a temporary directory for tests
      testDirectory = Directory.systemTemp.createTempSync('hive_test_');
      Hive.init(testDirectory.path);
    });

    setUp(() async {
      hiveClient = HiveClient<String>(boxName);
    });

    tearDown(() async {
      // Clean up: close and delete the box after each test
      try {
        await hiveClient.closeBox();
      } catch (_) {}

      try {
        if (Hive.isBoxOpen(boxName)) {
          await Hive.box<String>(boxName).close();
        }
      } catch (_) {}

      try {
        await Hive.deleteBoxFromDisk(boxName);
      } catch (_) {}
    });

    tearDownAll(() {
      // Delete the temporary directory
      try {
        testDirectory.deleteSync(recursive: true);
      } catch (_) {}
    });

    test('should initialize and open box', () async {
      await hiveClient.init();
      expect(Hive.isBoxOpen(boxName), true);
    });

    test('should put and get value from box', () async {
      const key = 'testKey';
      const value = 'testValue';

      await hiveClient.put(key, value);
      final result = await hiveClient.get(key);

      expect(result, value);
    });

    test('should return null for non-existent key', () async {
      final result = await hiveClient.get('nonExistentKey');

      expect(result, null);
    });

    test('should add all values to box', () async {
      final values = ['value1', 'value2', 'value3'];

      await hiveClient.addAll(values);
      final result = await hiveClient.getAll();

      expect(result, values);
    });

    test('should get all values from box', () async {
      await hiveClient.put('key1', 'value1');
      await hiveClient.put('key2', 'value2');

      final result = await hiveClient.getAll();

      expect(result.length, 2);
      expect(result.contains('value1'), true);
      expect(result.contains('value2'), true);
    });

    test('should delete value from box', () async {
      const key = 'testKey';
      const value = 'testValue';

      await hiveClient.put(key, value);
      await hiveClient.delete(key);
      final result = await hiveClient.get(key);

      expect(result, null);
    });

    test('should clear all values from box', () async {
      await hiveClient.put('key1', 'value1');
      await hiveClient.put('key2', 'value2');

      await hiveClient.clear();
      final result = await hiveClient.getAll();

      expect(result, isEmpty);
    });

    test('should check if key exists in box', () async {
      const key = 'testKey';
      const value = 'testValue';

      await hiveClient.put(key, value);

      final exists = await hiveClient.containsKey(key);
      final notExists = await hiveClient.containsKey('nonExistentKey');

      expect(exists, true);
      expect(notExists, false);
    });

    test('should close box', () async {
      await hiveClient.init();
      await hiveClient.closeBox();

      expect(Hive.isBoxOpen(boxName), false);
    });

    test('should handle multiple operations on same box', () async {
      await hiveClient.put('key1', 'value1');
      await hiveClient.put('key2', 'value2');

      final value1 = await hiveClient.get('key1');
      expect(value1, 'value1');

      await hiveClient.delete('key1');
      final deletedValue = await hiveClient.get('key1');
      expect(deletedValue, null);

      final value2 = await hiveClient.get('key2');
      expect(value2, 'value2');
    });
  });
}
