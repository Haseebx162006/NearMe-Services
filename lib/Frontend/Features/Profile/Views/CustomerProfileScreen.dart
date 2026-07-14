import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Auth/ViewModel/authViewModel.dart';
import '../../../Theme/app_colors.dart';
import '../../Auth/View/LoginScreen.dart';
import '../../Orders/Views/CustomerOrderHistoryScreen.dart';
import 'CustomerSettingsScreen.dart';

class CustomerProfileScreen extends ConsumerWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authprovider);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFF3E2723),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Not logged in.'));
          }
          final initials = user.name
              .split(' ')
              .map((e) => e.isNotEmpty ? e[0] : '')
              .take(2)
              .join('')
              .toUpperCase();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF4E342E),
                    backgroundImage: user.profilePicture != null
                        ? NetworkImage(user.profilePicture!)
                        : null,
                    child: user.profilePicture == null
                        ? Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
                Text(
                  user.email,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                _buildProfileOption(
                  Icons.phone_outlined,
                  'Phone',
                  user.phoneNumber,
                ),
                if (user.location != null)
                  _buildProfileOption(
                    Icons.location_on_outlined,
                    'Location',
                    'Lat: ${user.location!.coordinates[1].toStringAsFixed(2)}, Lng: ${user.location!.coordinates[0].toStringAsFixed(2)} · ${user.preferredRadiusKm} km radius',
                  )
                else
                  _buildProfileOption(
                    Icons.location_on_outlined,
                    'Location',
                    'Location not set',
                  ),
                _buildProfileOption(
                  Icons.account_balance_wallet_outlined,
                  'Wallet',
                  '\$${user.wallet.toStringAsFixed(2)}',
                ),

                _buildProfileOption(
                  Icons.settings_outlined,
                  'Settings',
                  'Notifications, privacy',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CustomerSettingsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    ref.read(authprovider.notifier).logout().then((_) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Loginscreen(),
                        ),
                      );
                    });
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Error loading profile: \$error')),
      ),
    );
  }

  Widget _buildProfileOption(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFBCA073)),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          color: Color(0xFF3E2723),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontFamily: 'Poppins',
          color: AppColors.textSecondary,
        ),
      ),
      trailing: onTap != null
          ? const Icon(Icons.chevron_right, color: AppColors.textHint)
          : null,
      onTap: onTap,
    );
  }
}
