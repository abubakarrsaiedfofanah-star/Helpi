import 'package:flutter/material.dart';

import '../core/theme.dart';

class AdminPortalScreen extends StatefulWidget {
  const AdminPortalScreen({super.key});

  @override
  State<AdminPortalScreen> createState() => _AdminPortalScreenState();
}

class _AdminPortalScreenState extends State<AdminPortalScreen> {
  int tabIndex = 0;

  static const labels = [
    'Dashboard',
    'Requests',
    'Organizations',
    'Community safety',
    'Countries',
  ];

  static const icons = [
    Icons.dashboard_outlined,
    Icons.volunteer_activism_outlined,
    Icons.apartment_outlined,
    Icons.shield_outlined,
    Icons.public_outlined,
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Helpi Operations'),
          backgroundColor: navy,
          foregroundColor: Colors.white,
        ),
        body: Row(
          children: [
            NavigationRail(
              backgroundColor: navy,
              extended: MediaQuery.sizeOf(context).width >= 1000,
              selectedIndex: tabIndex,
              onDestinationSelected: (value) => setState(() => tabIndex = value),
              selectedIconTheme: const IconThemeData(color: orange),
              unselectedIconTheme: const IconThemeData(color: Colors.white60),
              selectedLabelTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelTextStyle:
                  const TextStyle(color: Colors.white70),
              destinations: List.generate(
                labels.length,
                (index) => NavigationRailDestination(
                  icon: Icon(icons[index]),
                  label: Text(labels[index]),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: bg,
                padding: const EdgeInsets.all(24),
                child: _buildTab(tabIndex),
              ),
            ),
          ],
        ),
      );

  Widget _buildTab(int index) {
    switch (index) {
      case 0:
        return ListView(
          children: [
            const Text(
              'People and groups connecting through Helpi',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                _metricCard('Support requests', '1,248', Colors.blue),
                _metricCard('Helpers', '342', Colors.orange),
                _metricCard('Organizations', '42', Colors.green),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Recent activity',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            ...[
              'A new support request was posted',
              'A helper contacted a requester',
              'A community organization joined Helpi',
            ].map((activity) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.bolt, color: orange),
                    title: Text(activity),
                  ),
                )),
          ],
        );
      case 1:
        return ListView(
          children: [
            const Text(
              'Support requests',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            ...[
              'Orphan · KES 12,000 requested',
              'War survivor · KES 8,500 requested',
              'Single parent · KES 15,000 requested',
            ].map((request) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.volunteer_activism, color: orange),
                    title: Text(request),
                  ),
                )),
          ],
        );
      case 2:
        return ListView(
          children: [
            const Text(
              'Community organizations',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            ...[
              'Global Hope NGO',
              'Bright Future Community Group',
              'City Neighbors Network',
            ].map((organization) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.apartment, color: orange),
                    title: Text(organization),
                  ),
                )),
          ],
        );
      case 3:
        return ListView(
          children: [
            const Text(
              'Community safety',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            ...[
              'Review a reported chat',
              'Review a community safety report',
            ].map((report) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.shield_outlined, color: orange),
                    title: Text(report),
                  ),
                )),
          ],
        );
      case 4:
        return ListView(
          children: [
            const Text(
              'Countries and currencies',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            ...[
              'Kenya · KES',
              'Uganda · UGX',
              'United Kingdom · GBP',
              'Nigeria · NGN',
            ].map((country) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.public, color: orange),
                    title: Text(country),
                  ),
                )),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _metricCard(String title, String value, Color color) => Container(
        width: 210,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              'Connecting people',
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
      );
}
