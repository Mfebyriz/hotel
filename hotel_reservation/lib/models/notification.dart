class NotificationModel {
  final int id;
  final int userId;
  final String title;
  final String message;
  final String? type;
  final int? referenceId;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    this.type,
    this.referenceId,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      referenceId: json['reference_id'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'reference_id': referenceId,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
    };
  }

  // Get time ago string
  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);

    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()} minggu lalu';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }
}

extension DateTimeExtension on DateTime {
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}