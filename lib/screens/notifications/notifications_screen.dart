import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homeserve_app/services/notification_service.dart';
import 'package:homeserve_app/theme/app_theme.dart';
import 'package:homeserve_app/widgets/widgets.dart';

class NotificationsScreen extends StatefulWidget {
  final ValueChanged<String>? onNotificationTap;
  final VoidCallback? onBack;

  const NotificationsScreen({super.key, this.onNotificationTap, this.onBack});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isSelecting = false;
  final Set<String> _selected = {};

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
    if (type == 'payment_completed') return 'confirmed';
    if (type == 'complaint_filed') return 'rejected';
    if (type == 'account_status') return 'information';
    return 'information';
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelecting = false;
      _selected.clear();
    });
  }

  void _toggleSelect(String docId) {
    setState(() {
      if (_selected.contains(docId)) {
        _selected.remove(docId);
        if (_selected.isEmpty) _isSelecting = false;
      } else {
        _selected.add(docId);
      }
    });
  }

  Future<void> _deleteSelected() async {
    if (_selected.isEmpty) return;
    final count = _selected.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notifications'),
        content: Text('Delete $count selected notification${count > 1 ? 's' : ''}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await NotificationService.instance.deleteMultiple(_selected.toList());
    _exitSelectionMode();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$count notification${count > 1 ? 's' : ''} deleted')),
      );
    }
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text('Are you sure you want to clear all notifications? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await NotificationService.instance.clearAll();
    _exitSelectionMode();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All notifications cleared')),
      );
    }
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
                  child: _isSelecting
                      ? Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: _exitSelectionMode,
                            ),
                            Text('${_selected.length} selected',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            const Spacer(),
                            TextButton.icon(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              label: const Text('Delete', style: TextStyle(color: Colors.red)),
                              onPressed: _selected.isEmpty ? null : _deleteSelected,
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: AppBarWithIcon(
                                title: 'Notifications',
                                onLeadingPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
                              ),
                            ),
                            if (notifications.isNotEmpty) ...[
                              TextButton(
                                onPressed: () => NotificationService.instance.markAllAsRead(snapshot.data!),
                                child: const Text('Read all'),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, color: AppColors.text),
                                onSelected: (value) {
                                  if (value == 'select') {
                                    setState(() => _isSelecting = true);
                                  } else if (value == 'clear') {
                                    _clearAll();
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(value: 'select', child: Text('Select & Delete')),
                                  const PopupMenuItem(value: 'clear', child: Text('Clear All')),
                                ],
                              ),
                            ],
                          ],
                        ),
                ),
                Expanded(
                  child: notifications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.notifications_off_outlined, size: 64, color: AppColors.textLight.withValues(alpha: 0.5)),
                              const SizedBox(height: 16),
                              Text(
                                'No notifications yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textLight,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'You\'re all caught up!',
                                style: TextStyle(fontSize: 13, color: AppColors.textLight.withValues(alpha: 0.7)),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          itemCount: notifications.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final doc = notifications[index];
                            final data = doc.data();
                            final unread = data['isRead'] != true;
                            final statusStr = _statusFromType(data['type']?.toString());
                            final isSelected = _selected.contains(doc.id);
                            
                            return InkWell(
                              onTap: () async {
                                if (_isSelecting) {
                                  _toggleSelect(doc.id);
                                  return;
                                }
                                if (unread) await NotificationService.instance.markAsRead(doc.id);
                                final relatedId = data['relatedId']?.toString();
                                if (relatedId != null && relatedId.isNotEmpty) widget.onNotificationTap?.call(relatedId);
                              },
                              onLongPress: () {
                                if (!_isSelecting) {
                                  setState(() => _isSelecting = true);
                                }
                                _toggleSelect(doc.id);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFFFEBEE)
                                      : (unread ? const Color(0xFFE0F2F1) : Colors.white),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.red
                                        : (unread ? const Color(0xFF0F6B5C) : AppColors.border),
                                    width: isSelected || unread ? 1 : 0.5,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (_isSelecting)
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8, top: 2),
                                        child: Icon(
                                          isSelected ? Icons.check_circle : Icons.circle_outlined,
                                          color: isSelected ? Colors.red : AppColors.textLight,
                                          size: 22,
                                        ),
                                      )
                                    else if (unread)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        margin: const EdgeInsets.only(top: 6, right: 8),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      )
                                    else
                                      const SizedBox(width: 16),
                                      
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
