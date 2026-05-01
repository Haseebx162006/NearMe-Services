import 'package:dio/dio.dart';
import '../Model/UserModel.dart';
import '../../../../core/Network/dioClient.dart';
import '../../../../core/storage/secure_storage.dart';

class AuthRepository {
  final _secureStorage = SecureStorage();
  final _dio = Dioclient.dio;

  Future<String?> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password':
              password, // Ensure this matches the backend field name (passwrd vs password)
        },
      );

      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        if (token != null) {
          await _secureStorage.saveToken(token);
          return token;
        }
      }
      return null;
    } on DioException catch (e) {
      // Basic error handling for beginners
      final errorMessage =
          e.response?.data['detail'] ?? "Login failed. Please try again.";
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception("An unexpected error occurred: $e");
    }
  }

  Future<String?> signup(UserModel user) async {
    try {
      // Map Dart UserModel fields to match backend schema's exact field names
      final Map<String, dynamic> userData = {
        'name': user.name,
        'email': user.email,
        'phone_number': user.phoneNumber,
        'role': user.role,
        'password': user.password,
      };

      if (user.location != null &&
          user.location!.coordinates.isNotEmpty &&
          !(user.location!.coordinates[0] == 0.0 &&
              user.location!.coordinates[1] == 0.0)) {
        userData['location'] = user.location!.toJson();
      }

      final response = await _dio.post('/auth/signup', data: userData);

      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        if (token != null) {
          await _secureStorage.saveToken(token);
          return token;
        }
      }
      return null;
    } on DioException catch (e) {
      // Extract the actual error message from the backend response
      String errorMessage = "Signup failed. Please try again.";
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.containsKey('detail')) {
          errorMessage = data['detail'].toString();
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        errorMessage = "Cannot connect to server. Is the backend running?";
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception("An unexpected error occurred: $e");
    }
  }

  /// Logs out the user by deleting the stored token.
  Future<void> logout() async {
    await _secureStorage.deleteToken();
  }

  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<String?> getName() async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) {
        throw Exception("No token found. User might not be logged in.");
      }

      final response = await _dio.get(
        '/auth/getname',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return response.data['name'];
      } else {
        throw Exception(
          "Failed to fetch name. Status code: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Failed to fetch name: $e");
    }
  }
}
