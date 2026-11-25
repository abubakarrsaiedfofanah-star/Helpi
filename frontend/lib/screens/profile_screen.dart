import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../core/case_categories.dart';
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
      'ANONYMOUS' => l.get('anonymous_profile'),
      'ALIAS' => l.get('public_alias'),
      _ => l.get('personal_profile'),
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
      appBar: AppBar(title: Text(l.get('profile')), actions: [
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
                      if (caseCategoryLabels
                          .containsKey(u?['supportGroup']?.toString())) ...[
                        const SizedBox(height: 5),
                        Text(
                          l.category(u!['supportGroup'].toString()),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                      ],
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
              subtitle: Text(l.get('appearance_hint'),
                  style: const TextStyle(fontSize: 12)),
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
              title: Text(l.get('language'),
                  style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text(l.get('current_language', {
                'language': AppLocalizations.supportedLanguages[s.locale] ??
                    AppLocalizations.supportedLanguages['en']!,
              })),
              trailing: SizedBox(
                width: 108,
                child: DropdownButton<String>(
                  value: s.locale,
                  underline: const SizedBox(),
                  items: AppLocalizations.supportedLanguages.entries
                      .map((entry) => DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) s.setLocale(v);
                  },
                  isExpanded: true,
                ),
              ),
            ),
          ),
          _item(c, Icons.folder_open, l.get('my_requests'),
              l.get('view_requests'), const MyHelpScreen()),
          _item(c, Icons.settings_outlined, l.get('security'),
              l.get('account_privacy'), const SecurityScreen()),
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
