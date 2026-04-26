import 'package:flutter/material.dart';

class FreelancerGigsScreen extends StatelessWidget {
  const FreelancerGigsScreen({super.key});

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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'My Gigs',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3E2723),
                        ),
                      ),
                      const Text(
                        '4 of 5 gigs',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF4E342E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),

            // Gigs List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildGigCard(
                    title: 'Professional House Cleaning',
                    price: '\$45',
                    status: 'Active',
                    views: '1240',
                    orders: '124',
                    statusBackgroundColor: const Color(0xFFE8F5E9),
                    statusTextColor: Colors.green,
                  ),
                  _buildGigCard(
                    title: 'Deep Cleaning Service',
                    price: '\$65',
                    status: 'Active',
                    views: '856',
                    orders: '89',
                    statusBackgroundColor: const Color(0xFFE8F5E9),
                    statusTextColor: Colors.green,
                  ),
                  _buildGigCard(
                    title: 'Office Cleaning',
                    price: '\$80',
                    status: 'Suspended',
                    views: '432',
                    orders: '45',
                    statusBackgroundColor: const Color(0xFFFFEBEE),
                    statusTextColor: Colors.red,
                  ),
                  _buildGigCard(
                    title: 'Move-in/out Cleaning',
                    price: '\$120',
                    status: 'Under Review',
                    views: '234',
                    orders: '12',
                    statusBackgroundColor: const Color(0xFFFFF3E0),
                    statusTextColor: Colors.orange,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Gigs tab
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

  Widget _buildGigCard({
    required String title,
    required String price,
    required String status,
    required String views,
    required String orders,
    required Color statusBackgroundColor,
    required Color statusTextColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
              ),
              const Icon(Icons.more_vert, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              color: Color(0xFFC7A76D),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: statusBackgroundColor,
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
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.visibility_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '$views views',
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(width: 20),
              Text(
                '$orders orders',
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3E5D8),
                    foregroundColor: const Color(0xFF4E342E),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4E342E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'View Stats',
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
