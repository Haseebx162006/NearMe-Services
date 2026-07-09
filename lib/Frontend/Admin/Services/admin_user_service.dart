import 'package:dio/dio.dart';
import 'package:near_me/core/Network/dioClient.dart';
import 'package:near_me/core/storage/secure_storage.dart';
import 'package:near_me/Frontend/Features/Auth/Model/UserModel.dart';

class AdminUserService {
  final Dio _dio = Dioclient.dio;
  final SecureStorage _secureStorage = SecureStorage();

  Future<List<UserModel>> getAllUsers() async {
    final token = await _secureStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not logged in.');
    }

    final response = await _dio.get(
      '/admin/users',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data is List) {
        return data
            .map((e) => UserModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    }

    throw Exception('Failed to load users.');
  }

  Future<void> suspendUser({
    required String userId,
    required String remark,
  }) async {
    final token = await _secureStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not logged in.');
    }

    final response = await _dio.post(
      '/admin/users/$userId/suspend',
      data: {'remark': remark},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode == 200) return;
    throw Exception('Failed to suspend user.');
  }

  Future<void> reactivateUser({required String userId}) async {
    final token = await _secureStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not logged in.');
    }

    final response = await _dio.post(
      '/admin/users/$userId/reactivate',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode == 200) return;
    throw Exception('Failed to reactivate user.');
  }
}

