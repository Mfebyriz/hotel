import 'package:hotel_reservation/models/room.dart';
import 'package:hotel_reservation/models/room_category.dart';
import 'package:hotel_reservation/services/api_service.dart';
import 'package:hotel_reservation/config/api_config.dart';

class RoomService {
  final ApiService _apiService = ApiService();

  Future<List<Room>> getRooms({String? categoryId, String? search}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (categoryId != null) queryParams['category_id'] = categoryId;
      if (search != null) queryParams['search'] = search;

      final response = await _apiService.get(
        ApiConfig.rooms,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Room.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load rooms: $e');
    }
  }

  Future<Room?> getRoomDetail(int roomId) async {
    try {
      final response = await _apiService.get('${ApiConfig.rooms}/$roomId');
      if (response.statusCode == 200) {
        return Room.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load room detail: $e');
    }
  }

  Future<List<RoomCategory>> getCategories() async {
    try {
      final response = await _apiService.get(ApiConfig.roomCategories);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => RoomCategory.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  Future<List<Room>> checkAvailability({
    required DateTime checkIn,
    required DateTime checkOut,
    int? categoryId,
  }) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.rooms}/available',
        queryParameters: {
          'check_in': checkIn.toIso8601String(),
          'check_out': checkOut.toIso8601String(),
          if (categoryId != null) 'category_id': categoryId,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Room.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to check availability: $e');
    }
  }
}