import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hotel_reservation/models/user.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  Future<void> saveUser(User user) async {
    await _prefs?.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<User?> getUser() async {
    final userJson = _prefs?.getString(_userKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<void> deleteUser() async {
    await _prefs?.remove(_userKey);
  }

  Future<void> clearAll() async {
    await deleteToken();
    await deleteUser();
    await _prefs?.clear();
  }
}