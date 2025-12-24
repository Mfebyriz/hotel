import 'package:hotel_reservation/models/notification.dart';
import 'package:hotel_reservation/services/api_service.dart';
import 'package:hotel_reservation/config/api_config.dart';

class NotificationService {
  final ApiService _apiService = ApiService();

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _apiService.get(ApiConfig.notifications);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load notifications: $e');
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _apiService.get(ApiConfig.unreadNotifications);

      if (response.statusCode == 200) {
        return response.data['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<bool> markAsRead(int notificationId) async {
    try {
      final response = await _apiService.post(
        '${ApiConfig.notifications}/$notificationId/read',
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      final response = await _apiService.post(
        '${ApiConfig.notifications}/read-all',
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteNotification(int notificationId) async {
    try {
      final response = await _apiService.delete(
        '${ApiConfig.notifications}/$notificationId',
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}