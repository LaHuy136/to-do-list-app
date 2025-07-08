import 'dart:async';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_list_app/components/my_custom_showDialog.dart';
import 'package:to_do_list_app/provider/notification.provider.dart';
import 'package:to_do_list_app/theme/app_colors.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationItem> notifications = [];

  StreamSubscription<RemoteMessage>? _msgSubscription;

  @override
  void initState() {
    super.initState();
    loadNotifications().then((_) => markAllAsRead());

    _msgSubscription = FirebaseMessaging.onMessage.listen((
      RemoteMessage message,
    ) {
      final notification = message.notification;
      if (notification != null && mounted) {
        final newItem = NotificationItem(
          title: notification.title ?? '',
          body: notification.body ?? '',
          timestamp: DateTime.now(),
        );

        setState(() {
          notifications.insert(0, newItem);
        });

        saveNotifications();
        flutterLocalNotificationsPlugin.show(
          0,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'todo_channel', // channelId
              'To-Do Notifications', // channelName
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    });
  }

  Future<void> saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = notifications.map((n) => jsonEncode(n.toJson())).toList();
    await prefs.setStringList('notifications', jsonList);
  }

  Future<void> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('notifications') ?? [];
    setState(() {
      notifications =
          stored.map((e) => NotificationItem.fromJson(jsonDecode(e))).toList();
    });
  }

  void removeNotification(int index) {
    setState(() {
      notifications.removeAt(index);
    });
    saveNotifications();
  }

  void clearAllNotifications() {
    setState(() {
      notifications.clear();
    });
    saveNotifications();
  }

  void showClearAllDialog() {
    MyCustomDialog.show(
      context: context,
      isTwoButton: true,
      onPressed: () {
        Navigator.pop(context);
        clearAllNotifications();
      },
      confirmText: 'Confirm',
      title: 'Clear All Notifications',
      content: 'Are you sure you want to delete all notifications?',
    );
  }

  Future<void> markAllAsRead() async {
    setState(() {
      for (var n in notifications) {
        n.isRead = true;
      }
    });
    await saveNotifications();
  }

  @override
  void dispose() {
    _msgSubscription?.cancel();
    super.dispose();
  }

  IconData getIconByTitle(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('completed') || lower.contains('done')) {
      return Icons.check_box_rounded;
    } else if (lower.contains('upcoming')) {
      return Icons.upcoming_rounded;
    } else if (lower.contains('overdue')) {
      return Icons.warning_amber_rounded;
    }
    return Icons.notifications;
  }

  Color getIconColor(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('completed') || lower.contains('done')) {
      return AppColors.primary;
    } else if (lower.contains('upcoming')) {
      return AppColors.unfocusedIcon;
    } else if (lower.contains('overdue')) {
      return AppColors.destructive;
    }
    return AppColors.disabledSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.defaultText,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          title: Container(
            margin: const EdgeInsets.only(top: 8),
            child: Text(
              'Notification',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.primary,
              ),
            ),
          ),
          centerTitle: true,
          leadingWidth: 55,
          leading: InkWell(
            onTap:
                () =>
                    notifications.isNotEmpty
                        ? Navigator.pop(context, 'cleared')
                        : Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.only(left: 8, top: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.primary,
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 22,
                color: AppColors.defaultText,
              ),
            ),
          ),
          actions: [
            if (notifications.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(right: 8, top: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.primary,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.delete_sweep_rounded,
                    color: AppColors.defaultText,
                    size: 22,
                  ),
                  color: AppColors.primary,
                  tooltip: 'Clear all',
                  onPressed: () {
                    showClearAllDialog();
                  },
                ),
              ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size(double.infinity, 2),
            child: Divider(height: 2, color: AppColors.primary),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];
          final icon = getIconByTitle(item.title);
          final iconColor = getIconColor(item.title);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  index % 2 == 0
                      ? AppColors.disabledTertiary
                      : AppColors.defaultText,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: iconColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.body,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat('HH:mm dd/MM/yyyy').format(item.timestamp),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: AppColors.disabledSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => removeNotification(index),
                  tooltip: 'Remove',
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: AppColors.primary,
        child: Container(
          height: 50,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'You have ${notifications.length} notifications',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppColors.defaultText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
