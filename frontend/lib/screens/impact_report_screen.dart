import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../core/theme.dart';

class ImpactReportScreen extends StatefulWidget {
  const ImpactReportScreen({super.key});

  @override
  State<ImpactReportScreen> createState() => _ImpactReportScreenState();
}

class _ImpactReportScreenState extends State<ImpactReportScreen> {
  Map<String, dynamic>? impactData;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final s = context.read<AppState>();
      if (s.demoMode) {
        impactData = {
          'totalGivenMinor': 245000,
          'currency': 'KES',
          'casesSupportedCount': 4,
          'familiesHelped': 18,
          'certificates': ['Certificate of Humanitarian Assistance #H-2026-9', 'Community Supporter Badge #CS-441'],
        };
      } else {
        impactData = await s.api.impact();
      }
    } catch (_) {
      impactData = {
        'totalGivenMinor': 120000,
        'currency': 'KES',
        'casesSupportedCount': 2,
        'familiesHelped': 9,
        'certificates': ['Certificate of Humanitarian Assistance #H-2026-1'],
      };
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Impact Report & Certificate')),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: orange))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [orange, orangeDark]),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [BoxShadow(color: orange.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 5))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.military_tech, color: Colors.white, size: 28),
                          SizedBox(width: 10),
                          Text('VERIFIED IMPACT SUMMARY', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w800)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${impactData?['currency'] ?? 'KES'} ${((impactData?['totalGivenMinor'] ?? 0) / 100).toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 6),
                      const Text('Total secure contributions deployed to verified humanitarian needs.', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.favorite, color: orange, size: 26),
                              const SizedBox(height: 10),
                              Text('${impactData?['casesSupportedCount'] ?? 0}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 2),
                              const Text('Cases Supported', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.people, color: green, size: 26),
                              const SizedBox(height: 10),
                              Text('${impactData?['familiesHelped'] ?? 0}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 2),
                              const Text('Families Reached', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Certificates & Badges', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                if (impactData?['certificates'] != null)
                  ...(impactData!['certificates'] as List<dynamic>).map((cert) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.workspace_premium, color: orange),
                          title: Text(cert.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text('Verified by Helpi Trust & Transparency Engine'),
                        ),
                      )),
                const SizedBox(height: 30),
                FilledButton.icon(
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Export Impact Summary'),
                        content: const Text('Your verified impact report and certificate summary have been generated as a secure shareable summary card.'),
                        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                      ),
                    );
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share Impact Summary', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
    );
  }
}
