import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'analytics_repository.dart';
import '../Auth/ViewModel/authViewModel.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository();
});

// Since we need a userId, we expect it to be passed via a Family provider
final totalEarningsProvider = FutureProvider.family<double, String>((
  ref,
  userId,
) async {
  final repo = ref.read(analyticsRepositoryProvider);
  return repo.getTotalEarnings(userId);
});

final monthlyEarningsProvider = FutureProvider.family<double, String>((
  ref,
  userId,
) async {
  final repo = ref.read(analyticsRepositoryProvider);
  return repo.getMonthlyEarnings(userId);
});

final totalOrdersProvider = FutureProvider.family<int, String>((
  ref,
  userId,
) async {
  final repo = ref.read(analyticsRepositoryProvider);
  return repo.getTotalOrders(userId);
});


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
  double totalEarnings = 0.0;
  double monthEarnings = 0.0;
  int totalOrders = 0;
  
  try { totalEarnings = await repo.getTotalEarnings(userId); } catch (_) {}
  try { monthEarnings = await repo.getMonthlyEarnings(userId); } catch (_) {}
  try { totalOrders = await repo.getTotalOrders(userId); } catch (_) {}
  
  return AnalyticsSummary(
    totalEarnings: totalEarnings,
    totalOrders: totalOrders,
    monthEarnings: monthEarnings,
    pendingOrders: 0,
    recentOrders: [],
  );
});
