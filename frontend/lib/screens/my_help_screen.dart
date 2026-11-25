import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../core/case_categories.dart';
import '../core/localization.dart';
import '../core/theme.dart';

class MyHelpScreen extends StatefulWidget {
  const MyHelpScreen({super.key});

  @override
  State<MyHelpScreen> createState() => _MyHelpScreenState();
}

class _MyHelpScreenState extends State<MyHelpScreen> {
  List<dynamic> items = [];
  bool busy = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      items = await context.read<AppState>().api.mine();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext c) {
    final l = AppLocalizations(context.watch<AppState>().locale);
    return Scaffold(
      appBar: AppBar(title: Text(l.get('my_requests'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (busy)
            const Center(child: CircularProgressIndicator(color: orange)),
          ...items.map((x) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title:
                      Text(l.category((x['category'] ?? 'OTHER').toString())),
                  subtitle: Text(
                      '${x['currency'] ?? ''} ${((x['goalMinor'] ?? 0) / 100).toStringAsFixed(0)} requested · ${(x['status'] ?? '').toString().replaceAll('_', ' ').toLowerCase()}'),
                  trailing: const Icon(Icons.chevron_right),
                ),
              )),
          if (!busy && items.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Text(l.get('requests_empty'), textAlign: TextAlign.center),
            ),
        ],
      ),
    );
  }
}
