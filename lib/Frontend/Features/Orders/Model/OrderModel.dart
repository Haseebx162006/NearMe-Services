class OrderModel {
  final String? id;
  final String gigId;
  final String freelancerId;
  final String customerId;
  final String status; // pending, accepted, completed, cancelled
  final double price;
  final String? description;
  final String? customerName;
  final String? gigTitle;
  final DateTime createdAt;
  final DateTime? completedAt;

  OrderModel({
    this.id,
    required this.gigId,
    required this.freelancerId,
    required this.customerId,
    this.status = 'pending',
    required this.price,
    this.description,
    this.customerName,
    this.gigTitle,
    required this.createdAt,
    this.completedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'],
      gigId: json['gig_id'] ?? '',
      freelancerId: json['freelancer_id'] ?? '',
      customerId: json['customer_id'] ?? '',
      status: json['status'] ?? 'pending',
      price: (json['price'] ?? 0.0).toDouble(),
      description: json['description'],
      customerName: json['customer_name'],
      gigTitle: json['gig_title'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gig_id': gigId,
      'freelancer_id': freelancerId,
      'customer_id': customerId,
      'status': status,
      'price': price,
      'description': description,
    };
  }
}
