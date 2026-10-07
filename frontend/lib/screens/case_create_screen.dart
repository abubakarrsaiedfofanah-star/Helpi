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
  String category = 'MEDICAL';
  String country = 'KE';
  bool busy = false;
  bool anonymous = false;

  final cats = [
    'MEDICAL',
    'FOOD',
    'EDUCATION',
    'HOUSING',
    'WATER',
    'DISABILITY',
    'EMERGENCY',
    'COMMUNITY',
    'FAMILY',
    'FARMING',
    'ELDERLY',
    'OTHER'
  ];

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
            ? 'ANONYMOUS'
            : (alias.text.trim().isNotEmpty ? 'ALIAS' : 'REAL_NAME'),
        'publicDisplayName':
            alias.text.trim().isEmpty ? null : alias.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Financial help request posted successfully. Helpers can now connect with you.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
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
                                    'Tell helpers what financial support you need and how much. No evidence or documents are required.',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        height: 1.4))),
                          ]),
                    ),
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
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
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
                          maxLength: 3,
                          textCapitalization: TextCapitalization.characters,
                          decoration:
                              const InputDecoration(labelText: 'Currency'),
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
                        'Other users see Anonymous Helpi Member or your chosen alias. Helpi keeps your account identity private.'),
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
                    child: Text(
                        busy ? 'POSTING...' : 'POST FINANCIAL HELP REQUEST'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
