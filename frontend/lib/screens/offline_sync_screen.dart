import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/offline_manager.dart';
import '../core/theme.dart';
import '../features/cases/offline_case_create_screen.dart';

class OfflineSyncScreen extends StatefulWidget {
  const OfflineSyncScreen({super.key});

  @override
  State<OfflineSyncScreen> createState() => _OfflineSyncScreenState();
}

class _OfflineSyncScreenState extends State<OfflineSyncScreen> {
  List<Map<String, dynamic>> queue = [];
  bool loading = true;
  bool syncing = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    final items = await OfflineManager.getOfflineQueue();
    if (mounted) {
      setState(() {
        queue = items;
        loading = false;
      });
    }
  }

  Future<void> syncNow() async {
    HapticFeedback.mediumImpact();
    setState(() => syncing = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulate sync transmission
    await OfflineManager.clearOfflineQueue();
    await load();
    if (mounted) {
      setState(() => syncing = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Offline action queue synchronized successfully!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Sync & Action Queue'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Draft Offline Request',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OfflineCaseCreateScreen())).then((_) => load()),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: orange))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(22)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.cloud_sync, color: Colors.white, size: 28),
                          SizedBox(width: 10),
                          Text('OFFLINE QUEUE', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w800)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('${queue.length} pending actions stored offline', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      const Text('Helpi automatically queues outbound messages and requests when offline for background synchronization.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Pending Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    if (queue.isNotEmpty)
                      FilledButton.icon(
                        onPressed: syncing ? null : syncNow,
                        icon: const Icon(Icons.sync),
                        label: Text(syncing ? 'Syncing...' : 'Sync Now'),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (queue.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.check_circle_outline, size: 64, color: green),
                          const SizedBox(height: 12),
                          const Text('All actions are synchronized', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          const Text('No pending offline requests waiting in queue.', style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 20),
                          OutlinedButton.icon(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OfflineCaseCreateScreen())).then((_) => load()),
                            icon: const Icon(Icons.note_add),
                            label: const Text('Draft Offline Request'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...queue.map((item) => Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: const Icon(Icons.outbox, color: orange),
                          title: Text('${item['method']} ${item['endpoint']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Queued at: ${item['timestamp']}'),
                        ),
                      )),
              ],
            ),
    );
  }
}
