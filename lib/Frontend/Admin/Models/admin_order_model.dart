class AdminOrderModel {
  final String id;
  final String gigId;
  final String freelancerId;
  final String customerId;
  final String status;
  final double amount;
  final String paymentStatus;
  final DateTime? createdAt;

  const AdminOrderModel({
    required this.id,
    required this.gigId,
    required this.freelancerId,
    required this.customerId,
    required this.status,
    required this.amount,
    required this.paymentStatus,
    required this.createdAt,
  });

  factory AdminOrderModel.fromJson(Map<String, dynamic> json) {
    DateTime? created;
    final rawCreated = json['created_at'];
    if (rawCreated is String && rawCreated.isNotEmpty) {
      created = DateTime.tryParse(rawCreated);
    }

    return AdminOrderModel(
      id: (json['_id'] ?? '').toString(),
      gigId: (json['gig_id'] ?? '').toString(),
      freelancerId: (json['freelancer_id'] ?? '').toString(),
      customerId: (json['customer_id'] ?? '').toString(),
      status: (json['status'] ?? 'pending').toString(),
      amount: (json['amount'] ?? 0.0).toDouble(),
      paymentStatus: (json['payment_status'] ?? 'pending').toString(),
      createdAt: created,
    );
  }
}

class AdminPaymentsSummary {
  final double totalInEscrow;
  final int disputedOrders;

  const AdminPaymentsSummary({
    required this.totalInEscrow,
    required this.disputedOrders,
  });

  factory AdminPaymentsSummary.fromJson(Map<String, dynamic> json) {
    return AdminPaymentsSummary(
      totalInEscrow: (json['total_in_escrow'] ?? 0.0).toDouble(),
      disputedOrders: (json['disputed_orders'] ?? 0).toInt(),
    );
  }
}

