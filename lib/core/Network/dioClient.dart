import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../storage/secure_storage.dart';

class Dioclient {
  static final String _baseUrl = 
      dotenv.env['API_BASE_URL'] ?? 'http://192.168.100.4:8000';

  static final Dio dio = _initDio();

  static Dio _initDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptor to automatically add the Bearer token to all requests
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final storage = SecureStorage();
          final token = await storage.getToken();
          
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Centralized error mapping
          String errorMessage = 'Something went wrong';
          
          if (e.type == DioExceptionType.connectionTimeout || 
              e.type == DioExceptionType.receiveTimeout) {
            errorMessage = 'Connection timed out. Please check your internet.';
          } else if (e.type == DioExceptionType.connectionError) {
            errorMessage = 'Cannot reach server. Are you online?';
          } else if (e.response != null) {
            errorMessage = 'Server error: ${e.response?.statusCode}';
          }

          print('[Dio Error] $errorMessage - ${e.message}');
          return handler.next(e);
        },
      ),
    );

    // Optional: Add logging for better debugging (only in debug mode recommended for prod)
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));

    return dio;
  }
}
