import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../core/case_categories.dart';
import '../core/theme.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  final name = TextEditingController();
  final amount = TextEditingController();
  final contact = TextEditingController();
  String? category;
  bool consent = false;
  bool busy = false;

  @override
  void dispose() {
    name.dispose();
    amount.dispose();
    contact.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: const Text('Refer someone')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Only refer another person when you have their permission. Do not publish sensitive medical, financial or exact-location information.'),
              ),
            ),
            const SizedBox(height: 14),
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Person’s name')),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: category,
              items: caseCategoryLabels.entries
                  .map((entry) => DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => category = value),
              decoration: const InputDecoration(labelText: 'Their group'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: amount,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'Amount and currency they are seeking',
                hintText: 'e.g. KES 5,000',
              ),
            ),
            const SizedBox(height: 10),
            TextField(controller: contact, decoration: const InputDecoration(labelText: 'Safe contact method (optional)')),
            CheckboxListTile(
              value: consent,
              onChanged: (v) => setState(() => consent = v ?? false),
              title: const Text('I confirm they agreed to this referral.'),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: !consent || busy
                  ? null
                  : () async {
                      if (name.text.trim().length < 2 ||
                          category == null ||
                          amount.text.trim().isEmpty) {
                        ScaffoldMessenger.of(c).showSnackBar(
                          const SnackBar(
                            content: Text('Enter their name, group, and requested amount.'),
                          ),
                        );
                        return;
                      }
                      setState(() => busy = true);
                      try {
                        await c.read<AppState>().api.createReferral({
                          'personName': name.text.trim(),
                          'needSummary': 'Group: ${caseCategoryLabel(category!)}. Amount requested: ${amount.text.trim()}.',
                          'safeContact': contact.text.trim().isEmpty ? null : contact.text.trim(),
                          'consentConfirmed': true,
                        });
                        if (c.mounted) {
                          ScaffoldMessenger.of(c).showSnackBar(
                            const SnackBar(content: Text('Referral saved. They can post their group and requested amount when they are ready.')),
                          );
                          Navigator.pop(c);
                        }
                      } catch (e) {
                        if (c.mounted) {
                          ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                      } finally {
                        if (mounted) setState(() => busy = false);
                      }
                    },
              style: FilledButton.styleFrom(backgroundColor: orange, padding: const EdgeInsets.all(16)),
              child: Text(busy ? 'SENDING...' : 'SEND REFERRAL'),
            ),
          ],
        ),
      );
}
