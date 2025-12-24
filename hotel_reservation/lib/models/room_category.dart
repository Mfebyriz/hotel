class RoomCategory {
  final int id;
  final String name;
  final String? description;
  final double basePrice;
  final int maxGuests;
  final List<String> amenities;
  final String? imageUrl;  // Single image per category
  final bool isActive;

  RoomCategory({
    required this.id,
    required this.name,
    this.description,
    required this.basePrice,
    required this.maxGuests,
    required this.amenities,
    this.imageUrl,
    required this.isActive,
  });

  factory RoomCategory.fromJson(Map<String, dynamic> json) {
    return RoomCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      basePrice: double.parse(json['base_price'].toString()),
      maxGuests: json['max_guests'],
      amenities: List<String>.from(json['amenities'] ?? []),
      imageUrl: json['image_url'] ?? json['image_full_url'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'base_price': basePrice,
      'max_guests': maxGuests,
      'amenities': amenities,
      'image_url': imageUrl,
      'is_active': isActive,
    };
  }
}