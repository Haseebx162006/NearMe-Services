import 'package:dio/dio.dart';
import '../../../../core/Network/dioClient.dart';
import '../../../../core/storage/secure_storage.dart';
import '../Model/GigModel.dart';

class GigRepository {
  final _dio = Dioclient.dio;
  final _secureStorage = SecureStorage();

  Future<List<GigModel>> getAllGigs({String? sortBy, int limit = 10}) async {
    try {
      final token = await _secureStorage.getToken();
      final response = await _dio.get(
        '/gigs/',
        queryParameters: {
          if (sortBy != null) 'sort_by': sortBy,
          'limit': limit,
        },
        options: Options(
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => GigModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('GetAllGigs Error: $e');
      return [];
    }
  }

  Future<List<GigModel>> getMyGigs() async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) return [];

      final response = await _dio.get(
        '/gigs/my',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => GigModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('GetMyGigs Error: $e');
      return [];
    }
  }

  /// Creates a new gig on the backend.
  /// Returns the gig_id on success, throws on failure.
  Future<String> createGig({
    required String title,
    required String description,
    required double price,
    required String category,
    required String freelancerId,
    List<String> images = const [],
  }) async {
    final token = await _secureStorage.getToken();
    if (token == null) throw Exception('Not logged in');

    final response = await _dio.post(
      '/gigs/',
      data: {
        'title': title,
        'description': description,
        'price': price,
        'category': category,
        'freelancer_id': freelancerId,
        'images': images,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data['gig_id'] ?? '';
    }
    throw Exception('Failed to create gig');
  }

  /// Saves the freelancer's GPS coordinates to their user profile.
  /// This is needed so $geoNear search can find them.
  Future<bool> updateFreelancerLocation({
    required double longitude,
    required double latitude,
  }) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) return false;

      await _dio.patch(
        '/auth/update-location',
        data: {'longitude': longitude, 'latitude': latitude},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return true;
    } catch (e) {
      print('[GigRepo] Failed to save freelancer location: $e');
      return false;
    }
  }
}
