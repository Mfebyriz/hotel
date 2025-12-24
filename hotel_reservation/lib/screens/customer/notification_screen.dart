import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/notification.dart';
import '../../services/notification.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<AppNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);

    try {
      final notifications = await NotificationService.getNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(AppNotification notification) async {
    try {
      await NotificationService.markAsRead(notification.id);
      _loadNotifications();
    } catch(e) {
      // Ignore error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          if (_notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: () async {
                await NotificationService.markAllAsRead();
                _loadNotifications();
              },
              child: const Text('Tandai Semua Dibaca'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _notifications.isEmpty
                ? const Center(child: Text('Tidak ada notifikasi'))
                : ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return _buildNotificationItem(notification);
                    },
                ),
      ),
    );
  }

  Widget _buildNotificationItem(AppNotification notification) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: notification.isRead ? Colors.white : Colors.blue.shade50,
      child: ListTile(
        leading: Icon(
          _getNotificationIcon(notification.type),
          color: _getNotificationColor(notification.type),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.message),
            const SizedBox(height: 4),
            Text(
              notification.createdAt != null
                  ? DateFormat('dd MMM yyyy, HH:mm').format(
                      DateTime.parse(notification.createdAt!),
                    )
                  : '',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        onTap: () {
          if (!notification.isRead) {
            _markAsRead(notification);
          }
        },
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch(type) {
      case 'reminder':
        return Icons.access_time;
      case 'warning':
        return Icons.warning;
      default:
        return Icons.info;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'reminder':
        return Colors.blue;
      case 'warning':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }
}