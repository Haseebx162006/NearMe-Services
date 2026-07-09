import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Repository/OrderRepository.dart';

final customerOrderProvider =
    AsyncNotifierProvider<CustomerOrderNotifier, String?>(
      CustomerOrderNotifier.new,
    );

class CustomerOrderNotifier extends AsyncNotifier<String?> {
  final _repo = OrderRepository();

  @override
  FutureOr<String?> build() => null;

  /// Places an order and returns the orderId so the caller can initiate payment.
  Future<String> placeOrder({
    required String gigId,
    required String freelancerId,
    required String customerId,
    required double amount,
    String? requirements,
  }) async {
    state = const AsyncLoading();
    String orderId = '';
    state = await AsyncValue.guard(() async {
      orderId = await _repo.createOrder(
        gigId: gigId,
        freelancerId: freelancerId,
        customerId: customerId,
        amount: amount,
        requirements: requirements,
      );
      return orderId;
    });

    if (state.hasError) {
      throw Exception(state.error.toString());
    }

    return orderId;
  }
}
