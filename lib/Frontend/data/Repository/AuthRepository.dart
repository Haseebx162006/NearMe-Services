import 'package:dio/dio.dart';
import '../../Model/UserModel.dart';
import '../../../core/Network/dioClient.dart';
import '../../../core/storage/secure_storage.dart';

class AuthRepository {
  final _secureStorage = SecureStorage();
  final _dio = Dioclient.dio;


  Future<String?> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data:{
        'email': email,
        'password': password, // Ensure this matches the backend field name (passwrd vs password)
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
      // We use user.toJson() but ensure the field names match the backend (passwrd vs password)
      final userData = user.toJson();

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
      final errorMessage =
          e.response?.data['detail'] ?? "Signup failed. Please try again.";
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception("An unexpected error occurred: $e");
    }
  }

  /// Logs out the user by deleting the stored token.
  Future<void> logout() async {
    await _secureStorage.deleteToken();
  }

  /// Checks if a user is currently logged in.
  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.getToken();
    return token != null && token.isNotEmpty;
  }
}
