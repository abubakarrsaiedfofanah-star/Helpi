import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../core/theme.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  final name = TextEditingController();
  final need = TextEditingController();
  final contact = TextEditingController();
  bool consent = false;
  bool busy = false;

  @override
  void dispose() {
    name.dispose();
    need.dispose();
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
            TextField(controller: need, maxLines: 5, decoration: const InputDecoration(labelText: 'What help do they need?')),
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
                      setState(() => busy = true);
                      try {
                        await c.read<AppState>().api.createReferral({
                          'personName': name.text.trim(),
                          'needSummary': need.text.trim(),
                          'safeContact': contact.text.trim().isEmpty ? null : contact.text.trim(),
                          'consentConfirmed': true,
                        });
                        if (c.mounted) {
                          ScaffoldMessenger.of(c).showSnackBar(
                            const SnackBar(content: Text('Referral captured. A full referral case will require consent and verification before publication.')),
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
