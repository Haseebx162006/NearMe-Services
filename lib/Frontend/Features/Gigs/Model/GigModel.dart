import 'package:near_me/Frontend/Utils/mongo_id.dart';

class GigModel {
  final String? id;
  final String freelancerId;
  final String? freelancerName;
  final double? freelancerRating;
  final int? freelancerReviewCount;
  final String? freelancerEmail;
  final String? freelancerPhone;
  final String? freelancerBio;
  final List<String> freelancerSkills;
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
    this.freelancerName,
    this.freelancerRating,
    this.freelancerReviewCount,
    this.freelancerEmail,
    this.freelancerPhone,
    this.freelancerBio,
    this.freelancerSkills = const [],
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
      id: parseMongoId(json['_id']),
      freelancerId: parseMongoId(json['freelancer_id']),
      freelancerName: json['freelancer_name']?.toString(),
      freelancerRating: json['freelancer_rating'] != null
          ? (json['freelancer_rating'] as num).toDouble()
          : null,
      freelancerReviewCount: json['freelancer_review_count'] != null
          ? (json['freelancer_review_count'] as num).toInt()
          : null,
      freelancerEmail: json['freelancer_email']?.toString(),
      freelancerPhone: json['freelancer_phone']?.toString(),
      freelancerBio: json['freelancer_bio']?.toString(),
      freelancerSkills: List<String>.from(json['freelancer_skills'] ?? []),
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
