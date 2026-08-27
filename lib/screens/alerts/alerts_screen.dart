import 'package:flutter/material.dart';
import 'package:pedalya_mobile/core/theme/app_colors.dart';
import 'package:pedalya_mobile/services/api_service.dart';
class Alerts extends StatefulWidget {
  const Alerts({
    super.key,
  });

  @override
  State<Alerts> createState() => _AlertsState();
}

class _AlertsState extends State<Alerts> {
  List<Map<String, dynamic>> notifications = [];

  bool isLoading = true;
  String? errorMessage;
  int unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final notificationResponse =
        await ApiService.getNotifications();

    final unreadResponse =
        await ApiService.getUnreadNotificationCount();

    if (!mounted) return;

    if (notificationResponse['success'] == true) {
      final rawNotifications =
          notificationResponse['notifications'];

      setState(() {
        notifications =
            rawNotifications is List
                ? rawNotifications
                    .whereType<Map>()
                    .map(
                      (item) =>
                          Map<String, dynamic>.from(item),
                    )
                    .toList()
                : [];

        unreadCount =
            unreadResponse['unreadCount'] is int
                ? unreadResponse['unreadCount'] as int
                : int.tryParse(
                      unreadResponse['unreadCount']
                              ?.toString() ??
                          '0',
                    ) ??
                    0;

        isLoading = false;
      });
    } else {
      setState(() {
        errorMessage =
            notificationResponse['message']?.toString() ??
            'Failed to load notifications.';

        isLoading = false;
      });
    }
    
  }
  
  _AlertType _notificationAlertType(String type) {
  if (type.contains('payment')) {
    return _AlertType.payment;
  }

  if (type.contains('reminder') ||
      type.contains('ending') ||
      type.contains('expiry') ||
      type.contains('overdue')) {
    return _AlertType.reminder;
  }

  if (type.contains('accident') ||
      type.contains('theft') ||
      type.contains('geofence') ||
      type.contains('zone') ||
      type.contains('warning') ||
      type.contains('emergency')) {
    return _AlertType.danger;
  }

  return _AlertType.success;
}

IconData _notificationIcon(String type) {
  if (type.contains('payment')) {
    return Icons.account_balance_wallet_rounded;
  }

  if (type.contains('accident')) {
    return Icons.emergency_rounded;
  }

  if (type.contains('theft')) {
    return Icons.lock_rounded;
  }

  if (type.contains('geofence') ||
      type.contains('zone')) {
    return Icons.warning_rounded;
  }

  if (type.contains('reminder') ||
      type.contains('ending') ||
      type.contains('expiry') ||
      type.contains('overdue')) {
    return Icons.schedule_rounded;
  }

  if (type.contains('verification') ||
      type.contains('verified') ||
      type.contains('account')) {
    return Icons.verified_user_rounded;
  }

  return Icons.notifications_rounded;
}

String _notificationTag(String type) {
  if (type.contains('payment')) {
    return 'Payment';
  }

  if (type.contains('accident')) {
    return 'Accident';
  }

  if (type.contains('theft')) {
    return 'Security';
  }

  if (type.contains('geofence') ||
      type.contains('zone')) {
    return 'Zone warning';
  }

  if (type.contains('reminder') ||
      type.contains('ending') ||
      type.contains('expiry') ||
      type.contains('overdue')) {
    return 'Reminder';
  }

  if (type.contains('verification') ||
      type.contains('verified') ||
      type.contains('account')) {
    return 'Account';
  }

  if (type.contains('reservation') ||
      type.contains('rental')) {
    return 'Rental';
  }

  return 'Update';
}

String _formatNotificationTime(dynamic value) {
  if (value == null) {
    return '';
  }

  final createdAt = DateTime.tryParse(value.toString());

  if (createdAt == null) {
    return '';
  }

  final difference =
      DateTime.now().difference(createdAt.toLocal());

  if (difference.inSeconds < 60) {
    return 'Just now';
  }

  if (difference.inMinutes < 60) {
    return '${difference.inMinutes} min ago';
  }

  if (difference.inHours < 24) {
    return '${difference.inHours} hr ago';
  }

  if (difference.inDays == 1) {
    return 'Yesterday';
  }

  return '${difference.inDays} days ago';
}

