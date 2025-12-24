class AppConfig {
  // App Information
  static const String appName = 'Hotel Reservation';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Sistem Reservasi Hotel';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';

  // Date & Time Formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd MMM yyyy, HH:mm';
  static const String apiDateFormat = 'yyyy-MM-dd';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Image Upload
  static const int maxImageSizeMB = 2;
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png'];

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minNameLength = 2;
  static const int maxNameLength = 100;

  // Cache Duration
  static const Duration cacheDuration = Duration(minutes: 5);
  static const Duration tokenRefreshInterval = Duration(hours: 1);

  // Features
  static const bool enableNotifications = true;
  static const bool enableDarkMode = false;
  static const bool enableBiometric = false;
}