import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  static const _usernameKey = 'user_username';
  static const _passwordKey = 'user_password';

  static Future<void> saveCredentials({
    required String username,
    required String password,
  }) async {
    await _storage.write(key: _usernameKey, value: username);
    await _storage.write(key: _passwordKey, value: password);
  }

  static Future<String?> getUsername() async {
    return await _storage.read(key: _usernameKey);
  }

  static Future<String?> getPassword() async {
    return await _storage.read(key: _passwordKey);
  }

  static Future<bool> hasCredentials() async {
    final username = await getUsername();
    final password = await getPassword();
    return username != null && password != null;
  }

  static Future<void> clearCredentials() async {
    await _storage.delete(key: _usernameKey);
    await _storage.delete(key: _passwordKey);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
