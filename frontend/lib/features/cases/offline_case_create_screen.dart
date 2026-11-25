import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/case_categories.dart';
import '../../core/offline_manager.dart';
import '../../core/theme.dart';

class OfflineCaseCreateScreen extends StatefulWidget {
  const OfflineCaseCreateScreen({super.key});

  @override
  State<OfflineCaseCreateScreen> createState() => _OfflineCaseCreateScreenState();
}

class _OfflineCaseCreateScreenState extends State<OfflineCaseCreateScreen> {
  final goalCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  String? category;
  String currency = 'KES';
  bool busy = false;

  @override
  void dispose() {
    goalCtrl.dispose();
    cityCtrl.dispose();
    super.dispose();
  }

  Future<void> saveDraftOffline() async {
    final goal = double.tryParse(goalCtrl.text.trim()) ?? 0.0;

    if (category == null || goal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Choose your group and enter the amount you are seeking.')));
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => busy = true);

    try {
      await OfflineManager.enqueueOfflineAction('/cases', 'POST', {
        'category': category!,
        'goalMinor': (goal * 100).round(),
        'currency': currency,
        'countryCode': 'KE',
        'city': cityCtrl.text.trim().isNotEmpty ? cityCtrl.text.trim() : 'Nairobi',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Help request saved offline and queued for automatic sync!')));
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Support (Offline)')),
      body: ListView(
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
                    Icon(Icons.cloud_off, color: orange, size: 24),
                    SizedBox(width: 8),
                    Text('OFFLINE DRAFT MODE', style: TextStyle(color: orange, fontSize: 12, fontWeight: FontWeight.w800)),
                  ],
                ),
                SizedBox(height: 10),
                Text('Create requests without internet', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                SizedBox(height: 4),
                Text('Drafts are securely stored on your device and automatically synchronized when your connection is restored.', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Your group', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: category,
            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
            items: caseCategoryLabels.entries.map((entry) => DropdownMenuItem(value: entry.key, child: Text(entry.value))).toList(),
            onChanged: (v) {
              setState(() => category = v);
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Amount you are seeking', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(controller: goalCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(hintText: '50000')),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Currency', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: currency,
                      decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
                      items: const [
                        DropdownMenuItem(value: 'KES', child: Text('KES')),
                        DropdownMenuItem(value: 'USD', child: Text('USD')),
                        DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => currency = v);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('City / Location', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextField(controller: cityCtrl, decoration: const InputDecoration(hintText: 'e.g. Nairobi')),
          const SizedBox(height: 16),
          const SizedBox(height: 30),
          FilledButton.icon(
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            onPressed: busy ? null : saveDraftOffline,
            icon: const Icon(Icons.save_outlined),
            label: Text(busy ? 'Saving...' : 'Save Draft & Queue Offline', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
