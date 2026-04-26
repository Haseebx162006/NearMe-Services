import 'package:flutter/material.dart';
import '../Theme/app_colors.dart';

class CustomerOrderHistoryScreen extends StatefulWidget {
  const CustomerOrderHistoryScreen({super.key});

  @override
  State<CustomerOrderHistoryScreen> createState() => _CustomerOrderHistoryScreenState();
}

class _CustomerOrderHistoryScreenState extends State<CustomerOrderHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      appBar: AppBar(
        title: const Text(
          'Order History',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3E2723),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3, // Assuming this is under Profile/Account tab
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4E342E),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildOrderCard(
            title: 'Professional House Cleaning',
            provider: 'Sarah Johnson',
            date: 'Apr 20, 2026',
            amount: '\$47.25',
            status: 'Completed',
            statusColor: AppColors.success,
          ),
          _buildOrderCard(
            title: 'Laptop & PC Repair',
            provider: 'Mike Chen',
            date: 'Apr 18, 2026',
            amount: '\$62.25',
            status: 'Pending',
            statusColor: AppColors.warning,
          ),
          _buildOrderCard(
            title: 'Hair Styling at Home',
            provider: 'Emma Rodriguez',
            date: 'Apr 15, 2026',
            amount: '\$37.00',
            status: 'Completed',
            statusColor: AppColors.success,
          ),
          _buildOrderCard(
            title: 'Home Plumbing Services',
            provider: 'David Williams',
            date: 'Apr 10, 2026',
            amount: '\$82.50',
            status: 'Cancelled',
            statusColor: AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard({
    required String title,
    required String provider,
    required String date,
    required String amount,
    required String status,
    required Color statusColor,
  }) {
    IconData statusIcon;
    switch (status) {
      case 'Completed':
        statusIcon = Icons.check_circle_outline;
        break;
      case 'Pending':
        statusIcon = Icons.access_time;
        break;
      case 'Cancelled':
        statusIcon = Icons.cancel_outlined;
        break;
      default:
        statusIcon = Icons.help_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            provider,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppColors.textHint,
                ),
              ),
              Text(
                amount,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
