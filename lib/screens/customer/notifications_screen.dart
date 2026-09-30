import 'package:flutter/material.dart';

import '../../models/notification_model.dart';
import '../../services/notification_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationService notificationService =
        NotificationService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),

        actions: [
          IconButton(
            tooltip: 'Mark all as read',
            icon: const Icon(
              Icons.done_all,
            ),
            onPressed: () async {
              await notificationService
                  .markAllAsRead();
            },
          ),
        ],
      ),

      body: StreamBuilder<
          List<NotificationModel>>(
        stream: notificationService
            .getNotifications(),

        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
              ),
            );
          }

          final notifications =
              snapshot.data ?? [];

          if (notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80,
                  ),

                  SizedBox(height: 16),

                  Text(
                    'No notifications',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,

            itemBuilder: (context, index) {
              final notification =
                  notifications[index];

              return NotificationCard(
                notification: notification,
                notificationService:
                    notificationService,
              );
            },
          );
        },
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final NotificationService notificationService;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.notificationService,
  });

  IconData get notificationIcon {
    switch (notification.type) {
      case 'order':
        return Icons.shopping_bag;

      case 'delivery':
        return Icons.delivery_dining;

      case 'wishlist':
        return Icons.favorite;

      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),

      color: notification.isRead
          ? null
          : Colors.blue.withValues(alpha: 0.08),

      child: ListTile(
        leading: CircleAvatar(
          child: Icon(
            notificationIcon,
          ),
        ),

        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead
                ? FontWeight.normal
                : FontWeight.bold,
          ),
        ),

        subtitle: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            const SizedBox(height: 4),

            Text(
              notification.message,
            ),

            const SizedBox(height: 4),

            Text(
              notification.createdAt
                  .toString(),
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),

        trailing: notification.isRead
            ? null
            : const Icon(
                Icons.circle,
                size: 10,
              ),

        onTap: () async {
          if (!notification.isRead) {
            await notificationService
                .markAsRead(
              notification.id,
            );
          }
        },
      ),
    );
  }
}