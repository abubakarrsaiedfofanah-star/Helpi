import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../core/theme.dart';
import '../widgets.dart';
import 'case_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String? cat;
  final List<dynamic> data = [];
  bool busy = false;
  String? error;
  int requestId = 0;

  final cats = [
    'MEDICAL',
    'FOOD',
    'EDUCATION',
    'HOUSING',
    'WATER',
    'DISABILITY',
    'EMERGENCY',
    'COMMUNITY',
    'FAMILY',
    'FARMING',
    'ELDERLY'
  ];

  Future<void> search() async {
    final currentRequest = ++requestId;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final state = context.read<AppState>();
      final results = state.demoMode
          ? state.demoCases
              .where((item) => cat == null || item['category'] == cat)
              .toList()
          : await state.api.cases(category: cat);
      if (mounted && currentRequest == requestId) {
        setState(() {
          data
            ..clear()
            ..addAll(results);
        });
      }
    } catch (e) {
      if (mounted && currentRequest == requestId) {
        setState(() => error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted && currentRequest == requestId) setState(() => busy = false);
    }
  }

  @override
  void initState() {
    super.initState();
    search();
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: const Text('Find someone to help')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                  16, 18, 16, MediaQuery.viewInsetsOf(c).bottom + 28),
              children: [
                const Text('People who need financial help',
                    style:
                        TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                const Text(
                    'Choose a request to learn about the need and offer support.',
                    style: TextStyle(color: Colors.black54, height: 1.4)),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('All needs'),
                      selected: cat == null,
                      onSelected: busy
                          ? null
                          : (_) {
                              setState(() => cat = null);
                              search();
                            },
                    ),
                    ...cats.map((x) => ChoiceChip(
                          label: Text(_categoryLabel(x)),
                          selected: cat == x,
                          onSelected: busy
                              ? null
                              : (_) {
                                  setState(() => cat = x);
                                  search();
                                },
                        )),
                  ],
                ),
                const SizedBox(height: 20),
                if (busy)
                  const Padding(
                    padding: EdgeInsets.all(28),
                    child:
                        Center(child: CircularProgressIndicator(color: orange)),
                  ),
                if (!busy && error != null)
                  HelpiErrorState(message: error!, onRetry: search),
                if (!busy && error == null && data.isEmpty)
                  const HelpiEmptyState(
                    icon: Icons.volunteer_activism_outlined,
                    title: 'No requests in this category',
                    message:
                        'Choose another category to see people who need financial help.',
                  ),
                if (!busy && error == null)
                  ...data.map((x) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CaseCard(
                          item: x,
                          onTap: () => Navigator.push(
                              c,
                              MaterialPageRoute(
                                  builder: (_) => CaseDetailScreen(item: x))),
                        ),
                      )),
              ],
            ),
          ),
        ),
      );

  String _categoryLabel(String value) =>
      value[0] + value.substring(1).toLowerCase();
}
