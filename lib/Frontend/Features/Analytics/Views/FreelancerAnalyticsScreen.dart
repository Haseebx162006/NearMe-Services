import 'package:flutter/material.dart';

class FreelancerAnalyticsScreen extends StatelessWidget {
  const FreelancerAnalyticsScreen({super.key});

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
                'Analytics',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2723),
                ),
              ),
              const Text(
                'Track your performance',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),

              // Stats Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.3,
                children: [
                  _buildStatCard('Total Views', '2,832', '+12%', Icons.visibility_outlined),
                  _buildStatCard('Avg Rating', '4.8', '+0.2', Icons.star_outline),
                  _buildStatCard('Revenue', '\$2,450', '+18%', Icons.attach_money),
                  _buildStatCard('Growth', '+23%', 'vs last month', Icons.trending_up, isGrowth: true),
                ],
              ),

              const SizedBox(height: 30),

              // Monthly Earnings Chart
              _buildChartSection(
                title: 'Monthly Earnings',
                child: CustomPaint(
                  size: const Size(double.infinity, 200),
                  painter: BarChartPainter(),
                ),
              ),

              const SizedBox(height: 20),

              // Order Trends Chart
              _buildChartSection(
                title: 'Order Trends',
                child: CustomPaint(
                  size: const Size(double.infinity, 200),
                  painter: LineChartPainter(),
                ),
              ),

              const SizedBox(height: 20),

              // Top Performing Gigs
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Top Performing Gigs',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildGigRow('Professional House Cleaning', '124 orders', '\$1,240'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1),
                    ),
                    _buildGigRow('Deep Cleaning Service', '89 orders', '\$890'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1),
                    ),
                    _buildGigRow('Office Cleaning', '45 orders', '\$450'),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 4, // Analytics tab
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

  Widget _buildStatCard(String label, String value, String subtext, IconData icon, {bool isGrowth = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: const Color(0xFFC7A76D), size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2723),
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.grey),
              ),
              Text(
                subtext,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: isGrowth ? const Color(0xFF8D6E63) : const Color(0xFFC7A76D),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
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
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildGigRow(String name, String orders, String revenue) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF3E2723),
              ),
            ),
            Text(
              orders,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        Text(
          revenue,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFFC7A76D),
          ),
        ),
      ],
    );
  }
}

class BarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFC7A76D);
    final axisPaint = Paint()..color = Colors.grey.withOpacity(0.3)..strokeWidth = 1;
    
    // Draw Axis
    canvas.drawLine(Offset(30, size.height - 30), Offset(size.width, size.height - 30), axisPaint);
    canvas.drawLine(Offset(30, 0), Offset(30, size.height - 30), axisPaint);

    double barWidth = (size.width - 60) / 4 - 20;
    List<double> values = [0.4, 0.7, 0.6, 0.9]; // Normalised
    List<String> labels = ['Jan', 'Feb', 'Mar', 'Apr'];

    for (int i = 0; i < 4; i++) {
        double x = 50 + i * (barWidth + 20);
        double h = values[i] * (size.height - 50);
        Rect rect = Rect.fromLTWH(x, size.height - 30 - h, barWidth, h);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), paint);
        
        // Draw Label
        TextPainter(
            text: TextSpan(text: labels[i], style: const TextStyle(color: Colors.grey, fontSize: 10)),
            textDirection: TextDirection.ltr,
        )..layout()..paint(canvas, Offset(x + barWidth/4, size.height - 25));
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF4E342E)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final dotPaint = Paint()..color = const Color(0xFFC7A76D);
    final axisPaint = Paint()..color = Colors.grey.withOpacity(0.3)..strokeWidth = 1;

    canvas.drawLine(Offset(30, size.height - 30), Offset(size.width, size.height - 30), axisPaint);
    
    List<Offset> points = [
        Offset(50, size.height - 60),
        Offset(size.width * 0.4, size.height - 100),
        Offset(size.width * 0.7, size.height - 80),
        Offset(size.width - 20, size.height - 130),
    ];

    Path path = Path()..moveTo(points[0].dx, points[0].dy);
    for (var i = 1; i < points.length; i++) {
        path.quadraticBezierTo(
            (points[i-1].dx + points[i].dx) / 2,
            points[i-1].dy,
            points[i].dx,
            points[i].dy
        );
    }
    canvas.drawPath(path, linePaint);

    for (var p in points) {
        canvas.drawCircle(p, 4, dotPaint);
    }
    
    List<String> labels = ['Jan', 'Feb', 'Mar', 'Apr'];
    for(int i=0; i<4; i++) {
        TextPainter(
            text: TextSpan(text: labels[i], style: const TextStyle(color: Colors.grey, fontSize: 10)),
            textDirection: TextDirection.ltr,
        )..layout()..paint(canvas, Offset(points[i].dx - 10, size.height - 25));
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
