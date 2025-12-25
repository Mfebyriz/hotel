import 'constants.dart';

class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'Password minimal ${AppConstants.minPasswordLength} karakter';
    }

    if (value.length > AppConstants.maxPasswordLength) {
      return 'Password maksimal ${AppConstants.maxPasswordLength} karakter';
    }

    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama tidak boleh kosong';
    }

    if (value.length < AppConstants.minNameLength) {
      return 'Nama minimal ${AppConstants.minNameLength} karakter';
    }

    if (value.length > AppConstants.maxNameLength) {
      return 'Nama maksimal ${AppConstants.maxNameLength} karakter';
    }

    return null;
  }

  // Phone validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }

    final phoneRegex = RegExp(r'^[0-9+\-\s()]{10,15}$');

    if (!phoneRegex.hasMatch(value)) {
      return 'Format nomor telepon tidak valid';
    }

    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  // Number validation
  static String? validateNumber(String? value, {int? min, int? max}) {
    if (value == null || value.isEmpty) {
      return 'Angka tidak boleh kosong';
    }

    final number = int.tryParse(value);
    if (number == null) {
      return 'Harus berupa angka';
    }

    if (min != null && number < min) {
      return 'Minimal $min';
    }

    if (max != null && number > max) {
      return 'Maksimal $max';
    }

    return null;
  }

  // Date validation
  static String? validateDate(DateTime? date) {
    if (date == null) {
      return 'Tanggal tidak boleh kosong';
    }
    return null;
  }

  // Date range validation
  static String? validateDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null) {
      return 'Tanggal mulai tidak boleh kosong';
    }

    if (endDate == null) {
      return 'Tanggal selesai tidak boleh kosong';
    }

    if (endDate.isBefore(startDate)) {
      return 'Tanggal selesai harus setelah tanggal mulai';
    }

    return null;
  }

  // Price validation
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Harga tidak boleh kosong';
    }

    final price = double.tryParse(value);
    if (price == null) {
      return 'Harga harus berupa angka';
    }

    if (price < 0) {
      return 'Harga tidak boleh negatif';
    }

    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }

    if (password != confirmPassword) {
      return 'Password tidak sama';
    }

    return null;
  }
}