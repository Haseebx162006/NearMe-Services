import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'analytics_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  final String userId;

  const AnalyticsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalEarningsAsync = ref.watch(totalEarningsProvider(userId));
    final monthlyEarningsAsync = ref.watch(monthlyEarningsProvider(userId));
    final totalOrdersAsync = ref.watch(totalOrdersProvider(userId));

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F6),
      appBar: AppBar(
        title: const Text(
          'Analytics Overview',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFF3E2723),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF3E2723)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildAsyncCard(
              title: 'Total Earnings',
              icon: Icons.attach_money,
              asyncValue: totalEarningsAsync,
              parser: (val) => '\$${val.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 16),
            _buildAsyncCard(
              title: 'Monthly Earnings',
              icon: Icons.calendar_today,
              asyncValue: monthlyEarningsAsync,
              parser: (val) => '\$${val.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 16),
            _buildAsyncCard(
              title: 'Total Orders',
              icon: Icons.shopping_bag_outlined,
              asyncValue: totalOrdersAsync,
              parser: (val) => val.toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAsyncCard<T>({
    required String title,
    required IconData icon,
    required AsyncValue<T> asyncValue,
    required String Function(T) parser,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFC7A76D).withOpacity(0.2),
            radius: 24,
            child: Icon(icon, color: const Color(0xFFC7A76D)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                asyncValue.when(
                  data: (data) => Text(
                    parser(data),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  loading: () => const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (e, _) => Text(
                    'Error loading data',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
