import 'package:hotel_reservation/models/user.dart';
import 'package:hotel_reservation/models/room.dart';
import 'package:hotel_reservation/models/notification.dart';

class Reservation {
  final int id;
  final String bookingCode;
  final int userId;
  final int roomId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int numGuests;
  final int totalNights;
  final double pricePerNight;
  final double totalPrice;
  final String status;  // confirmed, checked_in, checked_out, cancelled (no pending)
  final String? specialRequests;
  final DateTime? checkedInAt;
  final DateTime? checkedOutAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final User? user;
  final Room? room;
  final DateTime createdAt;

  Reservation({
    required this.id,
    required this.bookingCode,
    required this.userId,
    required this.roomId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numGuests,
    required this.totalNights,
    required this.pricePerNight,
    required this.totalPrice,
    required this.status,
    this.specialRequests,
    this.checkedInAt,
    this.checkedOutAt,
    this.cancelledAt,
    this.cancellationReason,
    this.user,
    this.room,
    required this.createdAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      bookingCode: json['booking_code'],
      userId: json['user_id'],
      roomId: json['room_id'],
      checkInDate: DateTime.parse(json['check_in_date']),
      checkOutDate: DateTime.parse(json['check_out_date']),
      numGuests: json['num_guests'],
      totalNights: json['total_nights'],
      pricePerNight: double.parse(json['price_per_night'].toString()),
      totalPrice: double.parse(json['total_price'].toString()),
      status: json['status'],
      specialRequests: json['special_requests'],
      checkedInAt: json['checked_in_at'] != null
          ? DateTime.parse(json['checked_in_at'])
          : null,
      checkedOutAt: json['checked_out_at'] != null
          ? DateTime.parse(json['checked_out_at'])
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'])
          : null,
      cancellationReason: json['cancellation_reason'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      room: json['room'] != null ? Room.fromJson(json['room']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  bool get isConfirmed => status == 'confirmed';
  bool get isCheckedIn => status == 'checked_in';
  bool get isCheckedOut => status == 'checked_out';
  bool get isCancelled => status == 'cancelled';

  bool get canCheckIn => isConfirmed && checkInDate.isSameDay(DateTime.now());
  bool get canCheckOut => isCheckedIn;
  bool get canCancel => isConfirmed;

  String get statusText {
    switch (status) {
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'checked_in':
        return 'Sedang Menginap';
      case 'checked_out':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return 'Unknown';
    }
  }
}