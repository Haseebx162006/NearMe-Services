import 'package:dio/dio.dart';
import '../../../../core/Network/dioClient.dart';
import '../../../../core/storage/secure_storage.dart';
import '../Model/OrderModel.dart';

class OrderRepository {
  final _dio = Dioclient.dio;
  final _secureStorage = SecureStorage();

  Future<String> createOrder({
    required String gigId,
    required String freelancerId,
    required String customerId,
    required double amount,
    String? requirements,
  }) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) {
        throw Exception('Not logged in. Please sign in first.');
      }

      final response = await _dio.post(
        '/orders/',
        data: {
          'gig_id': gigId,
          'freelancer_id': freelancerId,
          'customer_id': customerId,
          'amount': amount,
          if (requirements != null && requirements.trim().isNotEmpty)
            'requirements': requirements.trim(),
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is String) {
          return response.data.toString();
        }

        if (response.data is Map) {
          return response.data['id']?.toString() ??
              response.data['order_id']?.toString() ??
              '';
        }

        return response.data.toString();
      }

      throw Exception('Could not place order');
    } on DioException catch (e) {
      String errorMessage = 'Could not place order. Please try again.';
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.containsKey('detail')) {
          errorMessage = data['detail'].toString();
        }
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Order error: $e');
    }
  }

  /// Get all orders for a freelancer (pending + accepted)
  Future<List<OrderModel>> getFreelancerOrders() async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) return [];

      final response = await _dio.get(
        '/orders/freelancer/orders-for-freelancer',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final List data = response.data is List
            ? response.data
            : [response.data];
        return data.map((json) => OrderModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('GetFreelancerOrders Error: $e');
      return [];
    }
  }

  /// Get accepted orders for a freelancer
  Future<List<OrderModel>> getAcceptedOrders() async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) return [];

      final response = await _dio.get(
        '/orders/freelancer/my-accepted-orders',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final List data = response.data is List
            ? response.data
            : [response.data];
        return data.map((json) => OrderModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('GetAcceptedOrders Error: $e');
      return [];
    }
  }
}
