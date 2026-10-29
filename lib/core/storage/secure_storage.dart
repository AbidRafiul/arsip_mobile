import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // In-memory fallback
  static final Map<String, String> _memCache = {};

  static const String _keyAccessToken = 'access_token';
  static const String _keyJwtCredential = 'jwt_credential';
  static const String _keyUserId = 'user_id';
  static const String _keyUsername = 'username';
  static const String _keyFullName = 'full_name';
  static const String _keyRole = 'role';
  static const String _keyBranchId = 'branch_id';

  // Access Token
  static Future<void> saveAccessToken(String token) async {
    _memCache[_keyAccessToken] = token;
    try {
      await _storage.write(key: _keyAccessToken, value: token);
    } catch (e) {
      debugPrint("SecureStorage write error: $e");
    }
  }

  static Future<String?> getAccessToken() async {
    if (_memCache.containsKey(_keyAccessToken)) {
      return _memCache[_keyAccessToken];
    }
    try {
      final val = await _storage.read(key: _keyAccessToken);
      if (val != null) _memCache[_keyAccessToken] = val;
      return val;
    } catch (e) {
      debugPrint("SecureStorage read error: $e");
      return _memCache[_keyAccessToken];
    }
  }

  // JWT Credential
  static Future<void> saveJwtCredential(String credential) async {
    _memCache[_keyJwtCredential] = credential;
    try {
      await _storage.write(key: _keyJwtCredential, value: credential);
    } catch (e) {
      debugPrint("SecureStorage write error: $e");
    }
  }

  static Future<String?> getJwtCredential() async {
    if (_memCache.containsKey(_keyJwtCredential)) {
      return _memCache[_keyJwtCredential];
    }
    try {
      final val = await _storage.read(key: _keyJwtCredential);
      if (val != null) _memCache[_keyJwtCredential] = val;
      return val;
    } catch (e) {
      debugPrint("SecureStorage read error: $e");
      return _memCache[_keyJwtCredential];
    }
  }

  // User Metadata
  static Future<void> saveUserData({
    required int userId,
    required String username,
    required String fullName,
    required String role,
    int? branchId,
  }) async {
    _memCache[_keyUserId] = userId.toString();
    _memCache[_keyUsername] = username;
    _memCache[_keyFullName] = fullName;
    _memCache[_keyRole] = role;
    if (branchId != null) {
      _memCache[_keyBranchId] = branchId.toString();
    }

    try {
      await _storage.write(key: _keyUserId, value: userId.toString());
      await _storage.write(key: _keyUsername, value: username);
      await _storage.write(key: _keyFullName, value: fullName);
      await _storage.write(key: _keyRole, value: role);
      if (branchId != null) {
        await _storage.write(key: _keyBranchId, value: branchId.toString());
      }
    } catch (e) {
      debugPrint("SecureStorage user data save error: $e");
    }
  }

  static Future<Map<String, String?>> getUserData() async {
    try {
      final uId = await _storage.read(key: _keyUserId) ?? _memCache[_keyUserId];
      final uName =
          await _storage.read(key: _keyUsername) ?? _memCache[_keyUsername];
      final fName =
          await _storage.read(key: _keyFullName) ?? _memCache[_keyFullName];
      final rName = await _storage.read(key: _keyRole) ?? _memCache[_keyRole];
      final bId =
          await _storage.read(key: _keyBranchId) ?? _memCache[_keyBranchId];

      return {
        'userId': uId,
        'username': uName,
        'fullName': fName,
        'role': rName,
        'branchId': bId,
      };
    } catch (e) {
      return {
        'userId': _memCache[_keyUserId],
        'username': _memCache[_keyUsername],
        'fullName': _memCache[_keyFullName],
        'role': _memCache[_keyRole],
        'branchId': _memCache[_keyBranchId],
      };
    }
  }

  static Future<void> clearAll() async {
    _memCache.clear();
    try {
      await _storage.deleteAll();
    } catch (e) {
      debugPrint("SecureStorage clear error: $e");
    }
  }

  // Generic Settings (e.g. Notifications)
  static Future<void> saveSetting(String key, String value) async {
    _memCache[key] = value;
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      debugPrint("SecureStorage write setting error: $e");
    }
  }

  static Future<String?> getSetting(String key) async {
    if (_memCache.containsKey(key)) {
      return _memCache[key];
    }
    try {
      final val = await _storage.read(key: key);
      if (val != null) _memCache[key] = val;
      return val;
    } catch (e) {
      debugPrint("SecureStorage read setting error: $e");
      return _memCache[key];
    }
  }
}
