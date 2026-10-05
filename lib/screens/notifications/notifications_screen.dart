import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homeserve_app/services/notification_service.dart';
import 'package:homeserve_app/theme/app_theme.dart';
import 'package:homeserve_app/widgets/widgets.dart';

class NotificationsScreen extends StatelessWidget {
  final ValueChanged<String>? onNotificationTap;
  final VoidCallback? onBack;

  const NotificationsScreen({super.key, this.onNotificationTap, this.onBack});

  static DateTime _timestamp(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final value = doc.data()['createdAt'];
    return value is Timestamp ? value.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
  }

  static String _formatDate(Object? value) {
    if (value is! Timestamp) return 'Just now';
    final date = value.toDate();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);
    
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final min = date.minute.toString().padLeft(2, '0');
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour:$min $ampm';

    if (targetDate == today) {
      return 'Today, $timeStr';
    } else if (targetDate == yesterday) {
      return 'Yesterday, $timeStr';
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final mStr = months[date.month - 1];
      final dStr = date.day.toString().padLeft(2, '0');
      return '$dStr $mStr ${date.year}, $timeStr';
    }
  }

  static String _statusFromType(String? type) {
    if (type == null) return 'unknown';
    if (type == 'booking_created') return 'pending';
    if (type == 'booking_confirmed') return 'confirmed';
    if (type == 'service_started') return 'in_progress';
    if (type == 'service_completed' || type == 'booking_completed') return 'completed';
    if (type == 'booking_rejected') return 'rejected';
    if (type == 'booking_cancelled') return 'cancelled';
    if (type == 'review_reminder') return 'information';
    if (type == 'provider_application') return 'verified';
    return 'information';
  }

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
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          itemCount: notifications.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final doc = notifications[index];
                            final data = doc.data();
                            final unread = data['isRead'] != true;
                            final statusStr = _statusFromType(data['type']?.toString());
                            
                            return InkWell(
                              onTap: () async {
                                if (unread) await NotificationService.instance.markAsRead(doc.id);
                                final relatedId = data['relatedId']?.toString();
                                if (relatedId != null && relatedId.isNotEmpty) onNotificationTap?.call(relatedId);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: unread ? const Color(0xFFE0F2F1) : Colors.white, // Teal highlight for unread
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: unread ? const Color(0xFF0F6B5C) : AppColors.border, width: unread ? 1 : 0.5),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (unread)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        margin: const EdgeInsets.only(top: 6, right: 8),
                                        decoration: const BoxDecoration(
                                          color: Colors.red, // Red unread badge
                                          shape: BoxShape.circle,
                                        ),
                                      )
                                    else
                                      const SizedBox(width: 16), // space replacement
                                      
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  data['title']?.toString() ?? 'Notification',
                                                  style: AppTextStyles.notifTitle.copyWith(
                                                    fontWeight: unread ? FontWeight.bold : FontWeight.normal,
                                                  ),
                                                ),
                                              ),
                                              StatusBadge(status: statusStr),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            data['message']?.toString() ?? '',
                                            style: AppTextStyles.notifSub.copyWith(
                                              color: unread ? Colors.black87 : Colors.black54,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _formatDate(data['createdAt']),
                                            style: AppTextStyles.notifTime.copyWith(
                                              color: Colors.black45,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
}
