import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../core/theme.dart';
import '../core/localization.dart';
import 'security_screen.dart';
import 'my_help_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext c) {
    final s = c.watch<AppState>();
    final l = AppLocalizations(s.locale);
    final u = s.user;
    final name = (u?['name'] ?? 'David Wilson').toString();
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile'), actions: [IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => Navigator.push(c, MaterialPageRoute(builder: (_) => const SecurityScreen())))]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(24)),
            child: Row(
              children: [
                Stack(
                  children: [
                    const CircleAvatar(radius: 32, backgroundColor: orange, child: Text('DW', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900))),
                    Positioned(bottom: 0, right: 0, child: Container(padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: green, shape: BoxShape.circle), child: const Icon(Icons.check, size: 14, color: Colors.white))),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 3),
                      const Row(children: [Icon(Icons.verified, size: 15, color: green), SizedBox(width: 5), Text('Verified Financial User', style: TextStyle(color: green, fontWeight: FontWeight.bold, fontSize: 13))]),
                      const SizedBox(height: 4),
                      Text(u?['email'] ?? 'david.wilson@helpi.local', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            _stat('\$1,250', 'Total Donated'),
            const SizedBox(width: 10),
            _stat('3', 'Requests Funded'),
          ]),
          const SizedBox(height: 16),
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: SwitchListTile(
              secondary: CircleAvatar(backgroundColor: orange.withValues(alpha: .12), foregroundColor: orange, child: const Icon(Icons.dark_mode_outlined)),
              title: Text(l.get('dark_mode'), style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text('Toggle light or dark Material 3 theme', style: TextStyle(fontSize: 12)),
              value: s.isDarkMode,
              onChanged: (_) => s.toggleTheme(),
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFE3F2FD), foregroundColor: Colors.blue, child: Icon(Icons.language)),
              title: const Text('Language / Lugha / Langue', style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text('Current: ${s.locale.toUpperCase()}'),
              trailing: DropdownButton<String>(
                value: s.locale,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'sw', child: Text('Swahili')),
                  DropdownMenuItem(value: 'fr', child: Text('Français')),
                ],
                onChanged: (v) {
                  if (v != null) s.setLocale(v);
                },
              ),
            ),
          ),
          _item(c, Icons.folder_open, 'My Financial Requests', 'Manage your monetary assistance cases', const MyHelpScreen()),
          _item(c, Icons.favorite_border, 'My Donations & Ledger', 'Track your financial contributions and receipts', const ImpactScreenStub()),
          _item(c, Icons.settings_outlined, 'Settings & Security', 'MFA, password, privacy and security', const SecurityScreen()),
          const SizedBox(height: 20),
          FilledButton.tonalIcon(
            onPressed: () => s.logout(),
            icon: const Icon(Icons.logout),
            label: Text(l.get('sign_out')),
          ),
        ],
      ),
    );
  }

  Widget _stat(String val, String label) => Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              children: [
                Text(val, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: orange)),
                const SizedBox(height: 3),
                Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      );

  Widget _item(BuildContext c, IconData icon, String title, String sub, Widget page, {Color? color}) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: CircleAvatar(backgroundColor: (color ?? orange).withValues(alpha: .12), foregroundColor: color ?? orange, child: Icon(icon)),
          title: Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: color)),
          subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => page)),
        ),
      );
}

class ImpactScreenStub extends StatelessWidget {
  const ImpactScreenStub({super.key});
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: const Text('My Donations & Ledger')), body: const Center(child: Text('Your financial contribution ledger and impact receipts.')));
}
