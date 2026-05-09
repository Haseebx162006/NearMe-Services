class AdminRecentActivityItem {
  final String title;
  final String? detail;
  final String? timeLabel;

  const AdminRecentActivityItem({
    required this.title,
    this.detail,
    this.timeLabel,
  });

  factory AdminRecentActivityItem.fromJson(Map<String, dynamic> json) {
    return AdminRecentActivityItem(
      title: (json['title'] ?? '').toString(),
      detail: json['detail']?.toString(),
      timeLabel: json['time']?.toString(),
    );
  }
}

class AdminDashboardModel {
  final int totalUsers;
  final int totalGigs;
  final int totalOrders;
  final double totalRevenue;
  final List<AdminRecentActivityItem> recentActivity;

  const AdminDashboardModel({
    required this.totalUsers,
    required this.totalGigs,
    required this.totalOrders,
    required this.totalRevenue,
    required this.recentActivity,
  });

  AdminDashboardModel copyWith({
    int? totalUsers,
    int? totalGigs,
    int? totalOrders,
    double? totalRevenue,
    List<AdminRecentActivityItem>? recentActivity,
  }) {
    return AdminDashboardModel(
      totalUsers: totalUsers ?? this.totalUsers,
      totalGigs: totalGigs ?? this.totalGigs,
      totalOrders: totalOrders ?? this.totalOrders,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      recentActivity: recentActivity ?? this.recentActivity,
    );
  }
}

