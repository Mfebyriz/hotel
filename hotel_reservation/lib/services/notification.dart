import 'package:hotel_reservation/config/constants.dart';
import 'package:hotel_reservation/models/notification.dart';
import 'api_service.dart';

class NotificationService {
  // Get notifications
  static Future<List<AppNotification>> getNotifications() async {
    final response = await ApiService.get(AppConstants.NOTIFICATIONS);

    if (response['success']) {
      final List<dynamic> data = response['data']['data'];
      return data.map((json) => AppNotification.fromJson(json)).toList();
    }

    return [];
  }

  // Mark as read
  static Future<void> markAsRead(int notificationId) async {
    await ApiService.put('${AppConstants.NOTIFICATIONS}/$notificationId/read');
  }

  // Mark all as read
  static Future<void> markAllAsRead() async {
    await ApiService.post('${AppConstants.NOTIFICATIONS}/read-all');
  }
}
