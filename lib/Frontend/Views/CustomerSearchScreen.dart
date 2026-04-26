import 'package:flutter/material.dart';
import '../Theme/app_colors.dart';

class CustomerSearchScreen extends StatefulWidget {
  const CustomerSearchScreen({super.key});

  @override
  State<CustomerSearchScreen> createState() => _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends State<CustomerSearchScreen> {
  double _searchRadius = 7.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Search tab
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4E342E),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Map Mockup (Using a CustomPainter or Grid container to simulate the map in your image)
          Positioned.fill(
            child: Container(
              color: const Color(0xFFEFE6D5), // Base map color
              child: CustomPaint(painter: MapGridPainter()),
            ),
          ),

          // 2. Map Elements (Markers and Radius)
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Radius Circle (Dashed)
                CustomPaint(
                  size: const Size(300, 300),
                  painter: RadiusCirclePainter(),
                ),

                // Center Blue Dot (User Location)
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A49E2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4A49E2).withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),

                // Freelancer Marker SJ
                Positioned(
                  left: 60,
                  top: 150,
                  child: _buildMapMarker('SJ', const Color(0xFFBCA073)),
                ),

                // Freelancer Marker MC
                Positioned(
                  right: 40,
                  top: 80,
                  child: _buildMapMarker('MC', const Color(0xFF4E342E)),
                ),

                // Freelancer Marker ER
                Positioned(
                  left: 20,
                  top: 100,
                  child: _buildMapMarker('ER', const Color(0xFF8B5E3C)),
                ),
              ],
            ),
          ),

          // 3. Top Search Controls
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: AppColors.textHint, size: 20),
                        SizedBox(width: 12),
                        Text(
                          'Search freelancers or skills...',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: AppColors.textHint,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.tune,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // 4. Map Action Buttons
          Positioned(
            right: 20,
            top: 150,
            child: Column(
              children: [
                _buildMapActionButton(Icons.add),
                const SizedBox(height: 8),
                _buildMapActionButton(Icons.remove),
              ],
            ),
          ),

          Positioned(
            right: 20,
            bottom: 180,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.near_me_outlined,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
          ),

          // 5. Bottom Radius Slider Overlay
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Search Radius',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${_searchRadius.toInt()} km',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFFBCA073),
                      inactiveTrackColor: const Color(0xFFF3E5D8),
                      thumbColor: const Color(0xFFBCA073),
                      overlayColor: const Color(0xFFBCA073).withOpacity(0.2),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: _searchRadius,
                      min: 1,
                      max: 20,
                      onChanged: (val) => setState(() => _searchRadius = val),
                    ),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '1km',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.circle, size: 8, color: Color(0xFFBCA073)),
                          SizedBox(width: 4),
                          Text(
                            '3 freelancers found',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: Color(0xFF4E342E),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '20km',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapMarker(String initials, Color color) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            initials,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        Positioned(
          top: -2,
          right: -2,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A), // Green active dot
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapActionButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5),
        ],
      ),
      child: Icon(icon, color: AppColors.textPrimary, size: 20),
    );
  }
}

class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD6C8B4).withOpacity(0.3)
      ..strokeWidth = 1;

    const double step = 60.0;

    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    // Simulating the green highlighted area
    final greenPaint = Paint()
      ..color = const Color(0xFFD1E2C4).withOpacity(0.6);
    canvas.drawRect(const Rect.fromLTWH(0, 420, 120, 120), greenPaint);
    canvas.drawRect(const Rect.fromLTWH(240, 720, 120, 120), greenPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RadiusCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4E342E).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Dashed circle
    const double dashWidth = 5;
    const double dashSpace = 5;
    double startAngle = 0;

    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2,
    );

    while (startAngle < 2 * 3.14159) {
      canvas.drawArc(
        rect,
        startAngle,
        dashWidth / (size.width / 2),
        false,
        paint,
      );
      startAngle += (dashWidth + dashSpace) / (size.width / 2);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
