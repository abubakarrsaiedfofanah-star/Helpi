import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../core/theme.dart';
import '../widgets.dart';
import 'case_create_screen.dart';
import 'explore_screen.dart';
import 'case_detail_screen.dart';
import 'security_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> cases = [];
  bool loading = true;
  String? error;
  int searchId = 0;
  String? category;
  final q = TextEditingController();

  Future<void> load() => _search();

  Future<void> _search() async {
    final currentSearch = ++searchId;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final s = context.read<AppState>();
      late final List<dynamic> results;
      if (s.demoMode) {
        final term = q.text.trim().toLowerCase();
        results = s.demoCases
            .where((x) =>
                term.isEmpty ||
                x['title'].toString().toLowerCase().contains(term) ||
                x['category'].toString().toLowerCase().contains(term))
            .where((x) => category == null || x['category'] == category)
            .toList();
      } else {
        results = await s.api.cases(q: q.text, category: category);
      }
      if (mounted && currentSearch == searchId) {
        setState(() => cases = results);
      }
    } catch (e) {
      if (mounted && currentSearch == searchId) {
        setState(() => error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted && currentSearch == searchId) {
        setState(() => loading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    final s = context.watch<AppState>();
    final name = s.displayName.split(' ').first;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: load,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: orange,
              pinned: true,
              expandedHeight: 170,
              actions: [
                IconButton(
                    tooltip: 'Notifications',
                    onPressed: () => Navigator.push(
                        c,
                        MaterialPageRoute(
                            builder: (_) => const NotificationsScreen())),
                    icon: const Icon(Icons.notifications_none)),
                IconButton(
                    tooltip: 'Security',
                    onPressed: () => Navigator.push(
                        c,
                        MaterialPageRoute(
                            builder: (_) => const SecurityScreen())),
                    icon: const Icon(Icons.shield_outlined)),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  padding: const EdgeInsets.fromLTRB(18, 82, 18, 18),
                  alignment: Alignment.bottomLeft,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Hello, $name',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900)),
                        const SizedBox(height: 3),
                        const Text(
                            'Financial help, shared directly between people.',
                            style: TextStyle(color: Colors.white70)),
                      ]),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 920),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                    child: Column(children: [
                      if (s.demoMode)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                              color: navy,
                              borderRadius: BorderRadius.circular(14)),
                          child: const Row(children: [
                            Icon(Icons.visibility_outlined,
                                color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Expanded(
                                child: Text(
                                    'Preview mode · explore financial assistance without real transactions.',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12))),
                          ]),
                        ),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [orange, orangeDark]),
                            borderRadius: BorderRadius.circular(24)),
                        child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Icon(Icons.volunteer_activism_outlined,
                                    color: Colors.white),
                                SizedBox(width: 8),
                                Text('DIRECT FINANCIAL HELP',
                                    style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800))
                              ]),
                              SizedBox(height: 10),
                              Text('Give or get financial help.',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 23,
                                      fontWeight: FontWeight.w900)),
                              SizedBox(height: 7),
                              Text(
                                  'Give or receive money. No proof needed. Use it as you choose.',
                                  style: TextStyle(color: Colors.white70)),
                            ]),
                      ),
                      const SizedBox(height: 14),
                      // Financial Assistant Core Action Tiles
                      LayoutBuilder(builder: (context, box) {
                        final compact = box.maxWidth < 560;
                        final needHelp = _roleAction(
                          icon: Icons.volunteer_activism_outlined,
                          title: 'I need financial help',
                          subtitle: 'Share what you need and how much.',
                          action: 'Create a request',
                          onTap: () async {
                            await Navigator.push(
                                c,
                                MaterialPageRoute(
                                    builder: (_) => const CaseCreateScreen()));
                            if (mounted) load();
                          },
                        );
                        final canHelp = _roleAction(
                          icon: Icons.favorite_outline,
                          title: 'I can help someone',
                          subtitle: 'Find a person and offer support.',
                          action: 'Find a person to help',
                          onTap: () => Navigator.push(
                              c,
                              MaterialPageRoute(
                                  builder: (_) => const ExploreScreen())),
                        );
                        return compact
                            ? Column(children: [
                                needHelp,
                                const SizedBox(height: 10),
                                canHelp
                              ])
                            : Row(children: [
                                Expanded(child: needHelp),
                                const SizedBox(width: 12),
                                Expanded(child: canHelp)
                              ]);
                      }),
                      const SizedBox(height: 18),
                      TextField(
                          controller: q,
                          onSubmitted: (_) {
                            if (!loading) _search();
                          },
                          decoration: InputDecoration(
                              hintText: 'Search people who need help',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: IconButton(
                                  tooltip: 'Search requests',
                                  onPressed: loading ? null : _search,
                                  icon: const Icon(Icons.arrow_forward)))),
                      const SizedBox(height: 22),
                      const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Who needs help?',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w900))),
                      const SizedBox(height: 10),
                      Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            'HARDSHIP',
                            'JOBLESS',
                            'WIDOW',
                            'ORPHAN',
                            'WAR_VICTIM',
                            'DISABILITY'
                          ]
                              .map((x) => FilterChip(
                                  selected: category == x,
                                  avatar: Icon(_catIcon(x),
                                      size: 17, color: orange),
                                  label: Text(_categoryLabel(x)),
                                  onSelected: (_) {
                                    category = category == x ? null : x;
                                    q.clear();
                                    _search();
                                  }))
                              .toList()),
                      const SizedBox(height: 22),
                      Row(children: [
                        const Expanded(
                            child: Text('People who need financial help',
                                style: TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w900))),
                        if (q.text.trim().isNotEmpty || category != null)
                          TextButton.icon(
                              onPressed: loading
                                  ? null
                                  : () {
                                      q.clear();
                                      category = null;
                                      _search();
                                    },
                              icon: const Icon(Icons.close, size: 18),
                              label: const Text('Clear filters')),
                      ]),
                      const SizedBox(height: 10),
                    ]),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: loading
                  ? const SliverFillRemaining(
                      child: Center(
                          child: CircularProgressIndicator(color: orange)))
                  : error != null
                      ? SliverFillRemaining(
                          child: Padding(
                          padding: const EdgeInsets.all(20),
                          child:
                              HelpiErrorState(message: error!, onRetry: load),
                        ))
                      : cases.isEmpty
                          ? const SliverFillRemaining(
                              child: Center(
                                  child: HelpiEmptyState(
                              icon: Icons.volunteer_activism_outlined,
                              title: 'No requests found',
                              message:
                                  'Try another search or category to find someone to support.',
                            )))
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (_, i) {
                                  final item = cases[i];
                                  final goal = (item['goalMinor'] ?? 0) / 100;
                                  final raised =
                                      (item['raisedMinor'] ?? 0) / 100;
                                  final progress = goal > 0
                                      ? (raised / goal).clamp(0.0, 1.0)
                                      : 0.0;
                                  return Center(
                                      child: ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 920),
                                    child: Card(
                                      margin: const EdgeInsets.only(bottom: 14),
                                      clipBehavior: Clip.antiAlias,
                                      child: InkWell(
                                        onTap: () async {
                                          await Navigator.push(
                                              c,
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      CaseDetailScreen(
                                                          item: item)));
                                          if (mounted) load();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(18),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 4),
                                                      decoration: BoxDecoration(
                                                          color:
                                                              orange.withValues(
                                                                  alpha: 0.1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8)),
                                                      child: Text(
                                                          (item['category'] ??
                                                                  'GENERAL')
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  color: orange,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900,
                                                                  fontSize:
                                                                      11))),
                                                  const Spacer(),
                                                  const Icon(Icons.public,
                                                      color: green, size: 18),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                      (item['countryCode'] ??
                                                              '')
                                                          .toString(),
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12,
                                                          color: Colors.grey)),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              Text(item['title'] ?? '',
                                                  style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w900)),
                                              const SizedBox(height: 6),
                                              Text(item['description'] ?? '',
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 13)),
                                              const SizedBox(height: 14),
                                              LinearProgressIndicator(
                                                  value: progress,
                                                  color: orange,
                                                  backgroundColor:
                                                      Colors.grey.shade200),
                                              const SizedBox(height: 8),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                      '${item['currency'] ?? ''} ${raised.toStringAsFixed(0)} raised of ${goal.toStringAsFixed(0)}',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          fontSize: 12)),
                                                  Text(
                                                      '${(progress * 100).toStringAsFixed(0)}%',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          color: orange,
                                                          fontSize: 12)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ));
                                },
                                childCount: cases.length,
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleAction(
      {required IconData icon,
      required String title,
      required String subtitle,
      required String action,
      required VoidCallback onTap}) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(children: [
            Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                    color: orange.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(16)),
                child: Icon(icon, color: orange, size: 27)),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style:
                          const TextStyle(color: Colors.black54, height: 1.3)),
                  const SizedBox(height: 10),
                  Row(children: [
                    Text(action,
                        style: const TextStyle(
                            color: orange, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward, color: orange, size: 17)
                  ]),
                ])),
          ]),
        ),
      ),
    );
  }

  IconData _catIcon(String cat) {
    switch (cat.toUpperCase()) {
      case 'JOBLESS':
        return Icons.work_off_outlined;
      case 'WIDOW':
        return Icons.person_outline;
      case 'ORPHAN':
        return Icons.child_care;
      case 'WAR_VICTIM':
        return Icons.shield_outlined;
      case 'DISABILITY':
        return Icons.accessible;
      default:
        return Icons.volunteer_activism_outlined;
    }
  }

  String _categoryLabel(String value) => value
      .replaceAll('_', ' ')
      .toLowerCase()
      .split(' ')
      .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}
