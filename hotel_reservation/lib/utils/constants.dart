import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Hotel Reservation';
  static const String appVersion = '1.0.0';

  // Colors
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF1976D2);
  static const Color accentColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFE53935);
  static const Color successColor = Color(0xFF43A047);
  static const Color warningColor = Color(0xFFFFA726);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);

  // Reservation Status
  static const String statusPending = 'pending';
  static const String statusConfirmed = 'confirmed';
  static const String statusCheckedIn = 'checked_in';
  static const String statusCheckedOut = 'checked_out';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';

  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleCustomer = 'customer';

  // Notification Types
  static const String notificationReservation = 'reservation';
  static const String notificationPayment = 'payment';
  static const String notificationPromo = 'promo';
  static const String notificationSystem = 'system';

  // Date Formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd MMM yyyy, HH:mm';

  // Sizes
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;

  // API Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration apiCacheTimeout = Duration(minutes: 5);

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minNameLength = 2;
  static const int maxNameLength = 100;

  // Status Colors
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case statusPending:
        return warningColor;
      case statusConfirmed:
        return primaryColor;
      case statusCheckedIn:
        return successColor;
      case statusCheckedOut:
      case statusCompleted:
        return Colors.grey;
      case statusCancelled:
        return errorColor;
      default:
        return textSecondaryColor;
    }
  }

  // Status Labels
  static String getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case statusPending:
        return 'Menunggu Konfirmasi';
      case statusConfirmed:
        return 'Dikonfirmasi';
      case statusCheckedIn:
        return 'Check-in';
      case statusCheckedOut:
        return 'Check-out';
      case statusCompleted:
        return 'Selesai';
      case statusCancelled:
        return 'Dibatalkan';
      default:
        return status;
    }
  }
}