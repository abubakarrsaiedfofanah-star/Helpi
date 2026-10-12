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
    final name = s.displayName;
    final identityMode = u?['publicIdentityMode']?.toString();
    final isAnonymous = identityMode == 'ANONYMOUS';
    final identityLabel = switch (identityMode) {
      'ANONYMOUS' => 'Anonymous profile',
      'ALIAS' => 'Public alias',
      _ => 'Personal profile',
    };
    final email = (u?['email'] ?? '').toString();
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), actions: [
        IconButton(
            tooltip: 'Security settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
                c, MaterialPageRoute(builder: (_) => const SecurityScreen())))
      ]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: navy, borderRadius: BorderRadius.circular(24)),
            child: Row(
              children: [
                CircleAvatar(
                    radius: 32,
                    backgroundColor: orange,
                    child: Text(initials,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900))),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w900)),
                      const SizedBox(height: 3),
                      Row(children: [
                        Icon(
                            isAnonymous
                                ? Icons.visibility_off_outlined
                                : Icons.person_outline,
                            size: 15,
                            color: Colors.white70),
                        const SizedBox(width: 5),
                        Text(identityLabel,
                            style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize: 13))
                      ]),
                      const SizedBox(height: 4),
                      if (!isAnonymous && email.isNotEmpty)
                        Text(email,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: SwitchListTile(
              secondary: CircleAvatar(
                  backgroundColor: orange.withValues(alpha: .12),
                  foregroundColor: orange,
                  child: const Icon(Icons.dark_mode_outlined)),
              title: Text(l.get('dark_mode'),
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text('Light or dark appearance',
                  style: TextStyle(fontSize: 12)),
              value: s.isDarkMode,
              onChanged: (_) => s.toggleTheme(),
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE3F2FD),
                  foregroundColor: Colors.blue,
                  child: Icon(Icons.language)),
              title: const Text('Language',
                  style: TextStyle(fontWeight: FontWeight.w800)),
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
          _item(c, Icons.folder_open, 'My requests',
              'View your financial help requests', const MyHelpScreen()),
          _item(c, Icons.account_balance_wallet_outlined, 'Payout method',
              'Private M-Pesa details for receiving help', const PayoutSettingsScreen()),
          _item(c, Icons.favorite_border, 'My contributions',
              'View your giving activity', const ImpactScreenStub()),
          _item(c, Icons.settings_outlined, 'Security',
              'Password and account privacy', const SecurityScreen()),
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

  Widget _item(
          BuildContext c, IconData icon, String title, String sub, Widget page,
          {Color? color}) =>
      Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: CircleAvatar(
              backgroundColor: (color ?? orange).withValues(alpha: .12),
              foregroundColor: color ?? orange,
              child: Icon(icon)),
          title: Text(title,
              style: TextStyle(fontWeight: FontWeight.w800, color: color)),
          subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () =>
              Navigator.push(c, MaterialPageRoute(builder: (_) => page)),
        ),
      );
}

class PayoutSettingsScreen extends StatefulWidget {
  const PayoutSettingsScreen({super.key});
  @override
  State<PayoutSettingsScreen> createState() => _PayoutSettingsScreenState();
}

class _PayoutSettingsScreenState extends State<PayoutSettingsScreen> {
  final phone = TextEditingController();
  bool loading = true, saving = false;
  Map<String, dynamic>? destination;
  String? error;

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { phone.dispose(); super.dispose(); }

  Future<void> _load() async {
    try { destination = await context.read<AppState>().api.payoutDestination(); }
    catch (e) { error = e.toString(); }
    if (mounted) setState(() => loading = false);
  }

  Future<void> _save() async {
    if (phone.text.trim().isEmpty) { setState(() => error = 'Enter your M-Pesa number.'); return; }
    setState(() { saving = true; error = null; });
    try {
      destination = await context.read<AppState>().api.savePayoutDestination(phone.text.trim());
      phone.clear();
    } catch (e) { error = e.toString(); }
    if (mounted) setState(() => saving = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Payout method')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      const Card(child: Padding(padding: EdgeInsets.all(16), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.lock_outline, color: green), SizedBox(width: 12), Expanded(child: Text('Your payout number is private. Only you can view its last digits. Helpi stores it encrypted for payout processing.'))]))),
      const SizedBox(height: 18),
      const Text('Kenya · M-Pesa', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      if (loading) const LinearProgressIndicator(),
      if (!loading && destination != null) Card(child: ListTile(leading: const Icon(Icons.phone_android, color: orange), title: Text('•••• ${destination!['displayLast4'] ?? '••••'}'), subtitle: Text('Status: ${destination!['status'] ?? 'PENDING'}'), trailing: const Icon(Icons.lock_outline))),
      if (!loading) TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'M-Pesa number', hintText: '+254 7xx xxx xxx', prefixIcon: Icon(Icons.phone_outlined))),
      if (error != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(error!, style: const TextStyle(color: Colors.red))),
      const SizedBox(height: 18),
      FilledButton(onPressed: loading || saving ? null : _save, child: Text(saving ? 'Saving…' : destination == null ? 'Save payout number' : 'Update payout number')),
      const SizedBox(height: 12),
      const Text('Payouts are not live until Helpi has active M-Pesa collection and disbursement credentials.', style: TextStyle(color: Colors.black54, height: 1.4)),
    ]),
  );
}

class ImpactScreenStub extends StatelessWidget {
  const ImpactScreenStub({super.key});
  @override
  Widget build(BuildContext c) => Scaffold(
      appBar: AppBar(title: const Text('My Donations & Ledger')),
      body: const Center(
          child:
              Text('Your financial contribution ledger and impact receipts.')));
}
