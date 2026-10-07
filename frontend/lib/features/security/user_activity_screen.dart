import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../core/theme.dart';

class UserActivityScreen extends StatefulWidget {
  const UserActivityScreen({super.key});

  @override
  State<UserActivityScreen> createState() => _UserActivityScreenState();
}

class _UserActivityScreenState extends State<UserActivityScreen> {
  List<dynamic> events = [];
  List<dynamic> sessions = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final api = context.read<AppState>().api;
    try {
      final res = await Future.wait([
        api.securityEvents(),
        api.sessions(),
      ]);
      if (mounted) {
        setState(() {
          events = res[0] as List<dynamic>;
          sessions = res[1] as List<dynamic>;
          loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account Activity & Security Log')),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: orange))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(22)),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.shield, color: green, size: 26),
                          SizedBox(width: 8),
                          Text('SECURITY AUDIT TRAIL', style: TextStyle(color: green, fontSize: 12, fontWeight: FontWeight.w800)),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text('Your Active Sessions & Events', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                      SizedBox(height: 4),
                      Text('Review account login activity, IP addresses, and active device sessions.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Active Sessions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                if (sessions.isEmpty)
                  const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No active session records found.')))
                else
                  ...sessions.map((s) => Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: const Icon(Icons.devices, color: orange),
                          title: Text(s['userAgent'] ?? 'Mobile Device', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('IP: ${s['ipAddress'] ?? 'hidden'} • Expires: ${s['expiresAt'] ?? ''}'),
                        ),
                      )),
                const SizedBox(height: 24),
                const Text('Recent Security Events', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                if (events.isEmpty)
                  const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No security events recorded yet.')))
                else
                  ...events.map((e) => Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: const Icon(Icons.security, color: green),
                          title: Text(e['action'] ?? 'Security Event', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('IP: ${e['ipAddress'] ?? 'hidden'} • ${e['createdAt'] ?? ''}'),
                        ),
                      )),
              ],
            ),
    );
  }
}
