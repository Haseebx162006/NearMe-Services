import 'package:near_me/Frontend/Utils/mongo_id.dart';

/// Model for a gig returned by the /search/nearby-gigs endpoint.
/// Includes distance_km which shows how far this gig's freelancer is.
class NearbyGigModel {
  final String id;
  final String freelancerId;
  final String title;
  final String description;
  final String category;
  final double price;
  final List<String> images;
  final bool isActive;
  final double distanceKm;

  NearbyGigModel({
    required this.id,
    required this.freelancerId,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    this.images = const [],
    this.isActive = true,
    required this.distanceKm,
  });

  /// Creates a NearbyGigModel from the JSON returned by the backend.
  factory NearbyGigModel.fromJson(Map<String, dynamic> json) {
    return NearbyGigModel(
      id: parseMongoId(json['_id'] ?? json['gig_id']),
      freelancerId: parseMongoId(json['freelancer_id']),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      images: List<String>.from(json['images'] ?? []),
      isActive: json['is_active'] ?? true,
      distanceKm: (json['distance_km'] ?? 0.0).toDouble(),
    );
  }
}

/// The full response from the /search/nearby-gigs endpoint.
class NearbyGigSearchResponse {
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;
  final int uniqueFreelancers;
  final double? nearestFreelancerKm;
  final List<NearbyGigModel> items;

  NearbyGigSearchResponse({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
    required this.uniqueFreelancers,
    this.nearestFreelancerKm,
    required this.items,
  });

  factory NearbyGigSearchResponse.fromJson(Map<String, dynamic> json) {
    return NearbyGigSearchResponse(
      page: json['page'] ?? 1,
      pageSize: json['page_size'] ?? 20,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
      uniqueFreelancers: json['unique_freelancers'] ?? 0,
      nearestFreelancerKm: json['nearest_freelancer_km']?.toDouble(),
      items: (json['items'] as List? ?? [])
          .map((item) => NearbyGigModel.fromJson(item))
          .toList(),
    );
  }
}
