import 'dart:io';

import 'package:dio/dio.dart';
import 'package:near_me/core/Network/dioClient.dart';
import 'package:near_me/core/storage/secure_storage.dart';

class MediaUploadResult {
  final String url;
  final String? publicId;
  final String? resourceType;

  const MediaUploadResult({
    required this.url,
    this.publicId,
    this.resourceType,
  });

  factory MediaUploadResult.fromJson(Map<String, dynamic> json) {
    return MediaUploadResult(
      url: (json['url'] ?? '').toString(),
      publicId: json['public_id']?.toString(),
      resourceType: json['resource_type']?.toString(),
    );
  }
}

class MediaUploadService {
  final Dio _dio = Dioclient.dio;
  final SecureStorage _secureStorage = SecureStorage();

  /// Uploads a file to backend, which uploads it to Cloudinary.
  ///
  /// Returns the Cloudinary URL. You can store this URL in:
  /// - user.profile_picture
  /// - gig.images[]
  Future<MediaUploadResult> uploadFile({
    required File file,
    String folder = 'nearme',
  }) async {
    final token = await _secureStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not logged in.');
    }

    final fileName = file.path.split(Platform.pathSeparator).last;

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });

    final response = await _dio.post(
      '/media/upload',
      queryParameters: {'folder': folder},
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          // Dio sets multipart boundary automatically when using FormData,
          // but this helps some proxies/tools.
          'Content-Type': 'multipart/form-data',
        },
      ),
    );

    if (response.statusCode == 200 && response.data is Map) {
      final result =
          MediaUploadResult.fromJson(Map<String, dynamic>.from(response.data));
      if (result.url.isEmpty) {
        throw Exception('Upload succeeded but URL is missing.');
      }
      return result;
    }

    throw Exception('Upload failed.');
  }
}

