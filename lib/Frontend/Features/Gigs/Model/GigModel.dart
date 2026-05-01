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
    required this.createdAt,
    this.updatedAt,
  });

  factory GigModel.fromJson(Map<String, dynamic> json) {
    return GigModel(
      id: json['_id'],
      freelancerId: json['freelancer_id'],
      title: json['title'],
      description: json['description'],
      price: (json['price'] ?? 0.0).toDouble(),
      category: json['category'],
      images: List<String>.from(json['images'] ?? []),
      rating: (json['rating'] ?? 0.0).toDouble(),
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
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
    };
  }
}
