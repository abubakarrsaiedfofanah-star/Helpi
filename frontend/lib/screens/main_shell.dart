import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'help_screen.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';
import '../core/theme.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int i = 0;
  final pages = const [HomeScreen(), ExploreScreen(), HelpScreen(), MessagesScreen(), ProfileScreen()];
  final labels = const ['Home', 'Explore', 'Help', 'Messages', 'Profile'];
  final icons = const [Icons.home_outlined, Icons.explore_outlined, Icons.volunteer_activism_outlined, Icons.chat_bubble_outline, Icons.person_outlined];
  final selectedIcons = const [Icons.home, Icons.explore, Icons.volunteer_activism, Icons.chat_bubble, Icons.person];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final width = box.maxWidth;
      final desktop = width >= 1100;
      final tablet = width >= 720 && width < 1100;
      if (desktop || tablet) {
        return Scaffold(
          body: Row(children: [
            SafeArea(
              child: NavigationRail(
                backgroundColor: navy,
                extended: desktop,
                minWidth: 76,
                minExtendedWidth: 238,
                selectedIndex: i,
                onDestinationSelected: (v) => setState(() => i = v),
                indicatorColor: orange.withValues(alpha: .2),
                selectedIconTheme: const IconThemeData(color: orange),
                unselectedIconTheme: const IconThemeData(color: Colors.white60),
                selectedLabelTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
                leading: Padding(
                  padding: EdgeInsets.symmetric(horizontal: desktop ? 16 : 10, vertical: 18),
                  child: desktop
                      ? const Row(children: [CircleAvatar(radius: 20, backgroundColor: orange, child: Text('H', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20))), SizedBox(width: 10), Text('Helpi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22))])
                      : const CircleAvatar(radius: 20, backgroundColor: orange, child: Text('H', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20))),
                ),
                destinations: List.generate(labels.length, (index) => NavigationRailDestination(icon: Icon(icons[index]), selectedIcon: Icon(selectedIcons[index]), label: Text(labels[index]))),
              ),
            ),
            Expanded(child: SafeArea(child: Align(alignment: Alignment.topCenter, child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1240), child: pages[i])))),
          ]),
        );
      }
      return Scaffold(
        body: SafeArea(child: pages[i]),
        bottomNavigationBar: NavigationBar(
          selectedIndex: i,
          onDestinationSelected: (v) => setState(() => i = v),
          destinations: List.generate(labels.length, (index) => NavigationDestination(icon: Icon(icons[index]), selectedIcon: Icon(selectedIcons[index]), label: labels[index])),
        ),
      );
    });
  }
}
