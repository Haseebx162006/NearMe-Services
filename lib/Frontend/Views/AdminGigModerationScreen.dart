import 'package:flutter/material.dart';

class AdminGigModerationScreen extends StatelessWidget {
  const AdminGigModerationScreen({super.key});

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
          'Gig Moderation',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3E2723),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              '2 gigs pending review',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildModerationCard(
                  title: 'Expert Plumbing Services',
                  freelancer: 'David Williams',
                  category: 'Repair',
                  price: '\$80',
                  submitted: 'Apr 22, 2026',
                  description: 'Professional plumbing services with 10+ years experience. Available for emergencies.',
                  imageUrl: 'https://images.unsplash.com/photo-1581094794329-c811ce198ab1?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                ),
                _buildModerationCard(
                  title: 'Mobile Car Wash',
                  freelancer: 'Alex Thompson',
                  category: 'Cleaning',
                  price: '\$35',
                  submitted: 'Apr 23, 2026',
                  description: 'Professional car washing and detailing at your location.',
                  imageUrl: 'https://images.unsplash.com/photo-1520339810219-2bcc48b2a8ed?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModerationCard({
    required String title,
    required String freelancer,
    required String category,
    required String price,
    required String submitted,
    required String description,
    required String imageUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
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
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(
              imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                color: Colors.grey[200],
                child: const Icon(Icons.image, size: 50, color: Colors.grey),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
                Text(
                  'by $freelancer',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetaColumn('Category', category),
                    _buildMetaColumn('Price', price),
                    _buildMetaColumn('Submitted', submitted),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F6F2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Color(0xFF3E2723),
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Reject'),
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
                        label: const Text('Approve'),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaColumn(String label, String value) {
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
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF3E2723),
          ),
        ),
      ],
    );
  }
}