Future<void> _markNotificationAsRead(
  Map<String, dynamic> notification,
) async {
  final notificationId =
      int.tryParse(notification['id']?.toString() ?? '');

  if (notificationId == null) return;

  final alreadyRead =
      notification['read'] == true ||
      notification['read'] == 1 ||
      notification['read']?.toString() == '1';

  if (alreadyRead) return;

  final response =
      await ApiService.markNotificationRead(notificationId);

  if (!mounted) return;

  if (response['success'] == true) {
    setState(() {
      notification['read'] = true;

      if (unreadCount > 0) {
        unreadCount--;
      }
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          response['message']?.toString() ??
              'Failed to mark notification as read.',
        ),
      ),
    );
  }
}

Future<void> _markAllNotificationsAsRead() async {
  if (unreadCount == 0) return;

  final response =
      await ApiService.markAllNotificationsRead();

  if (!mounted) return;

  if (response['success'] == true) {
    setState(() {
      for (final notification in notifications) {
        notification['read'] = true;
      }

      unreadCount = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read.'),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          response['message']?.toString() ??
              'Failed to mark notifications as read.',
        ),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0B0D18),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          28,
          20,
          30,
        ),
        children: [
          // =====================================
          // HEADER
          // =====================================

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ride updates',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    SizedBox(height: 6),

                    Text(
                      'Important updates about your rides and account.',
                      style: TextStyle(
                        color: Color(0xFF9699A8),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              GestureDetector(
  onTap: unreadCount > 0
      ? _markAllNotificationsAsRead
      : null,
  child: Container(
    width: 46,
    height: 46,
    decoration: const BoxDecoration(
      color: Color(0xFF292D43),
      shape: BoxShape.circle,
    ),
    child: Icon(
      unreadCount > 0
          ? Icons.mark_email_read_rounded
          : Icons.notifications_none_rounded,
      color: const Color(0xFFAAD9BB),
      size: 22,
    ),
  ),
),
            ],
          ),

          const SizedBox(height: 24),

          // =====================================
          // ALL CAUGHT UP
          // =====================================

         Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      colors: [
        Color(0xFF17292B),
        Color(0xFF20243A),
      ],
    ),
    borderRadius: BorderRadius.circular(22),
    border: Border.all(
      color: const Color(0xFF80BCBD).withValues(alpha: 0.15),
    ),
  ),
  child: Row(
    children: [
      Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: unreadCount > 0
              ? const Color(0xFF183238)
              : const Color(0xFF16312C),
          shape: BoxShape.circle,
        ),
        child: Icon(
          unreadCount > 0
              ? Icons.notifications_active_rounded
              : Icons.check_circle_outline_rounded,
          color: const Color(0xFFAAD9BB),
          size: 24,
        ),
      ),

      const SizedBox(width: 13),

      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              unreadCount > 0
                  ? '$unreadCount unread ${unreadCount == 1 ? 'update' : 'updates'}'
                  : 'You’re all caught up',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              unreadCount > 0
                  ? 'Check your recent ride updates below.'
                  : 'No urgent alerts right now.',
              style: const TextStyle(
                color: Color(0xFF9699A8),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),

          const SizedBox(height: 28),

          // =====================================
          // RECENT
          // =====================================

          const Text(
            'Recent',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 14),

if (isLoading)
  const Padding(
    padding: EdgeInsets.symmetric(vertical: 30),
    child: Center(
      child: CircularProgressIndicator(),
    ),
  )
else if (errorMessage != null)
  Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF25141A),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      children: [
        Text(
          errorMessage!,
          style: const TextStyle(
            color: Color(0xFFFF7D7D),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: _loadNotifications,
          child: const Text('Try again'),
        ),
      ],
    ),
  )
