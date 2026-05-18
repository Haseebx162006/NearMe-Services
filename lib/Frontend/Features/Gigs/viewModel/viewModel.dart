import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:near_me/Frontend/Features/Gigs/Model/GigModel.dart';
import 'package:near_me/Frontend/Features/Gigs/Repository/GigRepo.dart';

final gigprovider = AsyncNotifierProvider<GigViewmodel, List<GigModel>>(
  GigViewmodel.new,
);

class GigViewmodel extends AsyncNotifier<List<GigModel>> {
  final _repo = GigRepository();
  @override
  FutureOr<List<GigModel>> build() {
    // By default, only load "my" gigs if user is logged in
    return _repo.getMyGigs();
  }

  Future<void> getMyGigs() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return await _repo.getMyGigs();
    });
  }

  Future<void> refreshGigs() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return await _repo.getMyGigs();
    });
  }

  Future<bool> deleteGig(String gigId) async {
    final success = await _repo.deleteGig(gigId);
    if (success) {
      await getMyGigs();
    }
    return success;
  }

  Future<bool> editGig({
    required String gigId,
    required String title,
    required String description,
    required double price,
    required String category,
    required String freelancerId,
    List<String> images = const [],
  }) async {
    final success = await _repo.updateGig(
      gigId: gigId,
      title: title,
      description: description,
      price: price,
      category: category,
      freelancerId: freelancerId,
      images: images,
    );
    if (success) {
      await getMyGigs();
    }
    return success;
  }
}
