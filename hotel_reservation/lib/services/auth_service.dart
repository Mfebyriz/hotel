import 'package:hotel_reservation/models/user.dart';
import 'package:hotel_reservation/services/api_service.dart';
import 'package:hotel_reservation/services/storage_service.dart';
import 'package:hotel_reservation/config/api_config.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        ApiConfig.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['token'];
        final user = User.fromJson(data['user']);

        await _storageService.saveToken(token);
        await _storageService.saveUser(user);

        return {
          'success': true,
          'user': user,
          'token': token,
        };
      }

      return {
        'success': false,
        'message': 'Login failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.register,
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'password_confirmation': password,
        },
      );

      if (response.statusCode == 201) {
        final data = response.data;
        final token = data['token'];
        final user = User.fromJson(data['user']);

        await _storageService.saveToken(token);
        await _storageService.saveUser(user);

        return {
          'success': true,
          'user': user,
          'token': token,
        };
      }

      return {
        'success': false,
        'message': 'Registration failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.post(ApiConfig.logout);
    } catch (e) {
      // Ignore error
    }
    await _storageService.clearAll();
  }

  Future<User?> getCurrentUser() async {
    try {
      final response = await _apiService.get(ApiConfig.me);
      if (response.statusCode == 200) {
        final user = User.fromJson(response.data['user']);
        await _storageService.saveUser(user);
        return user;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final token = await _storageService.getToken();
    return token != null;
  }
}