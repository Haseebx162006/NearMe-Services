import 'package:dio/dio.dart';
import '../../../core/Network/dioClient.dart';

class AnalyticsService {
  final Dio _dio = Dioclient.dio;

  Future<Map<String, dynamic>> getTotalEarnings(String userId) async {
    final response = await _dio.get('/analytics/earnings/\$userId');
    return response.data;
  }

  Future<Map<String, dynamic>> getMonthlyEarnings(String userId) async {
    final response = await _dio.get('/analytics/monthly-earnings/\$userId');
    return response.data;
  }

  Future<Map<String, dynamic>> getTotalOrders(String userId) async {
    final response = await _dio.get('/analytics/total-orders/\$userId');
    return response.data;
  }
}
