import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../core/theme.dart';

class CaseCreateScreen extends StatefulWidget {
  const CaseCreateScreen({super.key});

  @override
  State<CaseCreateScreen> createState() => _CaseCreateScreenState();
}

class _CaseCreateScreenState extends State<CaseCreateScreen> {
  final title = TextEditingController();
  final desc = TextEditingController();
  final goal = TextEditingController();
  final alias = TextEditingController();
  final currencyInput = TextEditingController(text: 'KES');
  String category = 'HARDSHIP';
  String country = 'KE';
  bool busy = false;
  bool anonymous = false;

  final cats = [
    'HARDSHIP',
    'JOBLESS',
    'WIDOW',
    'ORPHAN',
    'WAR_VICTIM',
    'DISABILITY',
    'OTHER'
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AppState>().user;
    country = user?['countryCode']?.toString().toUpperCase() ?? 'KE';
    currencyInput.text = country == 'KE' ? 'KES' : '';
    final identityMode = user?['publicIdentityMode']?.toString();
    anonymous = identityMode == 'ANONYMOUS' || identityMode == 'ALIAS';
    alias.text = user?['publicAlias']?.toString() ?? '';
  }

  @override
  void dispose() {
    title.dispose();
    desc.dispose();
    goal.dispose();
    alias.dispose();
    currencyInput.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final amount = double.tryParse(goal.text.trim());
    if (title.text.trim().length < 10 || desc.text.trim().length < 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Please provide a clear title and explain the financial need.')),
      );
      return;
    }
    if (amount == null || !amount.isFinite || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid goal amount.')),
      );
      return;
    }
    setState(() => busy = true);
    try {
      final api = context.read<AppState>().api;
      await api.createCase({
        'title': title.text.trim(),
        'description': desc.text.trim(),
        'category': category,
        'goalMinor': (amount * 100).round(),
        'currency': currencyInput.text.trim().toUpperCase(),
        'countryCode': country,
        'publicIdentityMode': anonymous
            ? (alias.text.trim().isEmpty ? 'ANONYMOUS' : 'ALIAS')
            : 'REAL_NAME',
        'publicDisplayName': anonymous && alias.text.trim().isNotEmpty
            ? alias.text.trim()
            : null,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request posted.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', ''))));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: const Text('Request financial help')),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                    16, 16, 16, MediaQuery.viewInsetsOf(c).bottom + 32),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  Card(
                    color: orange.withValues(alpha: .08),
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.volunteer_activism_outlined,
                                color: orange),
                            SizedBox(width: 12),
                            Expanded(
                                child: Text(
                                    'No proof or documents needed. Use the money as you choose.',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        height: 1.4))),
                          ]),
                    ),
                  ),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.language, color: orange),
                    title: Text('Kenya · KES', style: TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text('Your request uses your country’s local currency.'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                      controller: title,
                      textCapitalization: TextCapitalization.sentences,
                      maxLength: 160,
                      decoration: const InputDecoration(
                          labelText: 'What financial help do you need?',
                          prefixIcon: Icon(Icons.edit_outlined))),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    items: cats
                        .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e == 'JOBLESS' ? 'Unemployment' : e
                                .replaceAll('_', ' ')
                                .toLowerCase()
                                .split(' ')
                                .map((w) =>
                                    '${w[0].toUpperCase()}${w.substring(1)}')
                                .join(' '))))
                        .toList(),
                    onChanged: (v) => setState(() => category = v!),
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                      controller: desc,
                      textCapitalization: TextCapitalization.sentences,
                      minLines: 4,
                      maxLines: 7,
                      maxLength: 4000,
                      decoration: const InputDecoration(
                          labelText: 'Describe your need',
                          hintText:
                              'What do you need help paying for, and by when?',
                          alignLabelWithHint: true,
                          prefixIcon: Icon(Icons.notes_outlined))),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                          child: TextField(
                              controller: goal,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: const InputDecoration(
                                  labelText: 'Amount needed',
                                  hintText: 'e.g. 5000'))),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 112,
                        child: TextField(
                          controller: currencyInput,
                          readOnly: true,
                          decoration: const InputDecoration(labelText: 'Currency', helperText: 'Based on country'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Show me anonymously',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: const Text(
                        'Others see your alias or “Anonymous”. Your account stays private.'),
                    value: anonymous,
                    onChanged: (v) => setState(() => anonymous = v),
                  ),
                  if (anonymous)
                    TextField(
                      controller: alias,
                      maxLength: 40,
                      decoration: const InputDecoration(
                          labelText: 'Public alias (optional)',
                          prefixIcon: Icon(Icons.visibility_off_outlined)),
                    ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: busy ? null : save,
                    style: FilledButton.styleFrom(
                        backgroundColor: orange,
                        padding: const EdgeInsets.all(16)),
                    child: Text(busy ? 'Posting…' : 'Post request'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
