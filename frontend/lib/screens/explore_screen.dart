import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../core/case_categories.dart';
import '../core/localization.dart';
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
  Widget build(BuildContext c) {
    final l = AppLocalizations(context.watch<AppState>().locale);
    return Scaffold(
      appBar: AppBar(title: Text(l.get('find_people_support'))),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
                16, 18, 16, MediaQuery.viewInsetsOf(c).bottom + 28),
            children: [
              Text(l.get('who_needs_help'),
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(l.get('filter_by_group'),
                  style: const TextStyle(color: Colors.black54, height: 1.4)),
              const SizedBox(height: 14),
              Card(
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  onTap: busy ? null : _chooseCategory,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  leading: CircleAvatar(
                    backgroundColor: orange.withValues(alpha: .12),
                    foregroundColor: orangeDark,
                    child: Icon(cat == null
                        ? Icons.grid_view_rounded
                        : caseCategoryIcon(cat!)),
                  ),
                  title: Text(
                    cat == null ? l.get('all_groups') : l.category(cat!),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(l.get('choose_group')),
                  trailing: const Icon(Icons.tune_rounded),
                ),
              ),
              const SizedBox(height: 12),
              if (busy)
                const LinearProgressIndicator(color: orange, minHeight: 3),
              if (busy) const SizedBox(height: 12),
              if (!busy && error != null)
                HelpiErrorState(message: error!, onRetry: search),
              if (!busy && error == null && data.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    data.length == 1
                        ? l.get('showing_person', {'count': '1'})
                        : l.get('showing_people', {'count': '${data.length}'}),
                    style: const TextStyle(
                        color: Colors.black54, fontWeight: FontWeight.w700),
                  ),
                ),
              if (!busy && error == null && data.isEmpty)
                HelpiEmptyState(
                  icon: Icons.volunteer_activism_outlined,
                  title: l.get('no_category_requests'),
                  message: l.get('try_another_group'),
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
  }

  Future<void> _chooseCategory() async {
    final selection = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _CategoryPickerSheet(selected: cat),
    );
    if (selection != null && mounted) {
      _selectCategory(selection == _allGroupsValue ? null : selection);
    }
  }

  void _selectCategory(String? value) {
    setState(() => cat = value);
    search();
  }
}

const _allGroupsValue = '__ALL_GROUPS__';

class _CategoryPickerSheet extends StatefulWidget {
  final String? selected;

  const _CategoryPickerSheet({required this.selected});

  @override
  State<_CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<_CategoryPickerSheet> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context.watch<AppState>().locale);
    final options = [
      (_allGroupsValue, l.get('all_groups'), Icons.grid_view_rounded),
      ...caseCategoryLabels.keys.map(
        (value) => (value, l.category(value), caseCategoryIcon(value)),
      ),
    ]
        .where(
            (option) => option.$2.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * .82,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.get('choose_group'),
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            TextField(
              onChanged: (value) => setState(() => query = value.trim()),
              decoration: InputDecoration(
                hintText: l.get('search_people_groups'),
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 620 ? 3 : 2;
                  return GridView.builder(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      mainAxisExtent: 66,
                    ),
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options[index];
                      final selected =
                          option.$1 == (widget.selected ?? _allGroupsValue);
                      return Material(
                        color:
                            selected ? const Color(0xFFFFE1D2) : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: selected ? orange : const Color(0xFFE3CFC2),
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => Navigator.pop(context, option.$1),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                Icon(option.$3,
                                    color:
                                        selected ? orangeDark : Colors.black54,
                                    size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    option.$2,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: selected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (selected)
                                  const Icon(Icons.check_circle,
                                      color: orange, size: 18),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
