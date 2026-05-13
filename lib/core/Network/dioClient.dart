import 'package:dio/dio.dart';

class Dioclient {
  static const String _defaultBaseUrl = 'http://192.168.1.46:8000';
  static const String _envBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultBaseUrl,
  );

  static Dio dio = Dio(
    BaseOptions(
      baseUrl: _envBaseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );
}
