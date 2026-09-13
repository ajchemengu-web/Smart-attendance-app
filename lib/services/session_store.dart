import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/login_result.dart';

/// Persists the logged-in session in the platform keystore/keychain
/// (never plain SharedPreferences — this is the same access_token
/// the web platform keeps server-only in an encrypted cookie;
/// on-device secure storage is this app's equivalent).
class SessionStore {
  static const _storage = FlutterSecureStorage();

  static const _tokenKey = 'access_token';
  static const _usernameKey = 'username';
  static const _roleKey = 'role';
  static const _dashboardKey = 'dashboard';

  Future<void> save(LoginResult result) async {
    await _storage.write(key: _tokenKey, value: result.accessToken);
    await _storage.write(key: _usernameKey, value: result.username);
    await _storage.write(key: _roleKey, value: result.role);
    await _storage.write(key: _dashboardKey, value: result.dashboard);
  }

  Future<String?> get token => _storage.read(key: _tokenKey);
  Future<String?> get username => _storage.read(key: _usernameKey);
  Future<String?> get role => _storage.read(key: _roleKey);
  Future<String?> get dashboard => _storage.read(key: _dashboardKey);

  Future<void> clear() async {
    await _storage.deleteAll();
  }
}
