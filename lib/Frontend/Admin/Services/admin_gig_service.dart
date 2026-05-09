import 'package:dio/dio.dart';
import 'package:near_me/core/Network/dioClient.dart';
import 'package:near_me/core/storage/secure_storage.dart';
import 'package:near_me/Frontend/Features/Gigs/Model/GigModel.dart';

class AdminGigService {
  final Dio _dio = Dioclient.dio;
  final SecureStorage _secureStorage = SecureStorage();

  Future<List<GigModel>> getPendingGigs({int limit = 50}) async {
    final token = await _secureStorage.getToken();
    if (token == null || token.isEmpty) throw Exception('Not logged in.');

    final response = await _dio.get(
      '/admin/gigs',
      queryParameters: {'status_filter': 'pending', 'limit': limit},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode == 200 && response.data is List) {
      final List data = response.data;
      return data.map((e) => GigModel.fromJson(e)).toList();
    }

    return [];
  }

  Future<void> setGigModerationStatus({
    required String gigId,
    required bool approve,
  }) async {
    final token = await _secureStorage.getToken();
    if (token == null || token.isEmpty) throw Exception('Not logged in.');

    final path = approve
        ? '/admin/gigs/$gigId/approve'
        : '/admin/gigs/$gigId/reject';

    final response = await _dio.patch(
      path,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode == 200) return;
    throw Exception('Failed to update gig status.');
  }
}

