class OrderModel {
  final String? id;
  final String gigId;
  final String freelancerId;
  final String customerId;
  final String status;
  final double price;
  final String? description;
  final String? customerName;
  final String? freelancerName;
  final String? gigTitle;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool reviewed;
  final int? rating;
  final String? reviewComment;

  OrderModel({
    this.id,
    required this.gigId,
    required this.freelancerId,
    required this.customerId,
    this.status = 'pending',
    required this.price,
    this.description,
    this.customerName,
    this.freelancerName,
    this.gigTitle,
    required this.createdAt,
    this.completedAt,
    this.reviewed = false,
    this.rating,
    this.reviewComment,
  });

  bool get needsReview =>
      status.toLowerCase() == 'completed' && !reviewed;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id']?.toString(),
      gigId: json['gig_id']?.toString() ?? '',
      freelancerId: json['freelancer_id']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      status: json['status'] ?? 'pending',
      price: (json['amount'] ?? json['price'] ?? 0.0).toDouble(),
      description: json['description'] ?? json['requirements'],
      customerName: json['customer_name'],
      freelancerName: json['freelancer_name'],
      gigTitle: json['gig_title'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'].toString())
          : null,
      reviewed: json['reviewed'] == true,
      rating: json['rating'] != null ? (json['rating'] as num).toInt() : null,
      reviewComment: json['review_comment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gig_id': gigId,
      'freelancer_id': freelancerId,
      'customer_id': customerId,
      'status': status,
      'amount': price,
      'description': description,
    };
  }
}
