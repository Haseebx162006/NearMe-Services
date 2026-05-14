import 'analytics_service.dart';

class AnalyticsRepository {
  final AnalyticsService _service = AnalyticsService();

  Future<Map<String, dynamic>> getFreelancerAnalytics() async {
    try {
      return await _service.getFreelancerAnalytics();
    } catch (e) {
      throw Exception('Failed to fetch analytics: $e');
    }
  }
}
