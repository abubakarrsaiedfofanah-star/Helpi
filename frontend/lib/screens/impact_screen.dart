import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../core/theme.dart';

class ImpactScreen extends StatefulWidget {
  const ImpactScreen({super.key});

  @override
  State<ImpactScreen> createState() => _ImpactScreenState();
}

class _ImpactScreenState extends State<ImpactScreen> {
  Map<String, dynamic>? d;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      d = await context.read<AppState>().api.impact();
    } catch (_) {
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: const Text('My impact')),
        body: loading
            ? const Center(child: CircularProgressIndicator(color: orange))
            : RefreshIndicator(
                onRefresh: load,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [orange, orangeDark]),
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.public, color: Colors.white, size: 34),
                          SizedBox(height: 12),
                          Text('Every act of help matters.', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                          SizedBox(height: 5),
                          Text('Your activity is shown without ranking you against other helpers.', style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.35,
                      children: [
                        _stat('Contributions', '${d?['contributions'] ?? 0}', Icons.favorite),
                        _stat('Active offers', '${d?['activeOffers'] ?? 0}', Icons.volunteer_activism),
                        _stat('Requests created', '${d?['requestsCreated'] ?? 0}', Icons.help_outline),
                        _stat('Requests completed', '${d?['requestsCompleted'] ?? 0}', Icons.check_circle_outline),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            const Icon(Icons.receipt_long_outlined, color: orange),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Financial transparency', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                                  const SizedBox(height: 4),
                                  Text('Successful contributions recorded: ${d?['amountMinor'] ?? 0} minor currency units.', style: const TextStyle(color: Colors.black54)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      );

  Widget _stat(String title, String value, IconData icon) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: orange),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
              Text(title, style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      );
}
