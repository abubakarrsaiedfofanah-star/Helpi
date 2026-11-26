import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_state.dart';

class TrustCenterScreen extends StatefulWidget {
  const TrustCenterScreen({super.key});

  @override
  State<TrustCenterScreen> createState() => _TrustCenterScreenState();
}

class _TrustCenterScreenState extends State<TrustCenterScreen> {
  bool busy = false;

  Future<void> reportSafetyConcern() async {
    final controller = TextEditingController();
    String? validationError;
    final description = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, updateDialog) => AlertDialog(
          title: const Text('Report a safety concern'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                minLines: 3,
                maxLines: 5,
                maxLength: 3000,
                onChanged: (_) => updateDialog(() => validationError = null),
                decoration: const InputDecoration(
                  hintText: 'Tell us what happened. Please do not include passwords or payment details.',
                  border: OutlineInputBorder(),
                ),
              ),
              if (validationError != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(validationError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.length < 10) {
                  updateDialog(() => validationError = 'Please enter at least 10 characters.');
                  return;
                }
                Navigator.pop(dialogContext, value);
              },
              child: const Text('Submit report'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (description == null || !mounted) return;

    setState(() => busy = true);
    try {
      await context.read<AppState>().api.report(
            'SAFEGUARDING',
            description,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your report was submitted.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not submit report: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Trust & Safety')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Your safety matters',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Helpi connects people seeking financial support with helpers and NGOs. You choose what to share in direct conversations.',
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: const Text('Report a safety concern'),
                subtitle: const Text(
                  'Report harassment, exploitation, coercion, or unsafe contact.',
                ),
                trailing: busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right),
                onTap: busy ? null : reportSafetyConcern,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Never share passwords, PINs, or full card details in chat.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
}
