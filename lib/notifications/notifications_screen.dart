import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/services/mock_notification_service.dart';
import 'models/notification_model.dart';
import 'package:construction_app/utils/feedback_helper.dart';
import 'package:construction_app/shared/widgets/confirm_dialog.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    // Auto-mark all as read on exit to clear global badges
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<MockNotificationService>(context, listen: false).markAllAsRead();
      }
    });
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MockNotificationService>(
      builder: (context, service, child) {
        final unread = service.unreadNotifications;
        final all = service.notifications;

        return ProfessionalPage(
          title: 'Secure Alerts',
          actions: [
            if (service.unreadCount > 0)
              IconButton(
                onPressed: () => _markAllRead(context, service),
                icon: Icon(Icons.done_all_rounded, color: Theme.of(context).colorScheme.primary),
                tooltip: 'Mark all as read',
              ),
            if (all.isNotEmpty)
              IconButton(
                onPressed: () => _clearAll(context, service),
                icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
                tooltip: 'Clear history',
              ),
          ],
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      'PENDING',
                      '${service.unreadCount}',
                      Icons.mark_email_unread_rounded,
                      Colors.orangeAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      'ARCHIVED',
                      '${all.length - service.unreadCount}',
                      Icons.history_rounded,
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
              padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                ),
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Theme.of(context).colorScheme.onPrimary,
                  unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('UNREAD'),
                          if (service.unreadCount > 0) ...[
                            const SizedBox(width: 10),
                            _buildUnreadBadge(service.unreadCount),
                          ],
                        ],
                      ),
                    ),
                    const Tab(text: 'LOG HISTORY'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: MediaQuery.of(context).size.height - 320,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildNotificationList(context, service, unread),
                  _buildNotificationList(context, service, all),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUnreadBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orangeAccent,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.orangeAccent.withOpacity(0.4), blurRadius: 6)],
      ),
      child: Text(
        '$count',
        style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return ProfessionalCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface, letterSpacing: -1)),
          Text(label, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        ],
      ),
    );
  }

  Widget _buildNotificationList(BuildContext context, MockNotificationService service, List<NotificationModel> notifications) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.05), shape: BoxShape.circle),
              child: Icon(Icons.notifications_off_rounded, size: 64, color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
            ),
            const SizedBox(height: 24),
            const Text('CLEAR HORIZON', style: TextStyle(fontSize: 14, color: Color(0xFFB0BEC5), fontWeight: FontWeight.w900, letterSpacing: 2)),
            const SizedBox(height: 8),
            Text('No operational alerts identified', style: TextStyle(fontSize: 13, color: const Color(0xFFB0BEC5).withOpacity(0.5), fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[notifications.length - 1 - index];
        return Dismissible(
          key: Key(notification.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
          ),
          onDismissed: (_) {
            service.deleteNotification(notification.id);
            FeedbackHelper.showSuccess(context, 'Alert dismissed');
          },
          child: _NotificationCard(
            notification: notification,
            onTap: () => service.markAsRead(notification.id),
          ),
        );
      },
    );
  }

  void _markAllRead(BuildContext context, MockNotificationService service) {
    service.markAllAsRead();
    FeedbackHelper.showSuccess(context, 'All logs marked as read');
  }

  void _clearAll(BuildContext context, MockNotificationService service) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Purge History?',
      message: 'This will permanently remove all notification logs from this device.',
      confirmText: 'PURGE LOGS',
      cancelText: 'RETAIN HISTORY',
      isDangerous: true,
    );
    if (confirmed == true) {
      service.clearAll();
      FeedbackHelper.showSuccess(context, 'Operational history purged');
    }
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(notification.type);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ProfessionalCard(
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIconContainer(typeColor),
                const SizedBox(width: 16),
                Expanded(child: _buildContent(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconContainer(Color color) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Center(child: Icon(_getTypeIcon(notification.type), color: color, size: 28)),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
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
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(notification.isRead ? 0.6 : 1.0),
                        letterSpacing: -0.2,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTimestamp(notification.timestamp),
                    style: const TextStyle(fontSize: 10, color: Color(0xFF78909C), fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildPriorityBadge(notification.priority),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          notification.message,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(notification.isRead ? 0.4 : 0.8),
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (!notification.isRead) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.orangeAccent, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              const Text('OPERATIONAL ALERT', style: TextStyle(color: Colors.orangeAccent, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPriorityBadge(NotificationPriority priority) {
    Color color;
    String label;
    switch (priority) {
      case NotificationPriority.high: color = Colors.redAccent; label = 'CRITICAL'; break;
      case NotificationPriority.medium: color = Colors.orangeAccent; label = 'ACTION'; break;
      case NotificationPriority.normal: color = Colors.blueAccent; label = 'SYSTEM'; break;
      case NotificationPriority.low: color = const Color(0xFFB0BEC5); label = 'INFO'; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
    );
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.alert: return Icons.warning_amber_rounded;
      case NotificationType.workSession: return Icons.work_history_rounded;
      case NotificationType.payment: return Icons.payments_rounded;
      case NotificationType.truck: return Icons.local_shipping_rounded;
      case NotificationType.inventory: return Icons.inventory_2_rounded;
      case NotificationType.approval: return Icons.fact_check_rounded;
      case NotificationType.system: return Icons.info_rounded;
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.alert: return Colors.redAccent;
      case NotificationType.workSession: return Colors.blueAccent;
      case NotificationType.payment: return Colors.greenAccent;
      case NotificationType.truck: return Colors.deepPurpleAccent;
      case NotificationType.inventory: return Colors.orangeAccent;
      case NotificationType.approval: return Colors.tealAccent;
      case NotificationType.system: return Colors.blueGrey;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return DateFormat('MMM dd, yyyy').format(timestamp);
  }
}
