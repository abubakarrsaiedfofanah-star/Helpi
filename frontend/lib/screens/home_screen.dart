import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../core/case_categories.dart';
import '../core/localization.dart';
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
                caseCategoryLabel(x['category'].toString())
                    .toLowerCase()
                    .contains(term) ||
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
    final l = AppLocalizations(s.locale);
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
                    tooltip: l.get('notifications'),
                    onPressed: () => Navigator.push(
                        c,
                        MaterialPageRoute(
                            builder: (_) => const NotificationsScreen())),
                    icon: const Icon(Icons.notifications_none)),
                IconButton(
                    tooltip: l.get('security'),
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
                        Text(l.get('hello_user', {'name': name}),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900)),
                        const SizedBox(height: 3),
                        Text(l.get('hello_tagline'),
                            style: const TextStyle(color: Colors.white70)),
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
                          child: Row(children: [
                            const Icon(Icons.visibility_outlined,
                                color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(
                                    'Preview mode · sample people and requests.',
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
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Icon(Icons.volunteer_activism_outlined,
                                    color: Colors.white),
                                SizedBox(width: 8),
                                Text('HELPI COMMUNITY',
                                    style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800))
                              ]),
                              SizedBox(height: 10),
                              Text(l.get('connect_directly'),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 23,
                                      fontWeight: FontWeight.w900)),
                              SizedBox(height: 7),
                              Text(l.get('browse_help'),
                                  style:
                                      const TextStyle(color: Colors.white70)),
                            ]),
                      ),
                      const SizedBox(height: 14),
                      // Financial Assistant Core Action Tiles
                      LayoutBuilder(builder: (context, box) {
                        final compact = box.maxWidth < 720;
                        final needHelp = _roleAction(
                          icon: Icons.volunteer_activism_outlined,
                          title: l.get('post_request'),
                          subtitle: l.get('choose_for_you_or_other'),
                          action: l.get('post_request_action'),
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
                          title: l.get('can_help'),
                          subtitle: l.get('browse_groups_chat'),
                          action: l.get('find_person_to_help'),
                          onTap: () => Navigator.push(
                              c,
                              MaterialPageRoute(
                                  builder: (_) => const ExploreScreen())),
                        );
                        return compact
                            ? Column(children: [
                                needHelp,
                                const SizedBox(height: 10),
                                canHelp,
                              ])
                            : Row(children: [
                                Expanded(child: needHelp),
                                const SizedBox(width: 12),
                                Expanded(child: canHelp),
                              ]);
                      }),
                      const SizedBox(height: 18),
                      TextField(
                          controller: q,
                          onSubmitted: (_) {
                            if (!loading) _search();
                          },
                          decoration: InputDecoration(
                              hintText: l.get('search_people_groups'),
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: IconButton(
                                  tooltip: l.get('search_requests'),
                                  onPressed: loading ? null : _search,
                                  icon: const Icon(Icons.arrow_forward)))),
                      const SizedBox(height: 22),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text(l.get('who_needs_help'),
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w900))),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilterChip(
                            selected: category == null,
                            label: Text(l.get('all_groups')),
                            onSelected: (_) {
                              category = null;
                              _search();
                            },
                          ),
                          ...caseCategoryLabels.keys
                              .map((x) => FilterChip(
                                  selected: category == x,
                                  avatar: Icon(_catIcon(x),
                                      size: 17, color: orange),
                                  label: Text(l.category(x)),
                                  onSelected: (_) {
                                    category = category == x ? null : x;
                                    q.clear();
                                    _search();
                                  }))
                              .toList()
                        ],
                      ),
                      const SizedBox(height: 22),
                      Row(children: [
                        Expanded(
                            child: Text(l.get('people_seeking_support'),
                                style: const TextStyle(
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
                              label: Text(l.get('clear_filters'))),
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
                          ? SliverFillRemaining(
                              child: Center(
                                  child: HelpiEmptyState(
                              icon: Icons.volunteer_activism_outlined,
                              title: l.get('no_requests_found'),
                              message: l.get('try_another_group'),
                            )))
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (_, i) {
                                  final item = cases[i];
                                  final goal = (item['goalMinor'] ?? 0) / 100;
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
                                                          caseCategoryLabel(
                                                              (item['category'] ??
                                                                      'OTHER')
                                                                  .toString()),
                                                          style: const TextStyle(
                                                              color: orange,
                                                              fontWeight:
                                                                  FontWeight.w900,
                                                              fontSize: 11))),
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
                                              Text(
                                                '${item['currency'] ?? ''} ${goal.toStringAsFixed(0)} requested',
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w900,
                                                ),
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
      case 'WAR_SURVIVOR':
        return Icons.shield_outlined;
      case 'DISABILITY':
        return Icons.accessible;
      case 'DISPLACED_PERSON':
        return Icons.flight_outlined;
      case 'ELDERLY':
        return Icons.elderly_outlined;
      case 'CAREGIVER':
        return Icons.volunteer_activism_outlined;
      case 'UNEMPLOYED':
        return Icons.work_off_outlined;
      default:
        return Icons.volunteer_activism_outlined;
    }
  }
}
