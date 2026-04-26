import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Admin Dashboard',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2723),
                ),
              ),
              const Text(
                'NearMe Services Platform',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),

              // Primary KPI Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.3,
                children: [
                  _buildKpiCard(
                    'Total Users',
                    '12,450',
                    const Color(0xFF4E342E),
                    Colors.white,
                    Icons.people_outline,
                  ),
                  _buildKpiCard(
                    'Active Gigs',
                    '2,340',
                    const Color(0xFFC7A76D),
                    Colors.white,
                    Icons.work_outline,
                  ),
                  _buildKpiCard(
                    'Orders Today',
                    '156',
                    const Color(0xFFF3E5D8),
                    const Color(0xFF3E2723),
                    Icons.shopping_bag_outlined,
                  ),
                  _buildKpiCard(
                    'Revenue',
                    '\$45,890',
                    const Color(0xFFDCC196),
                    const Color(0xFF3E2723),
                    Icons.attach_money,
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // Secondary Metrics Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.8,
                children: [
                  _buildMetricCard(
                    'Pending Gigs',
                    '23',
                    const Color(0xFFC7A76D),
                  ),
                  _buildMetricCard(
                    'Growth (30d)',
                    '+18%',
                    const Color(0xFFC7A76D),
                  ),
                  _buildMetricCard(
                    'Avg Order Value',
                    '\$52',
                    const Color(0xFFC7A76D),
                  ),
                  _buildMetricCard(
                    'Platform Fee',
                    '\$2,295',
                    const Color(0xFFC7A76D),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Shortcut Navigation
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.8,
                children: [
                  _buildShortcutCard(
                    'Users',
                    'Manage accounts',
                    Icons.people_outline,
                  ),
                  _buildShortcutCard(
                    'Gigs',
                    'Review & moderate',
                    Icons.work_outline,
                  ),
                  _buildShortcutCard(
                    'Orders',
                    'Track transactions',
                    Icons.shopping_bag_outlined,
                  ),
                  _buildShortcutCard(
                    'Analytics',
                    'View insights',
                    Icons.trending_up,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Recent Activity Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildActivityItem(
                      'New user registered:',
                      'john@example.com',
                      '2 min ago',
                    ),
                    _buildActivityItem(
                      'Gig pending approval:',
                      '\'Expert Plumbing\'',
                      '15 min ago',
                    ),
                    _buildActivityItem(
                      'Order #1234 completed successfully',
                      '',
                      '32 min ago',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard(
    String label,
    String value,
    Color bgColor,
    Color textColor,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: textColor.withOpacity(0.8), size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: textColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutCard(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF3E2723), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String detail, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: const BoxDecoration(
              color: Color(0xFFF3E5D8),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.circle, size: 8, color: Color(0xFFC7A76D)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: Color(0xFF3E2723),
                    ),
                    children: [
                      TextSpan(text: '$title '),
                      if (detail.isNotEmpty)
                        TextSpan(
                          text: detail,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
