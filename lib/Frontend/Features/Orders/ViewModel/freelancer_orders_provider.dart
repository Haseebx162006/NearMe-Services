import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Model/OrderModel.dart';
import '../Repository/OrderRepository.dart';

final freelancerOrdersProvider =
    AsyncNotifierProvider<FreelancerOrdersNotifier, List<OrderModel>>(
      FreelancerOrdersNotifier.new,
    );

class FreelancerOrdersNotifier extends AsyncNotifier<List<OrderModel>> {
  final _repo = OrderRepository();

  @override
  FutureOr<List<OrderModel>> build() {
    return _repo.getFreelancerOrders();
  }

  Future<void> refreshOrders() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return await _repo.getFreelancerOrders();
    });
  }

  Future<void> getAcceptedOrders() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return await _repo.getAcceptedOrders();
    });
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _repo.updateOrderStatus(orderId, newStatus);
    // Refresh to get the updated list
    await refreshOrders();
  }
}
