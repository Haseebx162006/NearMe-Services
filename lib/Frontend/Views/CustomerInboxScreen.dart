import 'package:flutter/material.dart';
import '../Theme/app_colors.dart';

class CustomerInboxScreen extends StatefulWidget {
  const CustomerInboxScreen({super.key});

  @override
  State<CustomerInboxScreen> createState() => _CustomerInboxScreenState();
}

class _CustomerInboxScreenState extends State<CustomerInboxScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Messages tab
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
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Header: Title and Top Icons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Messages',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3E2723),
                        ),
                      ),
                      Text(
                        '3 unread messages',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E5D8).withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.search,
                          color: Color(0xFF4E342E),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E5D8).withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit_note,
                          color: Color(0xFF4E342E),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildTab('All', true),
                  const SizedBox(width: 12),
                  _buildTab('Unread', false),
                  const SizedBox(width: 12),
                  _buildTab('Active Orders', false),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Message List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildMessageTile(
                    initials: 'SJ',
                    name: 'Sarah Johnson',
                    service: 'House Cleaning',
                    message: "Saturday at 2 PM works perfectly! I'll bri...",
                    time: '10:35 AM',
                    status: 'ACTIVE',
                    unreadCount: 2,
                    avatarColor: const Color(0xFFBCA073),
                    isOnline: true,
                  ),
                  _buildMessageTile(
                    initials: 'MC',
                    name: 'Mike Chen',
                    service: 'Tech Repair',
                    message: "Voice message · 0:23",
                    time: 'Yesterday',
                    isVoice: true,
                    avatarColor: const Color(0xFF4E342E),
                    isOnline: true,
                    isRead: true,
                  ),
                  _buildMessageTile(
                    initials: 'ER',
                    name: 'Emma Rodriguez',
                    service: 'Hair Styling',
                    message: "Sent a photo",
                    time: 'Yesterday',
                    isPhoto: true,
                    unreadCount: 1,
                    avatarColor: const Color(0xFF8B5E3C),
                  ),
                  _buildMessageTile(
                    initials: 'DW',
                    name: 'David Williams',
                    service: 'Plumbing',
                    message: "I can fix that pipe issue by Thursday, no pro...",
                    time: 'Mon',
                    isRead: true,
                    avatarColor: const Color(0xFF5D4037),
                  ),
                  _buildMessageTile(
                    initials: 'AP',
                    name: 'Aisha Patel',
                    service: 'Tutoring',
                    message: "Your session is confirmed for Friday 6 PM!",
                    time: 'Mon',
                    status: 'ACTIVE',
                    isRead: true,
                    avatarColor: const Color(0xFFA1887F),
                    isOnline: true,
                  ),
                  _buildMessageTile(
                    initials: 'JL',
                    name: 'James Liu',
                    service: 'Electrical Work',
                    message: "The estimate is \$120 for the full wiring job.",
                    time: 'Sun',
                    isRead: true,
                    avatarColor: const Color(0xFF795548),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF4E342E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? Colors.transparent : AppColors.border,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isActive ? Colors.white : AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildMessageTile({
    required String initials,
    required String name,
    required String service,
    required String message,
    required String time,
    String? status,
    int unreadCount = 0,
    bool isOnline = false,
    bool isVoice = false,
    bool isPhoto = false,
    bool isRead = false,
    required Color avatarColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF1F2F4), width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: avatarColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              if (isOnline)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (status != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E5D8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFBCA073),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  service,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (isRead) ...[
                      const Icon(
                        Icons.done_all,
                        color: Color(0xFFBCA073),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                    ],
                    if (isVoice) ...[
                      const Icon(
                        Icons.mic,
                        color: AppColors.textSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                    ],
                    if (isPhoto) ...[
                      const Icon(
                        Icons.image_outlined,
                        color: AppColors.textSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Expanded(
                      child: Text(
                        message,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: unreadCount > 0
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontWeight: unreadCount > 0
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Time and Batch
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 8),
              if (unreadCount > 0)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF3E2723),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
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
