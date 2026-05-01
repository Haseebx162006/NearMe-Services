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
          'sort_by': ?sortBy,
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
      return [];
    }
  }
}
