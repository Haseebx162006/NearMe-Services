import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'analytics_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsProvider);

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
      body: analyticsAsync.when(
        data: (analytics) => RefreshIndicator(
          onRefresh: () => ref.refresh(analyticsProvider.future),
          color: const Color(0xFF4E342E),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildStatCard(
                  title: 'Total Earnings',
                  icon: Icons.attach_money,
                  value: '\$${analytics.totalEarnings.toStringAsFixed(2)}',
                  color: const Color(0xFFC7A76D),
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  title: 'Monthly Earnings',
                  icon: Icons.calendar_today,
                  value: '\$${analytics.monthEarnings.toStringAsFixed(2)}',
                  color: const Color(0xFF8B5E3C),
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  title: 'Total Orders',
                  icon: Icons.shopping_bag_outlined,
                  value: analytics.totalOrders.toString(),
                  color: const Color(0xFF4E342E),
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  title: 'Pending Orders',
                  icon: Icons.access_time,
                  value: analytics.pendingOrders.toString(),
                  color: Colors.orange,
                ),
                
                if (analytics.recentOrders.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...analytics.recentOrders.map((order) => _buildRecentOrderTile(order)),
                ],
              ],
            ),
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF4E342E)),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Error: $err',
                style: const TextStyle(fontFamily: 'Poppins', color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(analyticsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required IconData icon,
    required String value,
    required Color color,
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
            backgroundColor: color.withOpacity(0.1),
            radius: 24,
            child: Icon(icon, color: color),
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
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRecentOrderTile(RecentOrder order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3E5D8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.serviceName,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                order.customerName,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Text(
            '\$${order.amount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: Color(0xFF4E342E),
            ),
          ),
        ],
      ),
    );
  }
}
