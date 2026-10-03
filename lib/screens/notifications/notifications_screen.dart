import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homeserve_app/services/notification_service.dart';
import 'package:homeserve_app/theme/app_theme.dart';
import 'package:homeserve_app/widgets/widgets.dart';

class NotificationsScreen extends StatelessWidget {
  final ValueChanged<String>? onNotificationTap;
  final VoidCallback? onBack;

  const NotificationsScreen({super.key, this.onNotificationTap, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: NotificationService.instance.watchNotifications(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return Center(child: Text('Could not load notifications: ${snapshot.error}'));
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final notifications = [...snapshot.data!.docs]
              ..sort((a, b) => _timestamp(b).compareTo(_timestamp(a)));
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl + 2, vertical: AppSpacing.xxl + 2),
                  child: Row(
                    children: [
                      Expanded(child: AppBarWithIcon(title: 'Notifications', onLeadingPressed: onBack ?? () => Navigator.of(context).maybePop())),
                      TextButton(
                        onPressed: () => NotificationService.instance.markAllAsRead(snapshot.data!),
                        child: const Text('Read all'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: notifications.isEmpty
                      ? const Center(child: Text('No notifications yet.'))
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl + 2),
                          itemCount: notifications.length,
                          separatorBuilder: (_, __) => const Divider(color: AppColors.border),
                          itemBuilder: (context, index) {
                            final doc = notifications[index];
                            final data = doc.data();
                            final unread = data['isRead'] != true;
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                              leading: CircleAvatar(
                                backgroundColor: unread ? AppColors.primaryLight : AppColors.surface,
                                child: Icon(_iconFor(data['type']?.toString()), color: AppColors.primaryDark),
                              ),
                              title: Text(data['title']?.toString() ?? 'Notification', style: unread ? AppTextStyles.notifTitle.copyWith(fontWeight: FontWeight.bold) : AppTextStyles.notifTitle),
                              subtitle: Text(data['message']?.toString() ?? '', style: AppTextStyles.notifSub),
                              trailing: Text(_relativeTime(data['createdAt']), style: AppTextStyles.notifTime),
                              onTap: () async {
                                if (unread) await NotificationService.instance.markAsRead(doc.id);
                                final relatedId = data['relatedId']?.toString();
                                if (relatedId != null && relatedId.isNotEmpty) onNotificationTap?.call(relatedId);
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static DateTime _timestamp(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final value = doc.data()['createdAt'];
    return value is Timestamp ? value.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
  }

  static String _relativeTime(Object? value) {
    if (value is! Timestamp) return 'now';
    final difference = DateTime.now().difference(value.toDate());
    if (difference.inMinutes < 1) return 'now';
    if (difference.inHours < 1) return '${difference.inMinutes}m';
    if (difference.inDays < 1) return '${difference.inHours}h';
    return '${difference.inDays}d';
  }

  static IconData _iconFor(String? type) {
    if (type == 'review_reminder') return Icons.star_border_rounded;
    if (type == 'booking_cancelled') return Icons.cancel_outlined;
    if (type == 'booking_completed') return Icons.check_circle_outline;
    if (type == 'provider_application') return Icons.verified_outlined;
    return Icons.notifications_none;
  }
}
