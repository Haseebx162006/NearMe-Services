import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:near_me/Frontend/Media/Services/media_upload_service.dart';

final mediaUploadServiceProvider = Provider<MediaUploadService>((ref) {
  return MediaUploadService();
});

class MediaUploadController extends AsyncNotifier<MediaUploadResult?> {
  @override
  Future<MediaUploadResult?> build() async {
    return null;
  }

  Future<MediaUploadResult> upload({
    required File file,
    String folder = 'nearme',
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(mediaUploadServiceProvider);
      return await service.uploadFile(file: file, folder: folder);
    });

    final result = state.value;
    if (result == null) throw Exception('Upload failed.');
    return result;
  }

  void reset() {
    state = const AsyncData(null);
  }
}

final mediaUploadControllerProvider =
    AsyncNotifierProvider.autoDispose<MediaUploadController, MediaUploadResult?>(
  MediaUploadController.new,
);

