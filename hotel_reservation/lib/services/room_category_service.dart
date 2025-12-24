import '../config/constants.dart';
import '../models/room_category.dart';
import 'api_service.dart';

class RoomCategoryService {
  // Get all categories
  static Future<List<RoomCategory>> getCategories() async {
    final responce = await ApiService.get(
      '/room-categories',
      requiresAuth: false,
    );

    if (responce['success']) {
      final List<dynamic> data = responce['data'];
      return data.map((json) => RoomCategory.fromJson(json)).toList();
    }

    return [];
  }

  // get category by ID
  static Future<RoomCategory?> getCategoriesById(int id) async {
    final response = await ApiService.get(
      '/room-categories/$id',
      requiresAuth: false,
    );

    if (response['success']) {
      return RoomCategory.fromJson(response['data']);
    }

    return null;
  }

  // Create category (Admin)
  static Future<RoomCategory> createCategory(
    Map<String, dynamic> categoryData,
  ) async {
    final response = await ApiService.post(
      '/room-categories',
      body: categoryData,
    );

    if (response['success']) {
      return RoomCategory.fromJson(response['data']);
    }

    throw Exception(response['message'] ?? 'Failed to create category');
  }

  // Update category (Admin)
  static Future<RoomCategory> updateCategory(
    int id,
    Map<String, dynamic> categoryData,
  ) async {
    final response = await ApiService.put(
      '/room-categories/$id',
      body: categoryData,
    );

    if (response['success']) {
      return RoomCategory.fromJson(response['data']);
    }

    throw Exception(response['message'] ?? 'Failed to update category');
  }

  // Delete category (Admin)
  static Future<void> deleteCategory(int id) async {
    final response = await ApiService.delete('/room-categories/$id');

    if (response['success']) {
      throw Exception(response['message'] ?? 'Failed to delete category');
    }
  }
}
