import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../models/notification.dart' as app_notification;
import '../utils/minimal_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MinimalTheme.background,
      appBar: AppBar(
        backgroundColor: MinimalTheme.background,
        elevation: 0,
        title: const Text('Notifications'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              if (notificationProvider.notifications.isEmpty) {
                return const SizedBox.shrink();
              }
              
              return PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'mark_all_read') {
                    notificationProvider.markAllAsRead();
                  } else if (value == 'clear_all') {
                    _showClearAllDialog(context, notificationProvider);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'mark_all_read',
                    child: Text('Mark all as read'),
                  ),
                  const PopupMenuItem(
                    value: 'clear_all',
                    child: Text('Clear all notifications'),
                  ),
                ],
                child: const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Icon(Icons.more_vert),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          if (notificationProvider.notifications.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Refresh notifications if needed
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notificationProvider.notifications.length,
              itemBuilder: (context, index) {
                final notification = notificationProvider.notifications[index];
                return _buildNotificationCard(notification, notificationProvider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    app_notification.Notification notification,
    NotificationProvider notificationProvider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: MinimalTheme.getCardDecoration().copyWith(
        border: !notification.isRead
            ? Border.all(color: MinimalTheme.primaryAccent, width: 2)
            : null,
      ),
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            notificationProvider.markAsRead(notification.id);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: _getNotificationColor(notification.type),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              color: MinimalTheme.primaryAccent,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: MinimalTheme.primaryAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        color: MinimalTheme.subtext,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          notification.timeAgo,
                          style: TextStyle(
                            color: MinimalTheme.subtext.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'delete') {
                              notificationProvider.deleteNotification(notification.id);
                            } else if (value == 'mark_read') {
                              notificationProvider.markAsRead(notification.id);
                            }
                          },
                          itemBuilder: (context) => [
                            if (!notification.isRead)
                              const PopupMenuItem(
                                value: 'mark_read',
                                child: Text('Mark as read'),
                              ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                          child: Icon(
                            Icons.more_horiz,
                            size: 16,
                            color: MinimalTheme.subtext.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'booking_confirmed':
        return Colors.green;
      case 'booking_cancelled':
        return Colors.red;
      case 'reminder':
        return Colors.orange;
      case 'general':
      default:
        return MinimalTheme.primaryAccent;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'booking_confirmed':
        return Icons.check_circle;
      case 'booking_cancelled':
        return Icons.cancel;
      case 'reminder':
        return Icons.schedule;
      case 'general':
      default:
        return Icons.info;
    }
  }

  void _showClearAllDialog(BuildContext context, NotificationProvider notificationProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: MinimalTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Clear All Notifications',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: MinimalTheme.primaryAccent,
          ),
        ),
        content: Text(
          'Are you sure you want to clear all notifications?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: MinimalTheme.subtext,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: MinimalTheme.subtext),
            ),
          ),
          Container(
            decoration: MinimalTheme.getBadgeDecoration(MinimalTheme.inactiveBadge),
            child: ElevatedButton(
              onPressed: () {
                notificationProvider.clearAllNotifications();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear All'),
            ),
          ),
        ],
      ),
    );
  }
}
