import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';

class HelpCircleScreen extends StatefulWidget {
  const HelpCircleScreen({super.key});

  @override
  State<HelpCircleScreen> createState() => _HelpCircleScreenState();
}

class _HelpCircleScreenState extends State<HelpCircleScreen> {
  final List<Map<String, dynamic>> _circles = [
    {
      'name': 'Nairobi Community Family Circle',
      'goal': 'KES 150,000',
      'raised': 'KES 98,000',
      'members': 14,
      'purpose': 'Medical support coordination for school children.',
    },
    {
      'name': 'Mombasa Student Support Group',
      'goal': 'KES 80,000',
      'raised': 'KES 54,000',
      'members': 8,
      'purpose': 'Textbooks and tuition assistance.',
    },
  ];

  void _createCircleDialog() {
    final nameCtrl = TextEditingController();
    final goalCtrl = TextEditingController();
    final purposeCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Create a Help Circle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Circle Name')),
            const SizedBox(height: 10),
            TextField(controller: goalCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Goal Amount (e.g. KES 50,000)')),
            const SizedBox(height: 10),
            TextField(controller: purposeCtrl, decoration: const InputDecoration(labelText: 'Purpose / Description')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                setState(() {
                  _circles.add({
                    'name': nameCtrl.text.trim(),
                    'goal': goalCtrl.text.trim().isNotEmpty ? goalCtrl.text.trim() : 'KES 50,000',
                    'raised': 'KES 0',
                    'members': 1,
                    'purpose': purposeCtrl.text.trim().isNotEmpty ? purposeCtrl.text.trim() : 'Community assistance group.',
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Help Circle created successfully!')));
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Circles & Community'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Create Circle',
            onPressed: () {
              HapticFeedback.lightImpact();
              _createCircleDialog();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [navy, Color(0xFF1B2A4A)]),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('COORDINATE PRIVATELY', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w800)),
                SizedBox(height: 8),
                Text('Help Circles', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                SizedBox(height: 6),
                Text('Coordinate family, friends, or community support privately with role-based permissions and shared contribution tracking.', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Your Active Circles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          ..._circles.map((c) => Card(
                margin: const EdgeInsets.only(bottom: 14),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.group, color: orange),
                          const SizedBox(width: 8),
                          Expanded(child: Text(c['name']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                            child: Text('${c['members']} members', style: const TextStyle(color: orange, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(c['purpose']!, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Goal: ${c['goal']}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          Text('Raised: ${c['raised']}', style: const TextStyle(fontWeight: FontWeight.w900, color: green, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 20),
          FilledButton.icon(
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            onPressed: _createCircleDialog,
            icon: const Icon(Icons.group_add),
            label: const Text('Create a New Help Circle', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
