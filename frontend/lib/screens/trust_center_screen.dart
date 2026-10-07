import 'package:flutter/material.dart';
import '../services/api.dart';

class TrustCenterScreen extends StatefulWidget {
  const TrustCenterScreen({super.key});

  @override
  State<TrustCenterScreen> createState() => _TrustCenterScreenState();
}

class _TrustCenterScreenState extends State<TrustCenterScreen> {
  final api = Api();
  bool busy = false;

  Future<void> safeguarding() async {
    final c = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (x) => AlertDialog(
        title: const Text('Safeguarding report'),
        content: TextField(
          controller: c,
          maxLines: 5,
          decoration: const InputDecoration(hintText: 'Describe what needs urgent attention. Do not include passwords or unnecessary private data.'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(x, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(x, true), child: const Text('Submit')),
        ],
      ),
    );
    if (ok == true && c.text.trim().isNotEmpty) {
      setState(() => busy = true);
      try {
        await api.call('POST', '/safeguarding/report', {'description': c.text.trim(), 'type': 'SAFETY'});
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Safeguarding report submitted securely.')));
      } finally {
        if (mounted) setState(() => busy = false);
      }
    }
  }

  Future<void> room(String type) async {
    setState(() => busy = true);
    try {
      final r = await api.call('POST', '/communications/room', {'type': type, 'participantIds': []});
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('$type assistance'),
            content: Text(r['message']?.toString() ?? 'Secure room requested. A configured provider is required for live calls.'),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: const Text('Trust & Safety')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Your safety comes first', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Verification, safeguarding and communication tools are designed to protect people without exposing unnecessary personal information.'),
            const SizedBox(height: 20),
            const Card(
              child: ListTile(
                leading: Icon(Icons.verified_user),
                title: Text('Identity & document verification'),
                subtitle: Text('Provider-backed checks with manual review when automated checks are unavailable.'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.gavel),
                title: const Text('Safeguarding'),
                subtitle: const Text('Report abuse, exploitation, coercion or unsafe contact.'),
                onTap: busy ? null : safeguarding,
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.call),
                title: const Text('Secure voice assistance'),
                subtitle: const Text('Start a protected voice room when a provider is configured.'),
                onTap: busy ? null : () => room('VOICE'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Secure video assistance'),
                subtitle: const Text('Video rooms are created only through a configured provider.'),
                onTap: busy ? null : () => room('VIDEO'),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Never send passwords, PINs, full card details or private verification documents through ordinary chat.', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );
}
