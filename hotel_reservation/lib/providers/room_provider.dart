import 'package:flutter/foundation.dart';
import '../models/room.dart';
import '../models/room_category.dart';
import '../services/room_service.dart';

class RoomProvider with ChangeNotifier {
  final RoomService _roomService = RoomService();

  List<Room> _rooms = [];
  List<RoomCategory> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Room> get rooms => _rooms;
  List<RoomCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Room> get availableRooms => _rooms.where((r) => r.isAvailable).toList();

  Future<void> fetchRooms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _rooms = await _roomService.getRooms();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _roomService.getCategories();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Room?> fetchRoomById(int id) async {
    try {
      return await _roomService.getRoomById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  List<Room> getRoomsByCategory(int categoryId) {
    return _rooms.where((room) => room.categoryId == categoryId).toList();
  }

  Future<bool> createRoom(Room room) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _roomService.createRoom(room);
      await fetchRooms();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateRoom(Room room) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _roomService.updateRoom(room);
      await fetchRooms();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteRoom(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _roomService.deleteRoom(id);
      await fetchRooms();
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