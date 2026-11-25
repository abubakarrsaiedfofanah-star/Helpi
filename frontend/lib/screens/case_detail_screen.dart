import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_state.dart';
import '../core/case_categories.dart';
import '../core/theme.dart';
import 'messages_screen.dart';

class CaseDetailScreen extends StatefulWidget {
  final Map<String, dynamic> item;

  const CaseDetailScreen({super.key, required this.item});

  @override
  State<CaseDetailScreen> createState() => _CaseDetailScreenState();
}

class _CaseDetailScreenState extends State<CaseDetailScreen> {
  bool contacting = false;

  Future<void> _offerAndContact() async {
    final amount = TextEditingController();
    final currency = (widget.item['currency'] ?? '').toString();
    final value = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Offer an amount'),
        content: TextField(
          controller: amount,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Amount you would like to offer',
            prefixText: '$currency ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final parsed = double.tryParse(amount.text.trim());
              if (parsed != null && parsed.isFinite && parsed > 0) {
                Navigator.pop(dialogContext, parsed);
              }
            },
            child: const Text('Continue to chat'),
          ),
        ],
      ),
    );
    amount.dispose();
    if (value == null || !mounted) return;

    setState(() => contacting = true);
    try {
      final state = context.read<AppState>();
      final amountMinor = (value * 100).round();
      final offerText =
          'I would like to offer $currency ${value.toStringAsFixed(2)}. Let’s connect to discuss details.';
      final Map<String, dynamic> thread = state.demoMode
          ? {
              'id': 'demo-direct-${widget.item['id']}',
              'title': 'Support request',
            }
          : await state.api
              .startCaseChat(widget.item['id'].toString(), amountMinor);
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ThreadScreen(
            id: thread['id'].toString(),
            title: thread['title']?.toString() ?? 'Support request',
            peerName: _requesterName(widget.item),
            initialMessage: state.demoMode ? offerText : null,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => contacting = false);
    }
  }

  Future<void> _report() async {
    final description = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Report this request'),
        content: TextField(
          controller: description,
          maxLines: 5,
          decoration:
              const InputDecoration(labelText: 'Tell us what seems wrong'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Report'),
          ),
        ],
      ),
    );
    if (confirmed == true && description.text.trim().isNotEmpty && mounted) {
      try {
        await context.read<AppState>().api.report(
              'OTHER',
              description.text.trim(),
              caseId: widget.item['id'],
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report submitted for review.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
    description.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final requested = _major(item['goalMinor']);
    final currency = (item['currency'] ?? '').toString();
    final category =
        caseCategoryLabel((item['category'] ?? 'OTHER').toString());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request details'),
        actions: [
          IconButton(
            tooltip: 'Report request',
            onPressed: _report,
            icon: const Icon(Icons.flag_outlined),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: contacting ? null : _offerAndContact,
                icon: contacting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.chat_bubble_outline),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(contacting
                      ? 'Opening chat…'
                      : 'Offer an amount and contact'),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [orange, orangeDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.volunteer_activism_outlined,
                              color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              category,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _requesterName(item),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        (item['countryCode'] ?? '').toString(),
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Amount requested',
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$currency ${requested.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: navy,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Helpi connects people seeking support with helpers. Contact this person directly to discuss details; you choose whether and how to help.',
                      style: TextStyle(height: 1.45),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _major(dynamic value) => value is num
      ? value / 100
      : (double.tryParse(value?.toString() ?? '') ?? 0) / 100;

  String _requesterName(Map<String, dynamic> item) {
    // A request may be posted by a helper for someone without a Helpi account.
    // Respect request-level privacy before looking at the poster's profile.
    if (item['publicIdentityMode'] == 'ANONYMOUS') return 'Anonymous member';
    final displayName = item['publicDisplayName']?.toString().trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;
    final owner = item['owner'];
    if (owner is Map) {
      if (owner['publicIdentityMode'] == 'ANONYMOUS') return 'Anonymous member';
      if (owner['publicAlias'] != null &&
          owner['publicAlias'].toString().trim().isNotEmpty) {
        return owner['publicAlias'].toString();
      }
      if (owner['name'] != null) return owner['name'].toString();
    }
    return 'Helpi member';
  }
}
