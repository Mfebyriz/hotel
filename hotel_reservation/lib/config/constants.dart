import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class AppConstants {
  static String get BASE_URL {
    if (kIsWeb) {
      // untuk Web
      return 'http://localhost:8000/api';
    } else if (Platform.isAndroid) {
      // Emulator
      return 'http://10.0.2.2:8000/api';
    } else if (Platform.isIOS) {
      // device fisik (ip HP)
      return 'http://localhost:8000/api';
    } else {
      // default
      return 'http://localhost:8000/api';
    }
  }

  // API endpoints
  static const String LOGIN = '/login';
  static const String REGISTER = '/register';
  static const String LOGOUT = '/logout';
  static const String ME = '/me';
  static const String ROOMS = '/rooms';
  static const String RESERVATIONS = '/reservations';
  static const String CUSTOMERS = '/customers';
  static const String PAYMENTS = '/payments';
  static const String NOTIFICATIONS = '/notifications';
  static const String REPORTS = '/reports';

  // Shared Preferences keys
  static const String TOKEN_KEY = 'auth_token';
  static const String USER_KEY = 'user_data';

  // API Settings
  static const int REQUEST_TIMEOUT = 30;
  static const int PRE_PAGE = 10;
}
