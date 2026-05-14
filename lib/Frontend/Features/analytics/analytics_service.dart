import 'package:dio/dio.dart';
import '../../../core/Network/dioClient.dart';

class AnalyticsService {
  final Dio _dio = Dioclient.dio;

  Future<Map<String, dynamic>> getFreelancerAnalytics() async {
    final response = await _dio.get('/analytics/me');
    return response.data;
  }
}
