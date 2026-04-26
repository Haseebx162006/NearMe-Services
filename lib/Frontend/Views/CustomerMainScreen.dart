import 'package:flutter/material.dart';
import '../Theme/app_colors.dart';
import '../Components/social_button.dart';

class CustomerMainScreen extends StatefulWidget {
  const CustomerMainScreen({super.key});

  @override
  State<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends State<CustomerMainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4E342E),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header: Location and Notifications
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Color(0xFFBCA073), size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Downtown · 10 km radius',
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Good morning, Alex 👋',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3E2723)),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: AppColors.border)),
                        child: const Icon(Icons.notifications_none, color: AppColors.textPrimary),
                      ),
                      const SizedBox(width: 12),
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFF4E342E),
                        child: Text('AJ', style: TextStyle(color: Colors.white, fontSize: 14)),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 24),

              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppColors.textHint),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'What service do you need?',
                        style: TextStyle(fontFamily: 'Poppins', color: AppColors.textHint),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: const Color(0xFFF3E5D8), borderRadius: BorderRadius.circular(12)),
                      child: const Text('Search', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Color(0xFF4E342E))),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Stats Box
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFF4E342E), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(Icons.bolt, '48', 'Active Now'),
                    _buildStatDivider(),
                    _buildStatItem(Icons.access_time, '~8 min', 'Avg Response'),
                    _buildStatDivider(),
                    _buildStatItem(Icons.verified_user_outlined, '100%', 'Verified'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Categories
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Categories', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                ],
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryItem('All', Icons.bolt, true),
                    const SizedBox(width: 12),
                    _buildCategoryItem('Cleaning', Icons.cleaning_services_outlined, false),
                    const SizedBox(width: 12),
                    _buildCategoryItem('Repair', Icons.build_outlined, false),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Promo Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFBCA073), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.stars, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('New User Offer 🎊', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.white)),
                          Text('Get 20% off your first booking', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.white)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
                      child: const Row(
                        children: [
                          Text('Claim', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
                          Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Featured Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Featured', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                  TextButton(
                    onPressed: () {},
                    child: const Row(
                      children: [
                        Text('View all', style: TextStyle(fontFamily: 'Poppins', color: Color(0xFFBCA073))),
                        Icon(Icons.chevron_right, color: Color(0xFFBCA073), size: 20),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Big Featured Card
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1581578731522-99459173d8ff?q=80&w=1000&auto=format&fit=crop',
                          height: 240,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                              color: const Color(0xFFBCA073),
                              borderRadius: BorderRadius.circular(12)),
                          child: const Row(
                            children: [
                              Icon(Icons.star, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text('Top Pick',
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              shape: BoxShape.circle),
                          child: const Icon(Icons.favorite_border,
                              color: Colors.white, size: 20),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.8),
                                  Colors.transparent
                                ]),
                            borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(24),
                                bottomRight: Radius.circular(24)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Professional House Cleaning',
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              const Text('Deep clean · Same-day available',
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.white70,
                                      fontSize: 12)),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const CircleAvatar(
                                          radius: 12,
                                          backgroundColor: Colors.white,
                                          child: Text('SJ',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xFF4E342E)))),
                                      const SizedBox(width: 8),
                                      const Text('Sarah Johnson',
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              color: Colors.white,
                                              fontSize: 12)),
                                      const SizedBox(width: 12),
                                      const Icon(Icons.star,
                                          color: Color(0xFFBCA073), size: 14),
                                      const Text(' 4.8 (124)',
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              color: Colors.white,
                                              fontSize: 12)),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: Colors.white30)),
                                    child: const Text('\$45/hr',
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      )
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFBCA073), size: 20),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(fontFamily: 'Poppins', color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(height: 30, width: 1, color: Colors.white24);
  }

  Widget _buildCategoryItem(String label, IconData icon, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF4E342E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isActive ? Colors.transparent : AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: isActive ? const Color(0xFFBCA073) : Colors.grey, size: 20),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontFamily: 'Poppins', color: isActive ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
