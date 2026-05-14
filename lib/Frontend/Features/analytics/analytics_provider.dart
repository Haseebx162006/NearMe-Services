import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'analytics_repository.dart';
import '../Auth/ViewModel/authViewModel.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository();
});

// Removed individual family providers in favor of a consolidated analyticsProvider


class RecentOrder {
  final String customerName;
  final String serviceName;
  final double amount;
  final String status;

  RecentOrder({
    required this.customerName,
    required this.serviceName,
    required this.amount,
    required this.status,
  });
}

class AnalyticsSummary {
  final double totalEarnings;
  final int totalOrders;
  final double monthEarnings;
  final int pendingOrders;
  final List<RecentOrder> recentOrders;

  AnalyticsSummary({
    required this.totalEarnings,
    required this.totalOrders,
    required this.monthEarnings,
    required this.pendingOrders,
    required this.recentOrders,
  });
}

final analyticsProvider = FutureProvider<AnalyticsSummary>((ref) async {
  final userState = ref.watch(authprovider);
  final userId = userState.value?.id;
  
  if (userId == null) {
    return AnalyticsSummary(
      totalEarnings: 0,
      totalOrders: 0,
      monthEarnings: 0,
      pendingOrders: 0,
      recentOrders: [],
    );
  }

  final repo = ref.read(analyticsRepositoryProvider);
  final data = await repo.getFreelancerAnalytics();
  
  final List recentList = data['recent_orders'] ?? [];
  final List<RecentOrder> recentOrders = recentList.map((o) => RecentOrder(
    customerName: o['customer_name'] ?? 'Customer',
    serviceName: o['gig_title'] ?? 'Service',
    amount: (o['amount'] ?? 0.0).toDouble(),
    status: o['status'] ?? 'pending',
  )).toList();

  return AnalyticsSummary(
    totalEarnings: (data['total_earnings'] ?? 0.0).toDouble(),
    totalOrders: (data['total_orders'] ?? 0).toInt(),
    monthEarnings: (data['month_earnings'] ?? 0.0).toDouble(),
    pendingOrders: (data['pending_orders'] ?? 0).toInt(),
    recentOrders: recentOrders,
  );
});
