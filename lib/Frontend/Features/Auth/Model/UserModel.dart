class LocationModel {
  final String type;
  final List<double> coordinates;

  LocationModel({this.type = "Point", required this.coordinates});

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      type: json['type'] ?? "Point",
      coordinates: List<double>.from(
        json['coordinates'].map((x) => x.toDouble()),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'coordinates': coordinates};
  }
}

class UserModel {
  final String? id;
  final String name;
  final String email;
  final String password;
  final String phoneNumber;
  final String role;
  final String? profilePicture;
  final String? profileBio;
  final LocationModel? location;
  final List<String> skills;
  final double wallet;
  final double rating;
  final String? stripeAccountId;
  final int preferredRadiusKm;
  final bool isActive;
  final String? suspensionRemark;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.role,
    this.profilePicture,
    this.profileBio,
    this.location,
    this.skills = const [],
    this.wallet = 0.0,
    this.rating = 0.0,
    this.stripeAccountId,
    this.preferredRadiusKm = 10,
    this.isActive = true,
    this.suspensionRemark,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedCreatedAt;
    try {
      parsedCreatedAt = DateTime.parse(json['created_at'] ?? '');
    } catch (_) {
      parsedCreatedAt = DateTime.now();
    }

    DateTime? parsedUpdatedAt;
    if (json['updated_at'] != null) {
      try {
        parsedUpdatedAt = DateTime.parse(json['updated_at']);
      } catch (_) {
        parsedUpdatedAt = null;
      }
    }

    return UserModel(
      id: json['_id']?.toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['passwrd'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      role: json['role'] ?? 'customer',
      profilePicture: json['profile_picture'],
      profileBio: json['profile_bio'],
      location: json['location'] != null
          ? LocationModel.fromJson(json['location'])
          : null,
      skills: List<String>.from(json['skills'] ?? []),
      wallet: (json['Wallet'] ?? 0.0).toDouble(),
      rating: (json['rating'] ?? 0.0).toDouble(),
      stripeAccountId: json['stripe_account_id']?.toString(),
      preferredRadiusKm: json['preferred_radius_km'] ?? 10,
      isActive: json['is_active'] ?? true,
      suspensionRemark: json['suspension_remark'],
      createdAt: parsedCreatedAt,
      updatedAt: parsedUpdatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'passwrd': password,
      'phone_number': phoneNumber,
      'role': role,
      'profile_picture': profilePicture,
      'profile_bio': profileBio,
      'location': location?.toJson(),
      'skills': skills,
      'Wallet': wallet,
      'rating': rating,
      'stripe_account_id': stripeAccountId,
      'preferred_radius_km': preferredRadiusKm,
      'is_active': isActive,
      'suspension_remark': suspensionRemark,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
