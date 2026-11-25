import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../core/theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> items = [];
  bool loading = true;
  String? error;

  Future<void> load() async {
    if (mounted) setState(() { loading = true; error = null; });
    try {
      final result = await context.read<AppState>().api.notifications();
      if (mounted) setState(() => items = result);
    } catch (cause) {
      if (mounted) setState(() => error = cause.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: RefreshIndicator(
          onRefresh: load,
          child: loading
              ? const Center(child: CircularProgressIndicator(color: orange))
              : error != null
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(28),
                      children: [
                        const SizedBox(height: 90),
                        const Icon(Icons.cloud_off_outlined, size: 58, color: Colors.black38),
                        const SizedBox(height: 14),
                        const Center(child: Text('Could not load notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
                        const SizedBox(height: 8),
                        Center(child: Text(error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54))),
                        const SizedBox(height: 18),
                        Center(child: FilledButton.icon(onPressed: load, icon: const Icon(Icons.refresh), label: const Text('Try again'))),
                      ],
                    )
              : items.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        Icon(Icons.notifications_none, size: 64, color: Colors.black26),
                        SizedBox(height: 12),
                        Center(child: Text('You are all caught up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
                        SizedBox(height: 6),
                        Center(child: Text('Important updates will appear here.', style: TextStyle(color: Colors.black54))),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (c, i) {
                        final n = items[i] as Map<String, dynamic>;
                        final unread = n['readAt'] == null;
                        return Card(
                          color: unread ? Colors.white : Colors.white70,
                          child: ListTile(
                            onTap: () async {
                              if (unread) {
                                try {
                                  await context.read<AppState>().api.markNotificationRead(n['id'].toString());
                                  await load();
                                } catch (cause) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Could not update notification: $cause')),
                                    );
                                  }
                                }
                              }
                            },
                            leading: CircleAvatar(
                              backgroundColor: orange.withValues(alpha: .12),
                              foregroundColor: orange,
                              child: Icon(_icon(n['type'])),
                            ),
                            title: Text(n['title'] ?? 'Update', style: TextStyle(fontWeight: unread ? FontWeight.w800 : FontWeight.w600)),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(n['body'] ?? ''),
                            ),
                            trailing: unread ? const Icon(Icons.circle, size: 9, color: orange) : null,
                          ),
                        );
                      },
                    ),
        ),
      );

  IconData _icon(dynamic t) {
    switch (t?.toString()) {
      case 'SECURITY':
        return Icons.shield_outlined;
      case 'PAYMENT':
        return Icons.payments_outlined;
      case 'MESSAGE':
        return Icons.chat_bubble_outline;
      case 'VERIFICATION':
        return Icons.verified_outlined;
      default:
        return Icons.notifications_none;
    }
  }
}
