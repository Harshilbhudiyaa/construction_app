import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/professional_page.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<NotificationItem> _allNotifications = [
    NotificationItem(
      id: '1',
      type: NotificationType.alert,
      title: 'Backup Blocks Used',
      message: 'Main stock depleted. 1,200 backup blocks allocated to Site A.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      isRead: false,
      priority: NotificationPriority.high,
    ),
    NotificationItem(
      id: '2',
      type: NotificationType.workSession,
      title: 'Work Session Started',
      message: 'Ramesh Kumar started Block Work at 9:30 AM',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      priority: NotificationPriority.normal,
    ),
    NotificationItem(
      id: '3',
      type: NotificationType.payment,
      title: 'Payment Pending',
      message: 'Worker payroll for Dec pending approval. Amount: ₹2.4L',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: true,
      priority: NotificationPriority.high,
    ),
    NotificationItem(
      id: '4',
      type: NotificationType.truck,
      title: 'Truck Delayed',
      message: 'GJ01AB1234 - Expected delay of 45 mins due to traffic',
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      isRead: true,
      priority: NotificationPriority.normal,
    ),
    NotificationItem(
      id: '5',
      type: NotificationType.inventory,
      title: 'Low Stock Alert',
      message: 'Cement stock below threshold. Current: 180 bags (Min: 200)',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      priority: NotificationPriority.medium,
    ),
    NotificationItem(
      id: '6',
      type: NotificationType.approval,
      title: 'Approval Required',
      message: 'Work session by Suresh needs verification',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      priority: NotificationPriority.medium,
    ),
    NotificationItem(
      id: '7',
      type: NotificationType.system,
      title: 'System Update',
      message: 'App updated to v2.5.0 with new analytics features',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
      priority: NotificationPriority.low,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<NotificationItem> get _unreadNotifications =>
      _allNotifications.where((n) => !n.isRead).toList();

  int get _unreadCount => _unreadNotifications.length;

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Notifications',
      children: [
        // Summary Cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Unread',
                  _unreadCount.toString(),
                  Icons.mark_email_unread_rounded,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Total',
                  _allNotifications.length.toString(),
                  Icons.notifications_rounded,
                  Colors.blue,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Tab Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.deepBlue1,
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[700],
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Unread'),
                      if (_unreadCount > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Tab(text: 'All'),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Tab Views
        SizedBox(
          height: MediaQuery.of(context).size.height - 300,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildNotificationList(_unreadNotifications),
              _buildNotificationList(_allNotifications),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color) {
    return ProfessionalCard(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.deepBlue1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList(List<NotificationItem> notifications) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_rounded,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ProfessionalCard(
        child: InkWell(
          onTap: () {
            setState(() {
              notification.isRead = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Opening ${notification.title}...')),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getTypeColor(notification.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getTypeIcon(notification.type),
                    color: _getTypeColor(notification.type),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontWeight: notification.isRead
                                    ? FontWeight.w600
                                    : FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.deepBlue1,
                              ),
                            ),
                          ),
                          _buildPriorityBadge(notification.priority),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatTimestamp(notification.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(NotificationPriority priority) {
    Color color;
    String label;

    switch (priority) {
      case NotificationPriority.high:
        color = Colors.red;
        label = 'HIGH';
        break;
      case NotificationPriority.medium:
        color = Colors.orange;
        label = 'MED';
        break;
      case NotificationPriority.normal:
        color = Colors.blue;
        label = 'NORM';
        break;
      case NotificationPriority.low:
        color = Colors.grey;
        label = 'LOW';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.alert:
        return Icons.warning_amber_rounded;
      case NotificationType.workSession:
        return Icons.work_history_rounded;
      case NotificationType.payment:
        return Icons.payments_rounded;
      case NotificationType.truck:
        return Icons.local_shipping_rounded;
      case NotificationType.inventory:
        return Icons.inventory_2_rounded;
      case NotificationType.approval:
        return Icons.fact_check_rounded;
      case NotificationType.system:
        return Icons.info_rounded;
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.alert:
        return Colors.red;
      case NotificationType.workSession:
        return Colors.blue;
      case NotificationType.payment:
        return Colors.green;
      case NotificationType.truck:
        return Colors.purple;
      case NotificationType.inventory:
        return Colors.orange;
      case NotificationType.approval:
        return Colors.teal;
      case NotificationType.system:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(timestamp);
    }
  }
}

enum NotificationType {
  alert,
  workSession,
  payment,
  truck,
  inventory,
  approval,
  system,
}

enum NotificationPriority {
  high,
  medium,
  normal,
  low,
}

class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead;
  final NotificationPriority priority;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.priority = NotificationPriority.normal,
  });
}
