import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:near_me/core/Network/dioClient.dart';

final analyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final response = await Dioclient.dio.get('/analytics/me');
  return response.data;
});
