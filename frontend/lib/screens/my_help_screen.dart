import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
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
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: const Text('My requests')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (busy) const Center(child: CircularProgressIndicator(color: orange)),
            ...items.map((x) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(x['title'] ?? ''),
                    subtitle: Text((x['status'] ?? '')
                        .toString()
                        .replaceAll('_', ' ')
                        .toLowerCase()),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                )),
            if (!busy && items.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 32),
                child: Text('Your requests will appear here.', textAlign: TextAlign.center),
              ),
          ],
        ),
      );
}
