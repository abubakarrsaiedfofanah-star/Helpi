import 'package:flutter/material.dart';
import '../core/theme.dart';

class AdminPortalScreen extends StatefulWidget {
  const AdminPortalScreen({super.key});

  @override State<AdminPortalScreen> createState() => _AdminPortalScreenState();
}

class _AdminPortalScreenState extends State<AdminPortalScreen> {
  int tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Helpi Admin Operations Console'),
        backgroundColor: navy,
        foregroundColor: Colors.white,
      ),
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: navy,
            selectedIndex: tabIndex,
            onDestinationSelected: (v) => setState(() => tabIndex = v),
            selectedIconTheme: const IconThemeData(color: orange),
            unselectedIconTheme: const IconThemeData(color: Colors.white60),
            selectedLabelTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Dashboard')),
              NavigationRailDestination(icon: Icon(Icons.verified_user), label: Text('Verification')),
              NavigationRailDestination(icon: Icon(Icons.payments), label: Text('Payments')),
              NavigationRailDestination(icon: Icon(Icons.school), label: Text('Scholarships')),
              NavigationRailDestination(icon: Icon(Icons.apartment), label: Text('Organizations')),
              NavigationRailDestination(icon: Icon(Icons.shield), label: Text('Fraud & Security')),
              NavigationRailDestination(icon: Icon(Icons.public), label: Text('Global Ops')),
            ],
          ),
          Expanded(
            child: Container(
              color: bg,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _buildAdminTab(tabIndex),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminTab(int index) {
    switch (index) {
      case 0:
        return ListView(
          children: [
            const Text('Admin Dashboard Overview', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                _metricCard('Active Cases', '1,248', '+12%', Colors.blue),
                _metricCard('Pending Verification', '342', '+6%', Colors.orange),
                _metricCard('Total Donations', '\$248,620', '+15%', Colors.green),
                _metricCard('Scholarships Pending', '86', '+6%', Colors.purple),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Recent Activity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            ...['New help case submitted — 2m ago', 'Payment received — 5m ago', 'Scholarship approved — 12m ago', 'Verification completed — 18m ago'].map((a) => Card(child: ListTile(leading: const Icon(Icons.bolt, color: orange), title: Text(a)))),
          ],
        );
      case 1:
        return ListView(
          children: [
            const Text('Verification Management', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            ...['Amina Hassan (Individual) — Need Review', 'Global Hope NGO (Organization) — In Review', 'James Miller (Individual) — Approved', 'Fatima Ali (Individual) — High Risk'].map((v) => Card(child: ListTile(leading: const Icon(Icons.verified_user, color: orange), title: Text(v), trailing: FilledButton(onPressed: () {}, child: const Text('Review'))))),
          ],
        );
      case 2:
        return ListView(
          children: [
            const Text('Payments & Transactions Management', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            ...['Tx #5478 — \$100.00 USD (Confirmed)', 'Tx #5479 — \$50.00 USD (Processing)', 'Tx #5480 — \$200.00 USD (Provider Confirmed)'].map((p) => Card(child: ListTile(leading: const Icon(Icons.receipt, color: green), title: Text(p), trailing: const Text('Settled', style: TextStyle(color: green, fontWeight: FontWeight.bold))))),
          ],
        );
      case 3:
        return ListView(
          children: [
            const Text('Scholarships Review Workspace', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            ...['Global Education Scholarship (Univ. of Global Studies) — Pending Review', 'Africa Leadership Scholarship (African Development Bank) — Pending Review'].map((s) => Card(child: ListTile(leading: const Icon(Icons.school, color: orange), title: Text(s), trailing: Row(mainAxisSize: MainAxisSize.min, children: [OutlinedButton(onPressed: () {}, child: const Text('Reject')), const SizedBox(width: 8), FilledButton(onPressed: () {}, child: const Text('Approve'))])))),
          ],
        );
      case 4:
        return ListView(
          children: [
            const Text('Organizations Management', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            ...['Global Hope NGO (Verified)', 'Bright Future School (Verified)', 'City Health Clinic (Pending KYB)'].map((o) => Card(child: ListTile(leading: const Icon(Icons.apartment, color: orange), title: Text(o)))),
          ],
        );
      case 5:
        return ListView(
          children: [
            const Text('Fraud & Security Monitor', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            ...['Duplicate document detected (High risk)', 'Suspicious payment destination (High risk)', 'Multiple accounts from same device (Medium risk)'].map((f) => Card(child: ListTile(leading: const Icon(Icons.warning, color: Colors.red), title: Text(f)))),
          ],
        );
      case 6:
        return ListView(
          children: [
            const Text('Global Operations & Country Config', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            ...['Kenya (KES) — Active', 'Uganda (UGX) — Active', 'United Kingdom (GBP) — Active', 'Nigeria (NGN) — Active'].map((g) => Card(child: ListTile(leading: const Icon(Icons.public, color: orange), title: Text(g)))),
          ],
        );
      default:
        return const Center(child: Text('Admin Workspace'));
    }
  }

  Widget _metricCard(String title, String val, String change, Color color) => Container(
        width: 210,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 6, offset: const Offset(0, 2))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(val, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(change, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      );
}
