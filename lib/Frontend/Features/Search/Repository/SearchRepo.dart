import 'package:dio/dio.dart';
import '../../../../core/Network/dioClient.dart';
import '../../../../core/storage/secure_storage.dart';
import '../Model/NearbyGigModel.dart';

/// Handles all HTTP calls related to search and location.
class SearchRepository {
  final _dio = Dioclient.dio;
  final _secureStorage = SecureStorage();

  /// Calls GET /search/nearby-gigs with the given filters.
  /// Returns the parsed response containing gigs and metadata.
  Future<NearbyGigSearchResponse> searchNearbyGigs({
    double radiusKm = 10,
    String search = '',
    String category = '',
    int page = 1,
    int pageSize = 20,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) {
        throw Exception('Not logged in. Please sign in first.');
      }

      final queryParams = <String, dynamic>{
        'radius_km': radiusKm,
        'search': search,
        'category': category,
        'page': page,
        'page_size': pageSize,
      };

      // Send GPS coordinates directly so the backend
      // does NOT need to look them up from the user document
      if (latitude != null && longitude != null) {
        queryParams['latitude'] = latitude;
        queryParams['longitude'] = longitude;
      }

      final response = await _dio.get(
        '/search/nearby-gigs',
        queryParameters: queryParams,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return NearbyGigSearchResponse.fromJson(response.data);
      }

      // If status code is not 200, return empty response
      return NearbyGigSearchResponse(
        page: page,
        pageSize: pageSize,
        total: 0,
        totalPages: 0,
        uniqueFreelancers: 0,
        items: [],
      );
    } on DioException catch (e) {
      String errorMessage = 'Search failed. Please try again.';
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.containsKey('detail')) {
          errorMessage = data['detail'].toString();
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        errorMessage = 'Cannot connect to server. Is the backend running?';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Search error: $e');
    }
  }

  /// Sends the user's GPS coordinates to the backend.
  /// Call this when the app first gets the user's location.
  /// Returns true if the location was saved successfully.
  Future<bool> updateUserLocation({
    required double longitude,
    required double latitude,
  }) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) {
        print('[SearchRepo] No token — cannot update location');
        return false;
      }

      print('[SearchRepo] Saving location: lat=$latitude, lng=$longitude');

      final response = await _dio.patch(
        '/auth/update-location',
        data: {
          'longitude': longitude,
          'latitude': latitude,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      print('[SearchRepo] Location saved: ${response.data}');
      return true;
    } catch (e) {
      print('[SearchRepo] Failed to save location: $e');
      return false;
    }
  }
}
