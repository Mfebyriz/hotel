import 'package:hotel_reservation/config/constants.dart';
import 'package:hotel_reservation/models/reservation.dart';
import 'api_service.dart';

class ReservationService {
  // Get Reservation
  static Future<List<Reservation>> getReservations({String? status}) async {
    String endpoint = AppConstants.RESERVATIONS;

    if (status != null) {
      endpoint += '?status=$status';
    }

    final response = await ApiService.get(endpoint);

    if (response['success']) {
      final List<dynamic> data = response['data']['data'];
      return data.map((json) => Reservation.fromJson(json)).toList();
    }

    return [];
  }

  // Get reservation by ID
  static Future<Reservation?> getReservationById(int id) async {
    final response = await ApiService.get('${AppConstants.RESERVATIONS}/$id');

    if (response['success']) {
      return Reservation.fromJson(response['data']);
    }

    return null;
  }

  // Create reservation
  static Future<Reservation> createReservation({
    required int roomId,
    required String checkInDate,
    required String checkOutData,
    String? notes,
  }) async {
    final response = await ApiService.post(
      AppConstants.RESERVATIONS,
      body: {
        'room': roomId,
        'check_in_date': checkInDate,
        'check_out_date': checkOutData,
        'notes': notes,
      },
    );

    if (response['success']) {
      return Reservation.fromJson(response['data']);
    }

    throw Exception(response['message'] ?? 'Failed to create reservation');
  }

  // CheckIn (Admin)
  static Future<Reservation> checkIn(int reservationId) async {
    final response = await ApiService.post(
      '${AppConstants.RESERVATIONS}/$reservationId/check-in',
    );

    if (response['success']) {
      return Reservation.fromJson(response['data']);
    }

    throw Exception(response['mesaage'] ?? 'Failed to check-in');
  }

  // CheckOut (Admin)
  static Future<Reservation> checkOut(int reservationId) async {
    final response = await ApiService.post(
      '${AppConstants.RESERVATIONS}/$reservationId/check-out',
    );

    if (response['success']) {
      return Reservation.fromJson(response['data']);
    }

    throw Exception(response['message'] ?? 'Failed to check-out');
  }

  // Cancel reservation
  static Future<void> cancelReservation(int reservationId) async {
    final response = await ApiService.put(
      '${AppConstants.RESERVATIONS}/$reservationId/cancel',
    );

    if (!response['success']) {
      throw Exception(response['message'] ?? 'Failed to cancel reservation');
    }
  }
}
