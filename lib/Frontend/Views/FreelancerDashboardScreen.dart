import 'package:flutter/material.dart';


class FreelancerDashboardScreen extends StatelessWidget {
  const FreelancerDashboardScreen({super.key});

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
                'Dashboard',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2723), // Dark brown from reference
                ),
              ),
              const Text(
                'Welcome back, Sarah!',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),

              // Summary Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.2,
                children: [
                   _buildSummaryCard(
                    icon: Icons.attach_money,
                    label: 'Total Earnings',
                    value: '\$2,450',
                    color: const Color(0xFFC7A76D), // Gold/Mustard
                    textColor: Colors.white,
                  ),
                  _buildSummaryCard(
                    icon: Icons.shopping_bag_outlined,
                    label: 'Active Orders',
                    value: '5',
                    color: const Color(0xFF4E342E), // Dark Brown
                    textColor: Colors.white,
                  ),
                  _buildSummaryCard(
                    icon: Icons.trending_up,
                    label: 'This Month',
                    value: '\$890',
                    color: const Color(0xFFF3E5D8), // Light Beige
                    textColor: const Color(0xFF4E342E),
                  ),
                  _buildSummaryCard(
                    icon: Icons.access_time,
                    label: 'Pending',
                    value: '2',
                    color: const Color(0xFFF3E5D8), // Light Beige
                    textColor: const Color(0xFF4E342E),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Recent Orders Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Orders',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4E342E),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Color(0xFFC7A76D),
                      ),
                    ),
                  ),
                ],
              ),

              // Recent Orders List
              _buildOrderCard('John D.', 'House Cleaning', '\$45', 'In Progress', const Color(0xFFFAF3E0)),
              _buildOrderCard('Lisa M.', 'House Cleaning', '\$45', 'Scheduled', const Color(0xFFF5E6D3)),
              _buildOrderCard('Robert K.', 'House Cleaning', '\$45', 'Completed', const Color(0xFFE8F5E9)),

              const SizedBox(height: 20),

              // Boost Visibility Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4E342E), Color(0xFFC7A76D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Boost Your Visibility',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Get featured in search results and attract more customers',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF4E342E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      child: const Text(
                        'Upgrade Now',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
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

  Widget _buildSummaryCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: textColor.withOpacity(0.8), size: 28),
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
                  color: textColor.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(String name, String service, String price, String status, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4E342E),
                ),
              ),
              Text(
                service,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: status == 'Completed' ? Colors.green : const Color(0xFF8D6E63),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Text(
            price,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4E342E),
            ),
          ),
        ],
      ),
    );
  }
}
