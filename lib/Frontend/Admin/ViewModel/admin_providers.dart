import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:near_me/Frontend/Admin/Models/admin_dashboard_model.dart';
import 'package:near_me/Frontend/Admin/Models/admin_order_model.dart';
import 'package:near_me/Frontend/Admin/Services/admin_dashboard_service.dart';
import 'package:near_me/Frontend/Admin/Services/admin_gig_service.dart';
import 'package:near_me/Frontend/Admin/Services/admin_orders_service.dart';
import 'package:near_me/Frontend/Admin/Services/admin_user_service.dart';
import 'package:near_me/Frontend/Features/Auth/Model/UserModel.dart';
import 'package:near_me/Frontend/Features/Gigs/Model/GigModel.dart';

final adminUserServiceProvider = Provider<AdminUserService>((ref) {
  return AdminUserService();
});

final adminGigServiceProvider = Provider<AdminGigService>((ref) {
  return AdminGigService();
});

final adminOrdersServiceProvider = Provider<AdminOrdersService>((ref) {
  return AdminOrdersService();
});

final adminDashboardServiceProvider = Provider<AdminDashboardService>((ref) {
  return AdminDashboardService();
});

final adminDashboardProvider = FutureProvider.autoDispose<AdminDashboardModel>((ref) async {
  final service = ref.read(adminDashboardServiceProvider);
  return service.loadDashboard();
});

final adminUsersProvider = FutureProvider.autoDispose<List<UserModel>>((ref) async {
  final service = ref.read(adminUserServiceProvider);
  return service.getAllUsers();
});

final adminGigsProvider = FutureProvider.autoDispose<List<GigModel>>((ref) async {
  final service = ref.read(adminGigServiceProvider);
  return service.getPendingGigs(limit: 100);
});

final adminOrdersProvider = FutureProvider.autoDispose<List<AdminOrderModel>>((ref) async {
  final service = ref.read(adminOrdersServiceProvider);
  return service.listOrders(limit: 100);
});

final adminPaymentsSummaryProvider = FutureProvider.autoDispose<AdminPaymentsSummary>((ref) async {
  final service = ref.read(adminOrdersServiceProvider);
  return service.getPaymentsSummary();
});

class AdminUserActionController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // no-op
  }

  Future<void> suspend({
    required String userId,
    required String remark,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(adminUserServiceProvider);
      await service.suspendUser(userId: userId, remark: remark);
      ref.invalidate(adminUsersProvider);
    });
  }

  Future<void> reactivate({required String userId}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(adminUserServiceProvider);
      await service.reactivateUser(userId: userId);
      ref.invalidate(adminUsersProvider);
    });
  }
}

final adminUserActionControllerProvider =
    AsyncNotifierProvider.autoDispose<AdminUserActionController, void>(
  AdminUserActionController.new,
);

class AdminGigModerationController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // no-op
  }

  Future<void> approveGig({required String gigId}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(adminGigServiceProvider);
      await service.setGigModerationStatus(gigId: gigId, approve: true);
      ref.invalidate(adminGigsProvider);
    });
  }

  Future<void> rejectGig({required String gigId}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(adminGigServiceProvider);
      await service.setGigModerationStatus(gigId: gigId, approve: false);
      ref.invalidate(adminGigsProvider);
    });
  }
}

final adminGigModerationControllerProvider =
    AsyncNotifierProvider.autoDispose<AdminGigModerationController, void>(
  AdminGigModerationController.new,
);

