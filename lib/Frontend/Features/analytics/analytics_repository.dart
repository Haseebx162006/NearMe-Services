import 'analytics_service.dart';

class AnalyticsRepository {
  final AnalyticsService _service = AnalyticsService();

  Future<double> getTotalEarnings(String userId) async {
    try {
      final data = await _service.getTotalEarnings(userId);
      if (data['success'] == true) {
        return (data['data']['totalEarnings'] ?? 0.0).toDouble();
      }
      throw Exception('Failed to fetch total earnings');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<double> getMonthlyEarnings(String userId) async {
    try {
      final data = await _service.getMonthlyEarnings(userId);
      if (data['success'] == true) {
        return (data['data']['monthEarnings'] ?? 0.0).toDouble();
      }
      throw Exception('Failed to fetch monthly earnings');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<int> getTotalOrders(String userId) async {
    try {
      final data = await _service.getTotalOrders(userId);
      if (data['success'] == true) {
        return (data['data']['totalOrders'] ?? 0).toInt();
      }
      throw Exception('Failed to fetch total orders');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
