import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:near_me/Frontend/Features/Gigs/Model/GigModel.dart';
import 'package:near_me/Frontend/Features/Gigs/Repository/GigRepo.dart';

final gigprovider = AsyncNotifierProvider<GigViewmodel, List<GigModel>>(
  GigViewmodel.new,
);
class GigViewmodel extends AsyncNotifier<List<GigModel>>{
  final _repo = GigRepository();
  @override
  FutureOr<List<GigModel>> build() {
    return _repo.getAllGigs(limit: 100);
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
      return await _repo.getAllGigs(limit: 100);
    });
  }
}