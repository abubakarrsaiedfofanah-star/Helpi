import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../core/theme.dart';

class OfferScreen extends StatefulWidget {
  const OfferScreen({super.key});

  @override
  State<OfferScreen> createState() => _OfferScreenState();
}

class _OfferScreenState extends State<OfferScreen> {
  final title = TextEditingController(text: 'Financial Support Contribution');
  final desc = TextEditingController(
      text: 'Offering secure monetary assistance for verified needs.');
  final amount = TextEditingController(text: '5000');
  final currencyInput = TextEditingController(text: 'KES');
  String country = 'KE';
  bool busy = false;

  @override
  void dispose() {
    title.dispose();
    desc.dispose();
    amount.dispose();
    currencyInput.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final amt = int.tryParse(amount.text.trim());
    if (amt == null || amt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please enter a valid financial support amount.')));
      return;
    }
    setState(() => busy = true);
    try {
      await context.read<AppState>().api.createOffer({
        'type': 'MONEY',
        'title': title.text.trim(),
        'description': desc.text.trim(),
        'amountMinor': amt,
        'currency': currencyInput.text.trim().toUpperCase(),
        'countryCode': country,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('Financial assistance offer published successfully.')));
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
        appBar: AppBar(title: const Text('Financial Assistance & Giving')),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                    16, 16, 16, MediaQuery.viewInsetsOf(c).bottom + 32),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: orange, borderRadius: BorderRadius.circular(24)),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.monetization_on,
                            color: Colors.white, size: 32),
                        SizedBox(height: 10),
                        Text('I can help someone',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900)),
                        SizedBox(height: 6),
                        Text(
                            'Offer financial support directly to a person who needs it. No proof or documents are required.',
                            style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                      controller: title,
                      decoration: const InputDecoration(
                          labelText: 'Contribution title',
                          prefixIcon: Icon(Icons.title))),
                  const SizedBox(height: 12),
                  TextField(
                      controller: desc,
                      maxLines: 4,
                      decoration: const InputDecoration(
                          labelText: 'Financial support description',
                          prefixIcon: Icon(Icons.description))),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                        child: TextField(
                            controller: amount,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Amount (Minor units)',
                                prefixIcon: Icon(Icons.attach_money)))),
                    const SizedBox(width: 12),
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
                  ]),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: busy ? null : save,
                    style: FilledButton.styleFrom(
                        backgroundColor: orange,
                        padding: const EdgeInsets.all(16)),
                    child: Text(busy
                        ? 'PUBLISHING...'
                        : 'PUBLISH FINANCIAL ASSISTANCE'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
