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

  /// Create new room (Admin only)
  Future<Room?> createRoom({
    required int categoryId,
    required String roomNumber,
    int? floor,
    String status = 'available',
    String? description,
    double? sizeSqm,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.adminRooms,
        data: {
          'category_id': categoryId,
          'room_number': roomNumber,
          if (floor != null) 'floor': floor,
          'status': status,
          if (description != null) 'description': description,
          if (sizeSqm != null) 'size_sqm': sizeSqm,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Room.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to create room: $e');
    }
  }

  /// Update existing room (Admin only)
  Future<Room?> updateRoom({
    required int roomId,
    required int categoryId,
    required String roomNumber,
    int? floor,
    required String status,
    String? description,
    double? sizeSqm,
  }) async {
    try {
      final response = await _apiService.put(
        '${ApiConfig.adminRooms}/$roomId',
        data: {
          'category_id': categoryId,
          'room_number': roomNumber,
          if (floor != null) 'floor': floor,
          'status': status,
          if (description != null) 'description': description,
          if (sizeSqm != null) 'size_sqm': sizeSqm,
        },
      );

      if (response.statusCode == 200) {
        return Room.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to update room: $e');
    }
  }

  /// Delete room (Admin only)
  Future<bool> deleteRoom(int roomId) async {
    try {
      final response = await _apiService.delete(
        '${ApiConfig.adminRooms}/$roomId',
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to delete room: $e');
    }
  }

  /// Update room status (Admin only)
  Future<bool> updateRoomStatus(int roomId, String status) async {
    try {
      final response = await _apiService.put(
        '${ApiConfig.adminRooms}/$roomId/status',
        data: {'status': status},
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to update room status: $e');
    }
  }

  /// Create new room category (Admin only)
  Future<RoomCategory?> createCategory({
    required String name,
    String? description,
    required double basePrice,
    required int maxGuests,
    List<String>? amenities,
    String? imageUrl,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.adminCategories,
        data: {
          'name': name,
          if (description != null) 'description': description,
          'base_price': basePrice,
          'max_guests': maxGuests,
          if (amenities != null) 'amenities': amenities,
          if (imageUrl != null) 'image_url': imageUrl,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return RoomCategory.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  /// Update room category (Admin only)
  Future<RoomCategory?> updateCategory({
    required int categoryId,
    required String name,
    String? description,
    required double basePrice,
    required int maxGuests,
    List<String>? amenities,
    String? imageUrl,
  }) async {
    try {
      final response = await _apiService.put(
        '${ApiConfig.adminCategories}/$categoryId',
        data: {
          'name': name,
          if (description != null) 'description': description,
          'base_price': basePrice,
          'max_guests': maxGuests,
          if (amenities != null) 'amenities': amenities,
          if (imageUrl != null) 'image_url': imageUrl,
        },
      );

      if (response.statusCode == 200) {
        return RoomCategory.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  /// Delete room category (Admin only)
  Future<bool> deleteCategory(int categoryId) async {
    try {
      final response = await _apiService.delete(
        '${ApiConfig.adminCategories}/$categoryId',
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }
}