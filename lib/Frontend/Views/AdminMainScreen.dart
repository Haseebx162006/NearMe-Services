import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:near_me/Frontend/Features/Auth/ViewModel/authViewModel.dart';
import 'package:near_me/Frontend/Features/Auth/View/LoginScreen.dart';
import 'package:near_me/Frontend/Views/AdminDashboardScreen.dart';
import 'package:near_me/Frontend/Views/AdminUserManagementScreen.dart';
import 'package:near_me/Frontend/Views/AdminGigModerationScreen.dart';
import 'package:near_me/Frontend/Views/AdminOrdersPaymentsScreen.dart';

class AdminTabEntry {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final Widget screen;

  const AdminTabEntry({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.screen,
  });
}

class AdminMainScreen extends ConsumerStatefulWidget {
  const AdminMainScreen({super.key});

  @override
  ConsumerState<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends ConsumerState<AdminMainScreen> {
  int _currentIndex = 0;

  static final Map<int, AdminTabEntry> _tabMap = {
    0: const AdminTabEntry(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      screen: AdminDashboardScreen(),
    ),
    1: const AdminTabEntry(
      label: 'Users',
      icon: Icons.people_outline,
      activeIcon: Icons.people,
      screen: AdminUserManagementScreen(),
    ),
    2: const AdminTabEntry(
      label: 'Gigs',
      icon: Icons.work_outline,
      activeIcon: Icons.work,
      screen: AdminGigModerationScreen(),
    ),
    3: const AdminTabEntry(
      label: 'Orders',
      icon: Icons.shopping_bag_outlined,
      activeIcon: Icons.shopping_bag,
      screen: AdminOrdersPaymentsScreen(),
    ),
  };

  void _onTabSelected(int index) {
    if (_tabMap.containsKey(index)) {
      setState(() => _currentIndex = index);
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Logout',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authprovider.notifier).logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const Loginscreen()),
                  (_) => false,
                );
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(fontFamily: 'Poppins', color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentTab = _tabMap[_currentIndex]!;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabMap.values.map((entry) => entry.screen).toList(),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ..._tabMap.entries.map((entry) {
                  final isActive = entry.key == _currentIndex;
                  final tab = entry.value;
                  return _NavBarItem(
                    icon: isActive ? tab.activeIcon : tab.icon,
                    label: tab.label,
                    isActive: isActive,
                    onTap: () => _onTabSelected(entry.key),
                  );
                }),
                _NavBarItem(
                  icon: Icons.logout,
                  label: 'Logout',
                  isActive: false,
                  onTap: _handleLogout,
                  isLogout: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isLogout;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isLogout
        ? Colors.red
        : isActive
            ? const Color(0xFF4E342E)
            : Colors.grey;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
