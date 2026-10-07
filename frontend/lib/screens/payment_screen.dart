import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../core/theme.dart';
import '../core/biometric_service.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> item;

  const PaymentScreen({super.key, required this.item});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final amount = TextEditingController();
  bool busy = false;
  String stage = 'Ready';

  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final value = double.tryParse(amount.text.trim());
    if (value == null || !value.isFinite || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount.')),
      );
      return;
    }
    if (context.read<AppState>().demoMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Preview mode does not process real payments.')),
      );
      return;
    }
    setState(() {
      busy = true;
      stage = 'Preparing secure help';
    });
    try {
      HapticFeedback.mediumImpact();
      final canBio = await BiometricService.canAuthenticate();
      if (!mounted) return;
      if (canBio) {
        final authenticated = await BiometricService.authenticate(
          reason: 'Verify your identity to confirm financial help',
        );
        if (!mounted) return;
        if (!authenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Authentication was cancelled.')),
          );
          return;
        }
      }

      setState(() => stage = 'Creating secure payment');
      final minor = (value * 100).round();
      final result = await context.read<AppState>().api.createPaymentIntent(
            widget.item['id'],
            minor,
            (widget.item['currency'] ?? 'USD').toString(),
          );
      if (!mounted) return;
      setState(() => stage = 'Waiting for provider confirmation');
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          icon: const Icon(Icons.check_circle_outline, color: green, size: 34),
          title: const Text('Secure payment created'),
          content: Text(
            'Payment intent ${result['id']} is ready. The payment is complete only after the payment provider confirms it.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
          stage = 'Ready';
        });
      }
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: const Text('Help this person')),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                    16, 18, 16, MediaQuery.viewInsetsOf(c).bottom + 28),
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [orange, orangeDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(children: [
                          Icon(Icons.favorite_outline, color: Colors.white),
                          SizedBox(width: 8),
                          Text('FINANCIAL SUPPORT',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w800)),
                        ]),
                        const SizedBox(height: 12),
                        Text(
                          widget.item['title']?.toString() ?? '',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 23,
                              fontWeight: FontWeight.w900,
                              height: 1.15),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.item['currency'] ?? ''} ${_major(widget.item['goalMinor']).toStringAsFixed(0)} goal',
                          style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text('Choose an amount',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: amount,
                    enabled: !busy,
                    autofocus: true,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      prefixText: '${widget.item['currency'] ?? ''} ',
                      hintText: '0.00',
                      helperText: 'Enter the amount you would like to give.',
                      prefixIcon: const Icon(Icons.payments_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (busy)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(children: [
                          const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: orange),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Text(stage,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700))),
                        ]),
                      ),
                    ),
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.shield_outlined, color: green),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                  'Your payment is handled through the configured payment provider. Never share your PIN, password or one-time code.'),
                            ),
                          ]),
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: busy ? null : submit,
                    icon: busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.lock_outline),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(busy ? 'Please wait' : 'Continue securely'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  double _major(dynamic value) {
    if (value is num) return value / 100;
    return (double.tryParse(value?.toString() ?? '') ?? 0) / 100;
  }
}
