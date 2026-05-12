class GigModel {
  final String? id;
  final String freelancerId;
  final String title;
  final String description;
  final double price;
  final String category;
  final List<String> images;
  final double rating;
  final bool isActive;
  final String moderationStatus;
  final DateTime createdAt;
  final DateTime? updatedAt;

  GigModel({
    this.id,
    required this.freelancerId,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    this.images = const [],
    this.rating = 0.0,
    this.isActive = true,
    this.moderationStatus = 'approved',
    required this.createdAt,
    this.updatedAt,
  });

  factory GigModel.fromJson(Map<String, dynamic> json) {
    return GigModel(
      id: json['_id'],
      freelancerId: json['freelancer_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      category: json['category'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      rating: (json['rating'] ?? 0.0).toDouble(),
      isActive: json['is_active'] ?? true,
      moderationStatus: (json['moderation_status'] ?? 'approved').toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'images': images,
      'is_active': isActive,
      'moderation_status': moderationStatus,
    };
  }
}
