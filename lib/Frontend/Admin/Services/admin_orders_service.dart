import 'package:dio/dio.dart';
import 'package:near_me/core/Network/dioClient.dart';
import 'package:near_me/core/storage/secure_storage.dart';
import 'package:near_me/Frontend/Admin/Models/admin_order_model.dart';

class AdminOrdersService {
  final Dio _dio = Dioclient.dio;
  final SecureStorage _secureStorage = SecureStorage();

  Future<List<AdminOrderModel>> listOrders({int limit = 50}) async {
    final token = await _secureStorage.getToken();
    if (token == null || token.isEmpty) throw Exception('Not logged in.');

    final response = await _dio.get(
      '/admin/orders',
      queryParameters: {'limit': limit},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode == 200 && response.data is List) {
      final List data = response.data;
      return data
          .whereType<Map>()
          .map((e) => AdminOrderModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return [];
  }

  Future<AdminPaymentsSummary> getPaymentsSummary() async {
    final token = await _secureStorage.getToken();
    if (token == null || token.isEmpty) throw Exception('Not logged in.');

    final response = await _dio.get(
      '/admin/payments/summary',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode == 200 && response.data is Map) {
      return AdminPaymentsSummary.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    }

    throw Exception('Failed to load payments summary.');
  }
}

