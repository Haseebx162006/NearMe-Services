import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/Network/dioClient.dart';
import '../../../../core/storage/secure_storage.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class PaymentRepository {
  final _dio = Dioclient.dio;
  final _secureStorage = SecureStorage();

  /// Creates a Stripe PaymentIntent for the given order and returns the client_secret
  Future<String> createPaymentIntent(String orderId) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not logged in');

      final response = await _dio.post(
        '/payments/create-intent',
        data: {'order_id': orderId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data['client_secret'] != null) {
        return response.data['client_secret'];
      }
      throw Exception('Failed to create payment intent');
    } on DioException catch (e) {
      final detail = e.response?.data is Map ? e.response!.data['detail'] : null;
      throw Exception(detail ?? 'Payment setup failed. Please try again.');
    }
  }

  /// Initializes and presents the Stripe Payment Sheet
  Future<void> presentPaymentSheet(String clientSecret) async {
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'NearMe Services',
        style: ThemeMode.light,
      ),
    );

    await Stripe.instance.presentPaymentSheet();
  }

  /// Creates a Stripe Connected Account for the freelancer
  Future<Map<String, dynamic>> createConnectedAccount() async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not logged in');

      final response = await _dio.post(
        '/payments/connect/create-account',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      }
      throw Exception('Failed to create connected account');
    } on DioException catch (e) {
      final detail = e.response?.data is Map ? e.response!.data['detail'] : null;
      throw Exception(detail ?? 'Could not set up payment account.');
    }
  }

  /// Gets the Stripe onboarding link for the freelancer
  Future<String> getOnboardingLink({required String refreshUrl, required String returnUrl}) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not logged in');

      final response = await _dio.post(
        '/payments/connect/onboarding-link',
        data: {
          'refresh_url': refreshUrl,
          'return_url': returnUrl,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data['url'] != null) {
        return response.data['url'];
      }
      throw Exception('Failed to get onboarding link');
    } on DioException catch (e) {
      final detail = e.response?.data is Map ? e.response!.data['detail'] : null;
      throw Exception(detail ?? 'Could not get onboarding link.');
    }
  }
}
