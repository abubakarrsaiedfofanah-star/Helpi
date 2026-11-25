import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../core/localization.dart';
import '../core/theme.dart';

class GlobalCenterScreen extends StatefulWidget {
  const GlobalCenterScreen({super.key});

  @override
  State<GlobalCenterScreen> createState() => _GlobalCenterScreenState();
}

class _GlobalCenterScreenState extends State<GlobalCenterScreen> {
  bool lowDataMode = false;
  bool offlineSyncQueueActive = true;
  String selectedCurrency = 'KES (Kenyan Shilling)';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final l = AppLocalizations(appState.locale);
    final selectedLanguage =
        AppLocalizations.supportedLanguages[appState.locale] ?? 'English';
    final items = [
      (
        'Language & translation',
        Icons.translate,
        selectedLanguage,
        () => _showLanguageSelector()
      ),
      (
        'Currency',
        Icons.currency_exchange,
        selectedCurrency,
        () => _showCurrencySelector()
      ),
      (
        'Accessibility',
        Icons.accessibility_new,
        'High contrast & large text',
        () => _showInfo(context, 'Accessibility',
            'Text size, high contrast, screen reader support and reduced motion are fully enabled.')
      ),
      (
        'Low-data mode',
        Icons.data_saver_on,
        lowDataMode ? 'Enabled (Saving bandwidth)' : 'Disabled',
        () => setState(() => lowDataMode = !lowDataMode)
      ),
      (
        'Emergency resources',
        Icons.emergency,
        'Country-specific contacts',
        () => _showInfo(context, 'Emergency Resources',
            'Find local emergency contacts and support services.')
      ),
      (
        'Privacy & anonymity',
        Icons.visibility_off,
        'Choose what appears publicly',
        () => _showInfo(context, 'Privacy & Anonymity',
            'Use an alias or anonymous public identity. Share more details directly in chat only if you choose.')
      ),
      (
        'Offline drafts & sync queue',
        Icons.cloud_off,
        offlineSyncQueueActive ? '2 drafts queued for sync' : 'All synced',
        () => _showSyncQueue()
      ),
      (
        'Safety & safeguarding',
        Icons.shield_outlined,
        '24/7 Report & review',
        () => _showInfo(context, 'Safety & Safeguarding',
            'Report abuse, unsafe contact, scams or urgent safeguarding concerns with guaranteed human review.')
      ),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Global Center')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient:
                  const LinearGradient(colors: [orange, Color(0xFFFF9A3D)]),
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.public, color: Colors.white, size: 34),
                  SizedBox(height: 14),
                  Text('Helpi, built for everywhere.',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900)),
                  SizedBox(height: 8),
                  Text(
                      'Local language, currency, accessibility, safety and connectivity should never be an afterthought.',
                      style: TextStyle(color: Colors.white, height: 1.45)),
                ]),
          ),
          const SizedBox(height: 18),
          ...items.map((x) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                      backgroundColor: orange.withValues(alpha: .12),
                      foregroundColor: orange,
                      child: Icon(x.$2)),
                  title: Text(x.$1,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(x.$3)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: x.$4,
                ),
              )),
          const SizedBox(height: 8),
          const Text('Safety principle',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(
              'Your public profile shows your category and requested amount. You control what you share in direct chat.',
              style: TextStyle(color: Colors.grey.shade700, height: 1.5)),
        ],
      ),
    );
  }

  void _showInfo(BuildContext context, String title, String body) {
    showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (_) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 21, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 10),
                    Text(body, style: const TextStyle(height: 1.5)),
                  ]),
            ));
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Language',
                        style: TextStyle(
                            fontSize: 21, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 10),
                    ...AppLocalizations.supportedLanguages.entries
                        .map((language) => ListTile(
                              title: Text(language.value),
                              trailing: sheetContext.watch<AppState>().locale ==
                                      language.key
                                  ? const Icon(Icons.check, color: orange)
                                  : null,
                              onTap: () async {
                                await sheetContext
                                    .read<AppState>()
                                    .setLocale(language.key);
                                if (mounted) Navigator.pop(sheetContext);
                              },
                            )),
                  ]),
            ));
  }

  void _showCurrencySelector() {
    showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (_) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Currency',
                        style: TextStyle(
                            fontSize: 21, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 10),
                    ...[
                      'KES (Kenyan Shilling)',
                      'USD (US Dollar)',
                      'EUR (Euro)',
                      'UGX (Ugandan Shilling)'
                    ].map((curr) => ListTile(
                          title: Text(curr),
                          trailing: selectedCurrency == curr
                              ? const Icon(Icons.check, color: orange)
                              : null,
                          onTap: () {
                            setState(() => selectedCurrency = curr);
                            Navigator.pop(context);
                          },
                        )),
                  ]),
            ));
  }

  void _showSyncQueue() {
    showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (_) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Offline Sync Queue',
                        style: TextStyle(
                            fontSize: 21, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    const Text(
                        'Items captured while offline are securely cached and ready for automatic synchronization.',
                        style: TextStyle(color: Colors.black54)),
                    const SizedBox(height: 16),
                    const Card(
                        child: ListTile(
                            leading: Icon(Icons.drafts, color: orange),
                            title: Text('Help Request Draft #402'),
                            subtitle:
                                Text('Queued — Waiting for stable network'))),
                    const SizedBox(height: 8),
                    const SizedBox(height: 16),
                    FilledButton(
                        onPressed: () {
                          setState(() => offlineSyncQueueActive = false);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Sync queue successfully synchronized!')));
                        },
                        child: const Text('SYNC NOW')),
                  ]),
            ));
  }
}