else if (notifications.isEmpty)
  const Padding(
    padding: EdgeInsets.symmetric(vertical: 24),
    child: Center(
      child: Text(
        'No notifications yet.',
        style: TextStyle(
          color: Color(0xFF9699A8),
          fontSize: 12,
        ),
      ),
    ),
  )
else
  ...notifications.asMap().entries.expand((entry) {
  final index = entry.key;
  final notification = entry.value;

  final type =
      notification['type']?.toString().toLowerCase() ?? '';

  return [
    _DarkAlertCard(
      icon: _notificationIcon(type),
      title:
          notification['title']?.toString() ??
          'Pedalya update',
      message:
          notification['message']?.toString() ?? '',
      time: _formatNotificationTime(
        notification['created_at'],
      ),
      tag: _notificationTag(type),
      type: _notificationAlertType(type),
      onTap: () => _markNotificationAsRead(notification),
    ),

    if (index < notifications.length - 1)
      const SizedBox(height: 11),
  ];
}),

          // =====================================
          // FOOTER INFO
          // =====================================

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF17292B),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFF80BCBD)
                    .withValues(alpha: 0.14),
              ),
            ),
            child: const Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xFF80D6D4),
                  size: 21,
                ),

                SizedBox(width: 10),

                Expanded(
                  child: Text(
                    'Rental, payment, safety, and account updates will appear here.',
                    style: TextStyle(
                      color: Color(0xFFC6C8D1),
                      fontSize: 12,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _AlertType {
  success,
  payment,
  reminder,
  danger,
}

class _DarkAlertCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String time;
  final String tag;
  final _AlertType type;
  final VoidCallback? onTap;

 const _DarkAlertCard({
  required this.icon,
  required this.title,
  required this.message,
  required this.time,
  required this.tag,
  required this.type,
  this.onTap,
});

  Color get accentColor {
    switch (type) {
      case _AlertType.success:
        return const Color(0xFFAAD9BB);

      case _AlertType.payment:
        return const Color(0xFF80D6D4);

      case _AlertType.reminder:
        return const Color(0xFFF9D77E);

      case _AlertType.danger:
        return const Color(0xFFFF6B6B);
    }
  }

  Color get iconBackground {
    switch (type) {
      case _AlertType.success:
        return const Color(0xFF16312C);

      case _AlertType.payment:
        return const Color(0xFF183238);

      case _AlertType.reminder:
        return const Color(0xFF3B321E);

      case _AlertType.danger:
        return const Color(0xFF3A171D);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDanger = type == _AlertType.danger;

   return GestureDetector(
  onTap: onTap,
  child: Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDanger
            ? const Color(0xFF25141A)
            : const Color(0xFF1A1D2E),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDanger
              ? const Color(0xFFFF6B6B)
                  .withValues(alpha: 0.50)
              : Colors.white.withValues(
                  alpha: 0.06,
                ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ICON
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius:
                  BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: accentColor,
              size: 23,
            ),
          ),

          const SizedBox(width: 12),

          // CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: isDanger
                              ? const Color(
                                  0xFFFF7D7D,
                                )
                              : Colors.white,
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Text(
                      time,
                      style: const TextStyle(
                        color: Color(0xFF777B8E),
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                Text(
                  message,
                  style: TextStyle(
                    color: isDanger
                        ? const Color(
                            0xFFD7B5B9,
                          )
                        : const Color(
                            0xFF9699A8,
                          ),
                    fontSize: 11,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 9),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius:
                        BorderRadius.circular(30),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 8,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class PedalyaAlertCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String title;
  final String message;
  final String time;
  final String status;
  final bool important;

  const PedalyaAlertCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.title,
    required this.message,
    required this.time,
    required this.status,
    this.important = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: important
            ? Border.all(
                color: Colors.red.withValues(alpha: 0.35),
              )
            : null,
        boxShadow: const [
          BoxShadow(
            color: Color(0x10214645),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 23,
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
                        title,
                        style: TextStyle(
                          color: important ? Colors.red : ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),

                    Text(
                      time,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                Text(
                  message,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 9),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}