import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Model/OrderModel.dart';
import '../Repository/OrderRepository.dart';

final _orderRepo = OrderRepository();

final customerOrdersProvider =
    AsyncNotifierProvider<CustomerOrdersNotifier, List<OrderModel>>(
  CustomerOrdersNotifier.new,
);

final pendingReviewProvider = FutureProvider<bool>((ref) async {
  return _orderRepo.hasPendingReview();
});

class CustomerOrdersNotifier extends AsyncNotifier<List<OrderModel>> {
  @override
  Future<List<OrderModel>> build() async {
    return _orderRepo.getCustomerOrders();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _orderRepo.getCustomerOrders());
  }

  Future<void> submitReview({
    required String orderId,
    required int rating,
    String? comment,
  }) async {
    await _orderRepo.submitReview(
      orderId: orderId,
      rating: rating,
      comment: comment,
    );
    await refresh();
  }
}
