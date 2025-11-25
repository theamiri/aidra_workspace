import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final String key;
  SecureStorage({required this.key});

  /// The secure storage instance.
  /// @return The secure storage instance
  final secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  /// Save the value of the key
  /// @param value The value to save
  /// @return The value of the key
  Future<void> save({required dynamic value}) async => await secureStorage.write(key: key, value: value);

  /// Get the value of the key
  /// @return The value of the key
  Future<dynamic> get() async {
    final value = await secureStorage.read(key: key);
    return value;
  }

  /// Delete the value of the key
  /// @return The value of the key
  Future<void> delete() async => await secureStorage.delete(key: key);

  /// Clear all the values
  /// @return The value of the key
  Future<void> clear() async => await secureStorage.deleteAll();
}
