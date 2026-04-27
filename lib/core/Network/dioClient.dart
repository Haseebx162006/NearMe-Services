import 'package:dio/dio.dart';

class Dioclient {
  static Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://localhost:8000",
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    )
  );
}