import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_state.dart';
import '../core/localization.dart';
import '../core/theme.dart';
import 'explore_screen.dart';
import 'home_screen.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int selectedIndex = helpiDemoMode ? 1 : 0;

  final pages = const [
    HomeScreen(),
    ExploreScreen(),
    MessagesScreen(),
    ProfileScreen(),
  ];

  final icons = const [
    Icons.home_outlined,
    Icons.volunteer_activism_outlined,
    Icons.chat_bubble_outline,
    Icons.person_outlined,
  ];
  final selectedIcons = const [
    Icons.home,
    Icons.volunteer_activism,
    Icons.chat_bubble,
    Icons.person,
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final l = AppLocalizations(appState.locale);
    final labels = [
      l.get('nav_home'),
      l.get('nav_find_help'),
      l.get('nav_chat'),
      l.get('nav_profile'),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // Keep bottom navigation on phones and tablets. A rail is only useful
        // once there is enough room for both it and the active page.
        final useRail = width >= 1000;
        final extendedRail = useRail;

        if (!useRail) {
          return Scaffold(
            body: SafeArea(child: pages[selectedIndex]),
            bottomNavigationBar: NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: _selectPage,
              destinations: _destinations(labels),
            ),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              SizedBox(
                width: 260,
                child: SafeArea(
                  child: NavigationRail(
                    backgroundColor: navy,
                    extended: extendedRail,
                    labelType: extendedRail
                        ? NavigationRailLabelType.none
                        : NavigationRailLabelType.all,
                    minWidth: 82,
                    minExtendedWidth: 244,
                    groupAlignment: -0.72,
                    selectedIndex: selectedIndex,
                    onDestinationSelected: _selectPage,
                    indicatorColor: orange.withValues(alpha: .2),
                    selectedIconTheme: const IconThemeData(color: orange),
                    unselectedIconTheme:
                        const IconThemeData(color: Colors.white60),
                    selectedLabelTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                    unselectedLabelTextStyle:
                        const TextStyle(color: Colors.white70),
                    leading: _railHeader(extendedRail, l),
                    destinations: List.generate(
                      labels.length,
                      (index) => NavigationRailDestination(
                        icon: Icon(icons[index]),
                        selectedIcon: Icon(selectedIcons[index]),
                        label: Text(labels[index]),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SafeArea(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1240),
                      child: pages[selectedIndex],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _railHeader(bool extended, AppLocalizations l) {
    const logo = CircleAvatar(
      radius: 20,
      backgroundColor: orange,
      child: Text(
        'H',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 20,
        ),
      ),
    );

    return Padding(
      padding:
          EdgeInsets.fromLTRB(extended ? 18 : 10, 22, extended ? 18 : 10, 22),
      child: extended
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    logo,
                    SizedBox(width: 10),
                    Text(
                      'Helpi',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  l.get('nav_brand_subtitle'),
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            )
          : logo,
    );
  }

  List<NavigationDestination> _destinations(List<String> labels) =>
      List.generate(
        labels.length,
        (index) => NavigationDestination(
          icon: Icon(icons[index]),
          selectedIcon: Icon(selectedIcons[index]),
          label: labels[index],
        ),
      );

  void _selectPage(int index) => setState(() => selectedIndex = index);
}
