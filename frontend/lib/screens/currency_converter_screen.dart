import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../core/theme.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final TextEditingController _amountController = TextEditingController(text: '1000');
  String _fromCurrency = 'KES';
  String _toCurrency = 'USD';
  double? _liveConverted;
  double? _liveRate;
  String _source = 'local';
  bool _loading = false;

  final Map<String, double> _ratesToUSD = {
    'USD': 1.0,
    'KES': 129.5,
    'EUR': 0.92,
    'GBP': 0.78,
    'TZS': 2590.0,
    'UGX': 3720.0,
  };

  @override
  void initState() {
    super.initState();
    _fetchConversion();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _fetchConversion() async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) return;
    setState(() => _loading = true);
    try {
      final api = context.read<AppState>().api;
      final res = await api.convertCurrency(amount, _fromCurrency, _toCurrency);
      if (mounted) {
        setState(() {
          _liveConverted = (res['converted'] as num?)?.toDouble();
          _liveRate = (res['rate'] as num?)?.toDouble();
          _source = res['source']?.toString() ?? 'live';
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _liveConverted = null;
          _liveRate = null;
          _source = 'local rate fallback';
          _loading = false;
        });
      }
    }
  }

  double _localConvert() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final rateFrom = _ratesToUSD[_fromCurrency] ?? 1.0;
    final rateTo = _ratesToUSD[_toCurrency] ?? 1.0;
    final amountInUSD = amount / rateFrom;
    return amountInUSD * rateTo;
  }

  @override
  Widget build(BuildContext context) {
    final result = _liveConverted ?? _localConvert();
    final rate = _liveRate ?? (_ratesToUSD[_toCurrency]! / _ratesToUSD[_fromCurrency]!);

    return Scaffold(
      appBar: AppBar(title: const Text('Currency Converter & FX')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [orange, orangeDark]), borderRadius: BorderRadius.circular(24)),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MULTI-CURRENCY FINANCIAL SUPPORT', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w800)),
                SizedBox(height: 8),
                Text('Global Currency Exchange', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                SizedBox(height: 4),
                Text('Convert financial assistance amounts seamlessly across supported currencies with live FX rates.', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) {
              setState(() {});
              _fetchConversion();
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              hintText: 'Enter amount',
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('From', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _fromCurrency,
                      decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
                      items: _ratesToUSD.keys.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _fromCurrency = v);
                          _fetchConversion();
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                padding: const EdgeInsets.only(top: 24),
                icon: const Icon(Icons.swap_horiz, size: 32, color: orange),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    final temp = _fromCurrency;
                    _fromCurrency = _toCurrency;
                    _toCurrency = temp;
                  });
                  _fetchConversion();
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('To', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _toCurrency,
                      decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
                      items: _ratesToUSD.keys.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _toCurrency = v);
                          _fetchConversion();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              children: [
                const Text('Converted Amount', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                if (_loading)
                  const CircularProgressIndicator()
                else
                  Text(
                    '${result.toStringAsFixed(2)} $_toCurrency',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: orange),
                  ),
                const SizedBox(height: 8),
                Text('1 $_fromCurrency = ${rate.toStringAsFixed(4)} $_toCurrency', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text('Rate Source: $_source', style: const TextStyle(fontSize: 10, color: Colors.black45)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

