import 'package:near_me/Frontend/Admin/Models/admin_dashboard_model.dart';
import 'package:dio/dio.dart';
import 'package:near_me/core/Network/dioClient.dart';
import 'package:near_me/core/storage/secure_storage.dart';

class AdminDashboardService {
  final Dio _dio = Dioclient.dio;
  final SecureStorage _secureStorage = SecureStorage();

  Future<AdminDashboardModel> loadDashboard() async {
    final token = await _secureStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not logged in.');
    }

    final response = await _dio.get(
      '/admin/dashboard',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode == 200 && response.data is Map) {
      final Map<String, dynamic> data =
          Map<String, dynamic>.from(response.data);

      final recent = (data['recent_activity'] is List)
          ? (data['recent_activity'] as List)
              .whereType<Map>()
              .map((e) => AdminRecentActivityItem.fromJson(
                    Map<String, dynamic>.from(e),
                  ))
              .toList()
          : <AdminRecentActivityItem>[];

      return AdminDashboardModel(
        totalUsers: (data['total_users'] ?? 0) as int,
        totalGigs: (data['total_gigs'] ?? 0) as int,
        totalOrders: (data['total_orders'] ?? 0) as int,
        totalRevenue: (data['total_revenue'] ?? 0.0).toDouble(),
        recentActivity: recent,
      );
    }

    throw Exception('Failed to load dashboard.');
  }
}

