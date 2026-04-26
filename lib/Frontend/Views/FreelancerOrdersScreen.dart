import 'package:flutter/material.dart';

class FreelancerOrdersScreen extends StatelessWidget {
  const FreelancerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F6),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Orders',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  Text(
                    'Manage your bookings',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Orders List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildOrderCard(
                    clientName: 'John D.',
                    service: 'House Cleaning',
                    dateTime: 'Apr 25, 2026 at 2:00 PM',
                    amount: '\$45',
                    requirements: '3-bedroom apartment, deep cleaning needed',
                    status: 'Pending',
                    statusColor: const Color(0xFFF3E5D8),
                    statusTextColor: const Color(0xFFC7A76D),
                    actions: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.close, size: 18),
                            label: const Text('Decline'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD32F2F),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('Accept'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC7A76D),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildOrderCard(
                    clientName: 'Lisa M.',
                    service: 'House Cleaning',
                    dateTime: 'Apr 24, 2026 at 10:00 AM',
                    amount: '\$45',
                    requirements: 'Regular cleaning, 2-bedroom',
                    status: 'Accepted',
                    statusColor: const Color(0xFFE8F5E9),
                    statusTextColor: Colors.green,
                    actions: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4E342E),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Mark as Completed', style: TextStyle(fontFamily: 'Poppins')),
                      ),
                    ),
                  ),
                  _buildOrderCard(
                    clientName: 'Robert K.',
                    service: 'House Cleaning',
                    dateTime: 'Apr 23, 2026 at 3:00 PM',
                    amount: '\$45',
                    requirements: 'Move-out cleaning',
                    status: 'Completed',
                    statusColor: const Color(0xFFF5E6D3),
                    statusTextColor: const Color(0xFF3E2723),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Orders tab
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4E342E),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: 'Gigs'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Analyse'),
        ],
      ),
    );
  }

  Widget _buildOrderCard({
    required String clientName,
    required String service,
    required String dateTime,
    required String amount,
    required String requirements,
    required String status,
    required Color statusColor,
    required Color statusTextColor,
    Widget? actions,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    clientName,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  Text(
                    service,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: statusTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Date & Time', dateTime),
          const SizedBox(height: 8),
          _buildInfoRow('Amount', amount, isPrice: true),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F6F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Requirements:',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  requirements,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Color(0xFF3E2723),
                  ),
                ),
              ],
            ),
          ),
          if (actions != null) ...[
            const SizedBox(height: 20),
            actions,
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isPrice = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: isPrice ? FontWeight.bold : FontWeight.w500,
            color: isPrice ? const Color(0xFFC7A76D) : const Color(0xFF3E2723),
          ),
        ),
      ],
    );
  }
}
