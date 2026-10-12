import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../core/theme.dart';
import 'payment_screen.dart';

class CaseDetailScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  const CaseDetailScreen({super.key, required this.item});

  @override
  State<CaseDetailScreen> createState() => _CaseDetailScreenState();
}

class _CaseDetailScreenState extends State<CaseDetailScreen> {
  Future<void> report() async {
    final d = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Report this case'),
        content: TextField(
            controller: d,
            maxLines: 5,
            decoration:
                const InputDecoration(labelText: 'Tell us what seems wrong')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Report')),
        ],
      ),
    );
    if (ok == true && d.text.trim().isNotEmpty) {
      if (!mounted) {
        return;
      }
      await context
          .read<AppState>()
          .api
          .report('OTHER', d.text.trim(), caseId: widget.item['id']);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report submitted for review.')));
      }
    }
  }

  @override
  Widget build(BuildContext c) {
    final item = widget.item;
    final goal = _money(item['goalMinor']);
    final raised = _money(item['raisedMinor']);
    final progress = goal > 0 ? (raised / goal).clamp(0.0, 1.0) : 0.0;
    return Scaffold(
      appBar: AppBar(title: const Text('Financial help details'), actions: [
        IconButton(
            tooltip: 'Report request',
            onPressed: report,
            icon: const Icon(Icons.flag_outlined))
      ]),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.push(
                    c,
                    MaterialPageRoute(
                        builder: (_) => PaymentScreen(item: item))),
                icon: const Icon(Icons.favorite_outline),
                label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Help this person financially')),
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
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [orange, orangeDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(24)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.volunteer_activism_outlined,
                            color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(
                                _categoryName(item['category']),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800))),
                      ]),
                      const SizedBox(height: 8),
                      Text(item['title'] ?? '',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 27,
                              fontWeight: FontWeight.w800,
                              height: 1.15)),
                      const SizedBox(height: 10),
                      Row(children: [
                        const Icon(Icons.person_outline,
                            color: Colors.white70, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                            child: Text(_publicName(item),
                                style: const TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w600)))
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: Text(
                                        '${item['currency'] ?? ''} ${goal.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.w900,
                                            color: navy))),
                                const Text('goal',
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w700)),
                              ]),
                          const SizedBox(height: 12),
                          ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 9,
                                  color: orange,
                                  backgroundColor:
                                      orange.withValues(alpha: .12))),
                          const SizedBox(height: 8),
                          Row(children: [
                            Expanded(
                                child: Text(
                                    '${item['currency'] ?? ''} ${raised.toStringAsFixed(0)} raised',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700))),
                            Text('${(progress * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                    color: orange, fontWeight: FontWeight.w900))
                          ]),
                        ]),
                  ),
                ),
                const SizedBox(height: 18),
                Row(children: [
                  _stat('Location', (item['countryCode'] ?? '').toString(),
                      Icons.place_outlined),
                  _stat(
                      'Support type',
                      (item['category'] ?? 'Financial').toString(),
                      Icons.category_outlined)
                ]),
                const SizedBox(height: 18),
                const Text('About this need',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(item['description'] ?? '',
                    style: const TextStyle(fontSize: 16, height: 1.55)),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _money(dynamic value) => value is num
      ? value / 100
      : (double.tryParse(value?.toString() ?? '') ?? 0) / 100;

  String _publicName(Map<String, dynamic> i) {
    if (i['publicDisplayName'] != null &&
        i['publicDisplayName'].toString().trim().isNotEmpty) {
      return 'Posted by ${i['publicDisplayName']}';
    }
    final owner = i['owner'];
    if (owner is Map) {
      if (owner['publicIdentityMode'] == 'ANONYMOUS') {
        return 'Posted anonymously';
      }
      if (owner['publicIdentityMode'] == 'ALIAS' &&
          owner['publicAlias'] != null) {
        return 'Posted by ${owner['publicAlias']}';
      }
      if (owner['name'] != null) {
        return 'Posted by ${owner['name']}';
      }
    }
    return 'Posted by a Helpi member';
  }

  String _categoryName(dynamic value) {
    final category = (value ?? 'Financial need').toString();
    if (category == 'JOBLESS') return 'UNEMPLOYMENT';
    return category.replaceAll('_', ' ').toUpperCase();
  }

  Widget _stat(String a, String b, IconData icon) => Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: orange, size: 20),
                const SizedBox(height: 8),
                Text(a, style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 4),
                Text(b,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 17)),
              ],
            ),
          ),
        ),
      );
}
