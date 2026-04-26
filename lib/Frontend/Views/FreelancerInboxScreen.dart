import 'package:flutter/material.dart';

class FreelancerInboxScreen extends StatelessWidget {
  const FreelancerInboxScreen({super.key});

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Messages',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3E2723),
                        ),
                      ),
                      Row(
                        children: [
                          _buildHeaderIcon(Icons.search),
                          const SizedBox(width: 12),
                          _buildHeaderIcon(Icons.tune),
                        ],
                      ),
                    ],
                  ),
                  const Text(
                    '3 new messages from clients',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Stats Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildStatBox('2', 'Active jobs'),
                  const SizedBox(width: 12),
                  _buildStatBox('3', 'Unread'),
                  const SizedBox(width: 12),
                  _buildStatBox('6', 'Total chats'),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildFilterChip('All', isActive: true),
                  _buildFilterChip('Unread', count: '3'),
                  _buildFilterChip('Active'),
                  _buildFilterChip('Completed'),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Message List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  _buildChatTile(
                    name: 'Alex Johnson',
                    service: 'House Cleaning · Sat May 3, 2PM',
                    message: 'Perfect, confirmed! See you then 🥳',
                    time: '10:36 AM',
                    initials: 'AJ',
                    avatarColor: const Color(0xFF4E342E),
                    isOnline: true,
                    isStarred: true,
                    tag: '\$45/hr',
                  ),
                  _buildChatTile(
                    name: 'Jamie Smith',
                    service: 'Tech Repair — MacBook',
                    message: 'Voice message · 0:12',
                    time: 'Yesterday',
                    initials: 'JS',
                    avatarColor: const Color(0xFF8D6E63),
                    isVoice: true,
                    unreadCount: 2,
                  ),
                  _buildChatTile(
                    name: 'Maria Lopez',
                    service: 'Hair Styling — Inquiry',
                    message: 'Sent a photo',
                    time: 'Yesterday',
                    initials: 'ML',
                    avatarColor: const Color(0xFFBCAAA4),
                    isOnline: true,
                    isImage: true,
                    unreadCount: 1,
                  ),
                  _buildChatTile(
                    name: 'Chris Park',
                    service: 'Deep Clean · Completed',
                    message: 'Thanks so much, great job!',
                    time: 'Mon',
                    initials: 'CP',
                    avatarColor: const Color(0xFF5D4037),
                    tag: '\$90',
                  ),
                  _buildChatTile(
                    name: 'Nina Torres',
                    service: 'Cleaning — Pending Quote',
                    message: 'I\'ll send you the quote shortly.',
                    time: 'Mon',
                    initials: 'NT',
                    avatarColor: const Color(0xFFD7CCC8),
                    isOnline: true,
                    isPending: true,
                  ),
                  _buildChatTile(
                    name: 'Ben Harrison',
                    service: 'Tutoring — Fri 6PM',
                    message: 'Your session is confirmed for Frid...',
                    time: 'Sun',
                    initials: 'BH',
                    avatarColor: const Color(0xFF3E2723),
                    isStarred: true,
                    isPending: true,
                    tag: '\$50/hr',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3, // Messages tab
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
            icon: Icon(Icons.grid_view),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            label: 'Gigs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Analyse',
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5D8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 20, color: const Color(0xFF3E2723)),
    );
  }

  Widget _buildStatBox(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFC7A76D),
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label, {
    bool isActive = false,
    String? count,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF3E2723) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? const Color(0xFF3E2723)
              : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? Colors.white : Colors.grey,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFF3E2723),
                shape: BoxShape.circle,
              ),
              child: Text(
                count,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChatTile({
    required String name,
    required String service,
    required String message,
    required String time,
    required String initials,
    required Color avatarColor,
    bool isOnline = false,
    bool isStarred = false,
    bool isVoice = false,
    bool isImage = false,
    bool isPending = false,
    int? unreadCount,
    String? tag,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          leading: Stack(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: avatarColor,
                  borderRadius: BorderRadius.circular(15),
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
              if (isStarred)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Color(0xFFC7A76D),
                      size: 14,
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
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF3E2723),
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                service,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (isVoice)
                    const Icon(Icons.mic, size: 16, color: Colors.grey),
                  if (isImage)
                    const Icon(
                      Icons.image_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
                  if (isPending)
                    const Icon(
                      Icons.done_all,
                      size: 16,
                      color: Color(0xFFC7A76D),
                    ),
                  if (isVoice || isImage || isPending) const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: unreadCount != null
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: unreadCount != null
                            ? const Color(0xFF3E2723)
                            : Colors.grey,
                      ),
                    ),
                  ),
                  if (unreadCount != null)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF3E2723),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  if (tag != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E5D8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: Color(0xFFC7A76D),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Divider(height: 1, thickness: 0.5),
        ),
      ],
    );
  }
}
