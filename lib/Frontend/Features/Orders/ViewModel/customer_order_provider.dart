import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Repository/OrderRepository.dart';

final customerOrderProvider =
    AsyncNotifierProvider<CustomerOrderNotifier, bool>(
      CustomerOrderNotifier.new,
    );

class CustomerOrderNotifier extends AsyncNotifier<bool> {
  final _repo = OrderRepository();

  @override
  FutureOr<bool> build() => false;

  Future<void> placeOrder({
    required String gigId,
    required String freelancerId,
    required String customerId,
    required double amount,
    String? requirements,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.createOrder(
        gigId: gigId,
        freelancerId: freelancerId,
        customerId: customerId,
        amount: amount,
        requirements: requirements,
      );
      return true;
    });

    if (state.hasError) {
      throw Exception(state.error.toString());
    }
  }
}
