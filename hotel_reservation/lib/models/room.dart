class Room {
  final int id;
  final int categoryId;
  final String roomNumber;
  final int? floor;
  final String status;
  final String? description;
  final double? sizeSqm;
  final RoomCategory? category;

  Room({
    required this.id,
    required this.categoryId,
    required this.roomNumber,
    this.floor,
    required this.status,
    this.description,
    this.sizeSqm,
    this.category,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      categoryId: json['category_id'],
      roomNumber: json['room_number'],
      floor: json['floor'],
      status: json['status'],
      description: json['description'],
      sizeSqm: json['size_sqm'] != null
          ? double.parse(json['size_sqm'].toString())
          : null,
      category: json['category'] != null
          ? RoomCategory.fromJson(json['category'])
          : null,
    );
  }

  bool get isAvailable => status == 'available';
  bool get isOccupied => status == 'occupied';
  bool get isReserved => status == 'reserved';
  bool get isMaintenance => status == 'maintenance';

  String get statusText {
    switch (status) {
      case 'available':
        return 'Tersedia';
      case 'occupied':
        return 'Terisi';
      case 'reserved':
        return 'Direservasi';
      case 'maintenance':
        return 'Maintenance';
      default:
        return 'Unknown';
    }
  }

  // Get image from category
  String? get imageUrl => category?.imageUrl;
}