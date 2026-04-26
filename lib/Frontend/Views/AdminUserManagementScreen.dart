import 'package:flutter/material.dart';

class AdminUserManagementScreen extends StatelessWidget {
  const AdminUserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3E2723)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'User Management',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3E2723),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  hintStyle: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
          ),

          // User List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildUserCard(
                  name: 'Sarah Johnson',
                  email: 'sarah@example.com',
                  role: 'Freelancer',
                  joined: 'Jan 15, 2026',
                  orders: '124',
                  status: 'Active',
                  initials: 'SJ',
                ),
                _buildUserCard(
                  name: 'John Doe',
                  email: 'john@example.com',
                  role: 'Customer',
                  joined: 'Feb 20, 2026',
                  orders: '8',
                  status: 'Active',
                  initials: 'JD',
                ),
                _buildUserCard(
                  name: 'Mike Chen',
                  email: 'mike@example.com',
                  role: 'Freelancer',
                  joined: 'Mar 5, 2026',
                  orders: '56',
                  status: 'Suspended',
                  initials: 'MC',
                ),
                _buildUserCard(
                  name: 'Emma Rodriguez',
                  email: 'emma@example.com',
                  role: 'Freelancer',
                  joined: 'Jan 28, 2026',
                  orders: '203',
                  status: 'Active',
                  initials: 'ER',
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard({
    required String name,
    required String email,
    required String role,
    required String joined,
    required String orders,
    required String status,
    required String initials,
  }) {
    bool isSuspended = status == 'Suspended';

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
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E5D8),
                  borderRadius: BorderRadius.circular(25),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    Text(
                      email,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_vert, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn('Role', role),
              _buildInfoColumn('Joined', joined),
              _buildInfoColumn('Orders', orders),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isSuspended ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: isSuspended ? Colors.red : Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSuspended ? const Color(0xFFF9F6F2) : const Color(0xFFFFEBEE),
                  foregroundColor: isSuspended ? const Color(0xFF3E2723) : Colors.red,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isSuspended)
                      const Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: Icon(Icons.block, size: 14),
                      ),
                    Text(
                      isSuspended ? 'Activate' : 'Suspend',
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF3E2723),
          ),
        ),
      ],
    );
  }
}
