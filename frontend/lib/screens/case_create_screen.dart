import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/app_state.dart';
import '../core/case_categories.dart';
import '../core/localization.dart';
import '../core/theme.dart';

class CaseCreateScreen extends StatefulWidget {
  const CaseCreateScreen({super.key, this.forSomeoneElse = false});

  final bool forSomeoneElse;

  @override
  State<CaseCreateScreen> createState() => _CaseCreateScreenState();
}

class _CaseCreateScreenState extends State<CaseCreateScreen> {
  final goal = TextEditingController();
  final alias = TextEditingController();
  final currencyInput = TextEditingController(text: 'KES');
  String? category;
  String country = 'KE';
  bool busy = false;
  bool anonymous = false;
  late bool postingForSomeoneElse;

  @override
  void initState() {
    super.initState();
    final user = context.read<AppState>().user;
    postingForSomeoneElse = widget.forSomeoneElse;
    country = user?['countryCode']?.toString().toUpperCase() ?? 'KE';
    final savedGroup = user?['supportGroup']?.toString();
    category =
        !postingForSomeoneElse && caseCategoryLabels.containsKey(savedGroup)
            ? savedGroup
            : null;
    _loadCurrency();
    final identityMode = user?['publicIdentityMode']?.toString();
    anonymous = postingForSomeoneElse ||
        identityMode == 'ANONYMOUS' ||
        identityMode == 'ALIAS';
    alias.text =
        postingForSomeoneElse ? '' : user?['publicAlias']?.toString() ?? '';
  }

  Future<void> _loadCurrency() async {
    try {
      final countries = jsonDecode(
        await rootBundle.loadString('lib/data/countries.json'),
      ) as List<dynamic>;
      final entry = countries.cast<Map<String, dynamic>>().firstWhere(
            (countryEntry) => countryEntry['code'] == country,
            orElse: () => <String, dynamic>{},
          );
      if (mounted && entry['currency'] != null) {
        setState(() => currencyInput.text = entry['currency'].toString());
      }
    } catch (_) {
      if (mounted && country == 'KE') {
        setState(() => currencyInput.text = 'KES');
      }
    }
  }

  @override
  void dispose() {
    goal.dispose();
    alias.dispose();
    currencyInput.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final l = AppLocalizations(context.read<AppState>().locale);
    if (currencyInput.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Your local currency could not be loaded.')),
      );
      return;
    }
    if (category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(postingForSomeoneElse
                ? l.get('choose_their_group_browse')
                : 'Choose the group that describes you.')),
      );
      return;
    }
    final amount = double.tryParse(goal.text.trim());
    if (amount == null || !amount.isFinite || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount.')),
      );
      return;
    }

    setState(() => busy = true);
    try {
      await context.read<AppState>().api.createCase({
        'category': category!,
        'goalMinor': (amount * 100).round(),
        'currency': currencyInput.text.trim().toUpperCase(),
        'countryCode': country,
        // When posting for another person, the publisher is the contact point
        // for helpers. Keep the recipient's identity out of the public request.
        'publicIdentityMode': postingForSomeoneElse
            ? 'ANONYMOUS'
            : anonymous
                ? (alias.text.trim().isEmpty ? 'ANONYMOUS' : 'ALIAS')
                : 'REAL_NAME',
        'publicDisplayName':
            !postingForSomeoneElse && anonymous && alias.text.trim().isNotEmpty
                ? alias.text.trim()
                : null,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(postingForSomeoneElse
                  ? 'The request is now visible to helpers.'
                  : 'Your request is now visible to helpers.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context.watch<AppState>().locale);
    return Scaffold(
      appBar: AppBar(
          title: Text(postingForSomeoneElse
              ? l.get('post_for_someone')
              : l.get('post_request'))),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.viewInsetsOf(context).bottom + 32,
              ),
              children: [
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(value: false, label: Text(l.get('for_me'))),
                    ButtonSegment(
                        value: true, label: Text(l.get('for_someone_else'))),
                  ],
                  selected: {postingForSomeoneElse},
                  onSelectionChanged: busy
                      ? null
                      : (selection) {
                          final value = selection.first;
                          final user = context.read<AppState>().user;
                          final savedGroup = user?['supportGroup']?.toString();
                          setState(() {
                            postingForSomeoneElse = value;
                            category = value
                                ? null
                                : caseCategoryLabels.containsKey(savedGroup)
                                    ? savedGroup
                                    : null;
                            anonymous = value;
                            alias.clear();
                            if (!value) {
                              final identityMode =
                                  user?['publicIdentityMode']?.toString();
                              anonymous = identityMode == 'ANONYMOUS' ||
                                  identityMode == 'ALIAS';
                              alias.text =
                                  user?['publicAlias']?.toString() ?? '';
                            }
                          });
                        },
                ),
                const SizedBox(height: 16),
                if (postingForSomeoneElse) ...[
                  Card(
                    color: orange.withValues(alpha: .08),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.chat_bubble_outline, color: orange),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l.get('identity_private'),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l.get('helpers_contact_poster'),
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.language, color: orange),
                  title: Text(
                    '$country · ${currencyInput.text}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(postingForSomeoneElse
                      ? l.get('currency_local')
                      : 'Your request uses your country’s local currency.'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  isExpanded: true,
                  items: caseCategoryLabels.entries
                      .map((entry) => DropdownMenuItem(
                            value: entry.key,
                            child: Text(l.category(entry.key),
                                overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: busy
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() => category = value);
                          }
                        },
                  decoration: InputDecoration(
                    labelText: l.get(postingForSomeoneElse
                        ? 'their_support_group'
                        : 'your_support_group'),
                    helperText: postingForSomeoneElse
                        ? l.get('choose_their_group_browse')
                        : l.get('choose_group_browse'),
                  ),
                ),
                const SizedBox(height: 8),
                const SizedBox(height: 18),
                TextField(
                  controller: goal,
                  enabled: !busy,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  decoration: InputDecoration(
                    labelText: l.get(postingForSomeoneElse
                        ? 'amount_they_seek'
                        : 'amount_you_seek'),
                    hintText: 'e.g. 5000',
                    prefixText: '${currencyInput.text} ',
                    prefixIcon: const Icon(Icons.payments_outlined),
                  ),
                ),
                const SizedBox(height: 8),
                if (!postingForSomeoneElse)
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      postingForSomeoneElse
                          ? 'Keep their identity private'
                          : 'Show me anonymously',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(postingForSomeoneElse
                        ? 'Helpers see the optional display name below, not their account details.'
                        : 'Helpers see your alias or “Anonymous”. Your account stays private.'),
                    value: anonymous,
                    onChanged: busy
                        ? null
                        : (value) => setState(() => anonymous = value),
                  ),
                if (!postingForSomeoneElse && anonymous)
                  TextField(
                    controller: alias,
                    enabled: !busy,
                    maxLength: 40,
                    decoration: InputDecoration(
                      labelText: postingForSomeoneElse
                          ? 'Display name (optional)'
                          : 'Public alias (optional)',
                      hintText: postingForSomeoneElse
                          ? 'e.g. Someone in my community'
                          : null,
                      prefixIcon: Icon(Icons.visibility_off_outlined),
                    ),
                  ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: busy ? null : save,
                  style: FilledButton.styleFrom(
                    backgroundColor: orange,
                    padding: const EdgeInsets.all(16),
                  ),
                  child: Text(busy
                      ? l.get('posting')
                      : postingForSomeoneElse
                          ? l.get('post_for_them')
                          : l.get('post_request_action')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
