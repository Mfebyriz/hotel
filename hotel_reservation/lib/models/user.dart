class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String? profileImage;
  final bool isActive;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.profileImage,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      profileImage: json['profile_image'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'profile_image': profileImage,
      'is_active': isActive,
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isCustomer => role == 'customer';
}