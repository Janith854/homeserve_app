import 'package:flutter/material.dart';
import 'dias_store.dart';
import 'dias_theme.dart';
import 'models.dart';

/// FR09 - Notifications (Create / Read / Update / Delete)
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  IconData _icon(String kind) {
    switch (kind) {
      case 'assigned':
        return Icons.person_pin_circle_outlined;
      case 'onway':
        return Icons.local_shipping_outlined;
      case 'payment':
        return Icons.payments_outlined;
      case 'rate':
        return Icons.star_outline;
      case 'emergency':
        return Icons.bolt;
      default:
        return Icons.check_circle_outline;
    }
  }

  void _showAdd(BuildContext context) {
    final titleCtrl = TextEditingController();
    final msgCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Notification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 10),
            TextField(
                controller: msgCtrl,
                decoration: const InputDecoration(labelText: 'Message')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (titleCtrl.text.trim().isEmpty) return;
              DiasStore.instance
                  .addNotification(titleCtrl.text.trim(), msgCtrl.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = DiasStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final items = store.notifications;
        final unread = items.where((n) => !n.isRead).length;
        return Scaffold(
          appBar: AppBar(
            title: Text(unread > 0 ? 'Notifications ($unread)' : 'Notifications'),
            actions: [
              TextButton(
                onPressed: unread == 0 ? null : store.markAllRead,
                child: const Text('Mark Read'),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: DiasColors.green,
            foregroundColor: Colors.white,
            onPressed: () => _showAdd(context),
            child: const Icon(Icons.add),
          ),
          body: items.isEmpty
              ? const Center(child: Text('No notifications'))
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 90),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final n = items[i];
                    return DiasCard(
                      onTap: () => store.markRead(n),
                      color: n.isRead ? Colors.white : DiasColors.greenLight,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(_icon(n.kind),
                                color: n.kind == 'emergency'
                                    ? DiasColors.red
                                    : DiasColors.green),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(n.title,
                                    style: TextStyle(
                                        fontWeight: n.isRead
                                            ? FontWeight.w500
                                            : FontWeight.w800)),
                                const SizedBox(height: 2),
                                Text(n.message,
                                    style: const TextStyle(
                                        color: DiasColors.grey, fontSize: 13)),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Text(n.timeText,
                                  style: const TextStyle(
                                      color: DiasColors.grey, fontSize: 12)),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(Icons.delete_outline, size: 20),
                                onPressed: () => store.deleteNotification(n),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
