import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';

import '../../Models/subscrptions/notification_model.dart';
import '../../Services/Auth_service/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool isLoading = true;
  List<NotificationModel> notifications = [];
  bool _showUsageTip = true; // Flag to show usage tip with first notification

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => isLoading = true);

    final data = await NotificationService.fetchNotifications();

    setState(() {
      notifications = data;
      isLoading = false;
    });
  }

  Future<void> markAllAsRead() async {
    final success = await NotificationService.markAllNotificationsRead();
    if (success) {
      setState(() {
        for (var i = 0; i < notifications.length; i++) {
          notifications[i] = NotificationModel(
            id: notifications[i].id,
            userId: notifications[i].userId,
            title: notifications[i].title,
            body: notifications[i].body,
            notificationType: notifications[i].notificationType,
            data: notifications[i].data,
            isRead: true,
            createdAt: notifications[i].createdAt,
            readAt: DateTime.now().toString(),
            deletedAt: notifications[i].deletedAt,
          );
        }
      });
      // ignore: use_build_context_synchronously
      AppAlert.success(context, "All notifications marked as read ✅");
    }
  }

  Future<void> markSingleAsRead(String notifId) async {
    final success = await NotificationService.markSingleNotificationRead(
      notifId,
    );
    if (success) {
      setState(() {
        final index = notifications.indexWhere((n) => n.id == notifId);
        if (index != -1) {
          notifications[index] = NotificationModel(
            id: notifications[index].id,
            userId: notifications[index].userId,
            title: notifications[index].title,
            body: notifications[index].body,
            notificationType: notifications[index].notificationType,
            data: notifications[index].data,
            isRead: true,
            createdAt: notifications[index].createdAt,
            readAt: DateTime.now().toString(),
            deletedAt: notifications[index].deletedAt,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // or your needed height
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.h),
        child: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            "Notifications",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
          ),
          actions: [
            // DELETE ALL
            // Container(
            //   margin: const EdgeInsets.only(right: 10),
            //   decoration: BoxDecoration(
            //     shape: BoxShape.circle,
            //     color: Colors.blue.withOpacity(0.1),
            //   ),
            //   child: IconButton(
            //     icon: const Icon(Icons.delete, color: Colors.blue),
            //     tooltip: "Delete all notifications",
            //     onPressed: deleteAllNotifications,
            //   ),
            // ),

            // MARK ALL READ
            Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // ignore: deprecated_member_use
                color: Colors.blue.withOpacity(0.1),
              ),
              child: IconButton(
                icon: const Icon(Icons.done_all, color: Colors.blue),
                tooltip: "Mark all as read",
                onPressed: markAllAsRead,
              ),
            ),
          ],
        ),
      ),

      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Loading notifications...",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            )
          : notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No notifications yet",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "We'll notify you when something arrives",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          : Builder(
              builder: (context) {
                // 🔹 Sort notifications so latest comes first
                notifications.sort(
                  (a, b) => DateTime.parse(
                    b.createdAt,
                  ).compareTo(DateTime.parse(a.createdAt)),
                );

                return RefreshIndicator(
                  color: Colors.blue,
                  backgroundColor: Colors.white,
                  onRefresh: () async {
                    await _fetchNotifications();
                  },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 4),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notif = notifications[index];

                      return _buildNotificationItem(
                        context,
                        notif,
                        index,
                        showUsageTip: _showUsageTip && index == 0,
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    NotificationModel notif,
    int index, {
    bool showUsageTip = false,
  }) {
    return Stack(
      children: [
        Dismissible(
          key: Key(notif.id),
          direction: DismissDirection.endToStart,
          background: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.redAccent,
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.delete_outline, color: Colors.white, size: 24),
                SizedBox(width: 8),
                Text(
                  "Delete",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          onDismissed: (direction) async {
            final deletedNotif = notif;

            setState(() {
              notifications.removeAt(index);
            });

            final success = await NotificationService.deleteNotification(
              notif.id,
            );

            if (success) {
              // ignore: use_build_context_synchronously
              AppAlert.success(context, "Notification deleted");
            } else {
              setState(() {
                notifications.insert(index, deletedNotif);
              });
              // ignore: use_build_context_synchronously
              AppAlert.error(context, "Failed to delete notification");
            }
          },
          child: Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: notif.isRead
                    ? Colors.grey.shade200
                    : Colors.blue.shade200,
                width: 1,
              ),
            ),
            color: notif.isRead
                ? Colors.white
                // ignore: deprecated_member_use
                : Colors.blue.shade50.withOpacity(0.3),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: notif.isRead
                      ? Colors.grey.shade100
                      : Colors.blue.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  notif.isRead
                      ? Icons.notifications_none
                      : Icons.notifications_active,
                  color: notif.isRead
                      ? Colors.grey.shade600
                      : Colors.blue.shade700,
                  size: 20,
                ),
              ),
              title: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notif.title,
                      style: TextStyle(
                        fontWeight: notif.isRead
                            ? FontWeight.normal
                            : FontWeight.w600,
                        fontSize: 15,
                        color: notif.isRead
                            ? Colors.grey.shade800
                            : Colors.blue.shade900,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (showUsageTip) ...[
                      const SizedBox(height: 4),
                      Text(
                        "💡 Swipe left to delete | Tap to expand",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.amber.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              subtitle: Text(
                _formatDate(notif.createdAt),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              trailing: notif.isRead
                  ? null
                  : Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
              onExpansionChanged: (expanded) {
                if (expanded && !notif.isRead) {
                  markSingleAsRead(notif.id);
                }
                // Hide usage tip when user interacts with notification
                if (expanded && showUsageTip) {
                  setState(() {
                    _showUsageTip = false;
                  });
                }
              },
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Usage instructions in the expanded view
                      if (showUsageTip)
                        Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.amber.shade200,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: Colors.amber.shade700,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Quick Tips:",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.amber.shade800,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "• Swipe left on any notification to delete\n"
                                      "• Tap to expand and view details\n"
                                      "• Blue dot means unread",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.grey.shade500,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showUsageTip = false;
                                  });
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                      Text(
                        notif.body,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Divider(color: Colors.grey.shade300, height: 1),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatFullDate(notif.createdAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          if (!notif.isRead)
                            ElevatedButton.icon(
                              onPressed: () => markSingleAsRead(notif.id),
                              icon: const Icon(
                                Icons.check_circle_outline,
                                size: 14,
                              ),
                              label: const Text(
                                'Mark as read',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 0,
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
        // Swipe hint overlay for first notification
        if (showUsageTip)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.shade600,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.swipe_left, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    "Swipe to delete",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // Helper functions for date formatting
  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  String _formatFullDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
