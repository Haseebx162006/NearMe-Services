import 'package:dio/dio.dart';

class Dioclient {
  static Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://192.168.100.4:8000",
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );
}
