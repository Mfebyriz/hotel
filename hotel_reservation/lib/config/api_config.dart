class ApiConfig {
  // Base URL - GANTI DENGAN URL SERVER KAMU
  static const String baseUrl = 'http://10.0.2.2:8000/api'; // Android Emulator
  // static const String baseUrl = 'http://127.0.0.1:8000/api'; // iOS Simulator
  // static const String baseUrl = 'http://192.168.1.100:8000/api'; // Real Device (ganti dengan IP komputer kamu)
  // static const String baseUrl = 'https://yourserver.com/api'; // Production

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Room Endpoints
  static const String rooms = '/rooms';
  static const String roomCategories = '/room-categories';

  // Customer Reservation Endpoints
  static const String customerReservations = '/customer/reservations';

  // Notification Endpoints
  static const String notifications = '/notifications';
  static const String unreadNotifications = '/notifications/unread-count';

  // Admin Endpoints
  static const String adminDashboard = '/admin/dashboard';
  static const String adminCustomers = '/admin/customers';
  static const String adminRooms = '/admin/rooms';
  static const String adminCategories = '/admin/room-categories';
  static const String adminReservations = '/admin/reservations';
  static const String adminReports = '/admin/reports';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}