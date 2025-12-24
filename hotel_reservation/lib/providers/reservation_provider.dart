import 'package:flutter/foundation.dart';
import '../models/reservation.dart';
import '../services/reservation_service.dart';

class ReservationProvider with ChangeNotifier {
  final ReservationService _reservationService = ReservationService();

  List<Reservation> _reservations = [];
  bool _isLoading = false;
  String? _error;

  List<Reservation> get reservations => _reservations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Reservation> get activeReservations => _reservations
      .where((r) => r.status == 'confirmed' || r.status == 'checked_in')
      .toList();

  List<Reservation> get pendingReservations =>
      _reservations.where((r) => r.status == 'pending').toList();

  List<Reservation> get completedReservations =>
      _reservations.where((r) => r.status == 'completed').toList();

  Future<void> fetchMyReservations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reservations = await _reservationService.getMyReservations();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllReservations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reservations = await _reservationService.getAllReservations();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Reservation?> fetchReservationById(int id) async {
    try {
      return await _reservationService.getReservationById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<Reservation?> createReservation({
    required int roomId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int totalGuests,
    String? specialRequests,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final reservation = await _reservationService.createReservation(
        roomId: roomId,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        numGuests: totalGuests,
        specialRequests: specialRequests,
      );

      if (reservation != null) {
        await fetchMyReservations();
      }

      _isLoading = false;
      notifyListeners();
      return reservation;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateReservationStatus(int id, String status) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _reservationService.updateReservationStatus(id, status);
      await fetchAllReservations();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelReservation(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _reservationService.cancelReservation(id);
      await fetchMyReservations();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}