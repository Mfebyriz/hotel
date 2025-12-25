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

      print('Login Response Status: ${response.statusCode}');
      print('Login Response Data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        // Check if response has required fields
        if (data['token'] != null && data['user'] != null) {
          final token = data['token'] as String;
          final user = User.fromJson(data['user'] as Map<String, dynamic>);

          await _storageService.saveToken(token);
          await _storageService.saveUser(user);

          return {
            'success': true,
            'user': user,
            'token': token,
          };
        } else {
          return {
            'success': false,
            'message': 'Invalid response format from server',
          };
        }
      }

      return {
        'success': false,
        'message': response.data?['message'] ?? 'Login failed',
      };
    } catch (e) {
      print('Login Error: $e');
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
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

      print('Register Response Status: ${response.statusCode}');
      print('Register Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data != null) {
          final data = response.data;

          if (data['token'] != null && data['user'] != null) {
            final token = data['token'] as String;
            final user = User.fromJson(data['user'] as Map<String, dynamic>);

            await _storageService.saveToken(token);
            await _storageService.saveUser(user);

            return {
              'success': true,
              'user': user,
              'token': token,
            };
          }
        }
      }

      return {
        'success': false,
        'message': response.data?['message'] ?? 'Registration failed',
      };
    } catch (e) {
      print('Register Error: $e');
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.post(ApiConfig.logout);
    } catch (e) {
      print('Logout Error: $e');
    } finally {
      await _storageService.clearAll();
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final response = await _apiService.get(ApiConfig.me);

      print('Get User Response Status: ${response.statusCode}');
      print('Get User Response Data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final user = User.fromJson(response.data['user'] as Map<String, dynamic>);
        await _storageService.saveUser(user);
        return user;
      }
    } catch (e) {
      print('Get Current User Error: $e');
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final token = await _storageService.getToken();
    return token != null && token.isNotEmpty;
  }
}