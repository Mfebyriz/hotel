import 'package:hotel_reservation/models/reservation.dart';
import 'package:hotel_reservation/services/api_service.dart';
import 'package:hotel_reservation/config/api_config.dart';

class ReservationService {
  final ApiService _apiService = ApiService();

  /// Create reservation - AUTO CONFIRMED (NO PAYMENT)
  Future<Reservation?> createReservation({
    required int roomId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int numGuests,
    String? specialRequests,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.customerReservations,
        data: {
          'room_id': roomId,
          'check_in_date': checkInDate.toIso8601String().split('T')[0],
          'check_out_date': checkOutDate.toIso8601String().split('T')[0],
          'num_guests': numGuests,
          if (specialRequests != null) 'special_requests': specialRequests,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Reservation.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to create reservation: $e');
    }
  }

  Future<List<Reservation>> getMyReservations() async {
    try {
      final response = await _apiService.get(ApiConfig.customerReservations);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Reservation.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load reservations: $e');
    }
  }

  Future<Reservation?> getReservationDetail(int reservationId) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.customerReservations}/$reservationId',
      );

      if (response.statusCode == 200) {
        return Reservation.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load reservation: $e');
    }
  }

  Future<bool> cancelReservation(int reservationId, {String? reason}) async {
    try {
      final response = await _apiService.post(
        '${ApiConfig.customerReservations}/$reservationId/cancel',
        data: {
          if (reason != null) 'reason': reason,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkIn(int reservationId) async {
    try {
      final response = await _apiService.post(
        '${ApiConfig.customerReservations}/$reservationId/check-in',
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkOut(int reservationId) async {
    try {
      final response = await _apiService.post(
        '${ApiConfig.customerReservations}/$reservationId/check-out',
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}