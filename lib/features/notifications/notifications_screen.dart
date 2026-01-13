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
                  Colors.orangeAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Total',
                  _allNotifications.length.toString(),
                  Icons.notifications_rounded,
                  Colors.blueAccent,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Tab Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blueAccent, AppColors.deepBlue3],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.5),
              labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('UNREAD'),
                      if (_unreadCount > 0) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Tab(text: 'ALL HISTORY'),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

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
      useGlass: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.4),
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(List<NotificationItem> notifications) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_off_rounded,
                size: 60,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'CLEAR HORIZON',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.4),
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No new alerts to process',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.2),
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
    final typeColor = _getTypeColor(notification.type).withOpacity(0.8);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
      child: ProfessionalCard(
        useGlass: true,
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: () {
            setState(() {
              notification.isRead = true;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: typeColor.withOpacity(0.2)),
                  ),
                  child: Center(
                    child: Icon(
                      _getTypeIcon(notification.type),
                      color: typeColor,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification.title,
                                  style: TextStyle(
                                    fontWeight: notification.isRead ? FontWeight.w700 : FontWeight.w900,
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(notification.isRead ? 0.7 : 1.0),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatTimestamp(notification.timestamp),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withOpacity(0.4),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildPriorityBadge(notification.priority),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(notification.isRead ? 0.5 : 0.8),
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (!notification.isRead) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.orangeAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'NEW ALERT',
                              style: TextStyle(
                                color: Colors.orangeAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
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
        color = Colors.redAccent;
        label = 'URGENT';
        break;
      case NotificationPriority.medium:
        color = Colors.orangeAccent;
        label = 'ACTION';
        break;
      case NotificationPriority.normal:
        color = Colors.blueAccent;
        label = 'REMARK';
        break;
      case NotificationPriority.low:
        color = Colors.white.withOpacity(0.4);
        label = 'INFO';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
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
        return Colors.redAccent;
      case NotificationType.workSession:
        return Colors.blueAccent;
      case NotificationType.payment:
        return Colors.greenAccent;
      case NotificationType.truck:
        return Colors.purpleAccent;
      case NotificationType.inventory:
        return Colors.orangeAccent;
      case NotificationType.approval:
        return Colors.tealAccent;
      case NotificationType.system:
        return Colors.white70;
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
