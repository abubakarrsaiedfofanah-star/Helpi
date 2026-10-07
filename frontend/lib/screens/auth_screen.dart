import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../core/theme.dart';
import '../widgets.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool register = false, show = false, busy = false, anonymousPublic = false;
  final name = TextEditingController();
  final email = TextEditingController();
  final pass = TextEditingController();
  final alias = TextEditingController();
  String country = 'KE';

  Future<void> submit() async {
    setState(() => busy = true);
    final s = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);
    String? err;
    if (register) {
      err = await s.register(name.text, email.text, pass.text, country, anonymousPublic: anonymousPublic, publicAlias: alias.text);
      if (err == null && mounted) {
        messenger.showSnackBar(const SnackBar(content: Text('Account created. Check your email to verify it before signing in.')));
        setState(() => register = false);
      }
    } else {
      err = await s.login(email.text, pass.text);
    }
    if (err != null && mounted) {
      if (err.toLowerCase().contains('mfa')) {
        final code = await _mfaDialog();
        if (code != null) {
          err = await s.login(email.text, pass.text, mfa: code);
        }
      }
      if (err != null && err.isNotEmpty && mounted) {
        messenger.showSnackBar(SnackBar(content: Text(err)));
      }
    }
    if (mounted) setState(() => busy = false);
  }

  Future<String?> _mfaDialog() async {
    final c = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Security verification code'),
        content: TextField(
          controller: c,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(labelText: 'Enter 6-digit MFA code', prefixIcon: Icon(Icons.lock_clock)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, c.text), child: const Text('Verify')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [orange, orangeDark],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(builder: (context, constraints) {
              final compact = constraints.maxWidth < 430;
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(compact ? 16 : 24),
                    child: Card(
                      elevation: 8,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      child: Padding(
                        padding: EdgeInsets.all(compact ? 20 : 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: orange.withValues(alpha: .1), shape: BoxShape.circle),
                                child: Image.asset(
                                  'assets/helpi_logo.png',
                                  height: compact ? 64 : 84,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.monetization_on, size: 60, color: orange),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              register ? 'Create Account' : 'Welcome Back',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: compact ? 24 : 28, fontWeight: FontWeight.w900, color: navy),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              register ? 'Secure financial assistance & giving.' : 'Sign in to access your financial assistant.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.black54, fontSize: 13),
                            ),
                            if (helpiDemoMode) ...[
                              const SizedBox(height: 12),
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(color: orange.withValues(alpha: .12), borderRadius: BorderRadius.circular(30)),
                                  child: const Text('APP PREVIEW MODE ACTIVE', style: TextStyle(color: orangeDark, fontSize: 11, fontWeight: FontWeight.w900)),
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            if (register) ...[
                              TextField(
                                controller: name,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(labelText: 'Full name', prefixIcon: Icon(Icons.person_outline)),
                              ),
                              const SizedBox(height: 14),
                            ],
                            TextField(
                              controller: email,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(labelText: 'Email address', prefixIcon: Icon(Icons.email_outlined)),
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              controller: pass,
                              obscureText: !show,
                              onSubmitted: (_) => submit(),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  tooltip: show ? 'Hide password' : 'Show password',
                                  onPressed: () => setState(() => show = !show),
                                  icon: Icon(show ? Icons.visibility_off : Icons.visibility),
                                ),
                              ),
                            ),
                            if (register) ...[
                              const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text('Use at least 12 characters with letters and numbers.', style: TextStyle(fontSize: 11, color: Colors.black54)),
                              ),
                              const SizedBox(height: 8),
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Anonymous public profile', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                subtitle: const Text('Keep your public identity private while Helpi retains required security records.', style: TextStyle(fontSize: 12)),
                                value: anonymousPublic,
                                onChanged: (v) => setState(() => anonymousPublic = v),
                              ),
                              if (anonymousPublic) ...[
                                const SizedBox(height: 6),
                                TextField(
                                  controller: alias,
                                  maxLength: 40,
                                  decoration: const InputDecoration(labelText: 'Public alias (optional)', prefixIcon: Icon(Icons.visibility_off_outlined)),
                                ),
                              ],
                            ],
                            const SizedBox(height: 22),
                            HelpiLoadingButton(
                              loading: busy,
                              label: register ? 'CREATE SECURE ACCOUNT' : 'SIGN IN',
                              onPressed: submit,
                            ),
                            if (helpiDemoMode) ...[
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                onPressed: busy
                                    ? null
                                    : () async {
                                        final s = context.read<AppState>();
                                        final messenger = ScaffoldMessenger.of(context);
                                        final err = await s.login('demo@helpi.local', 'demo');
                                        if (err != null && mounted) messenger.showSnackBar(SnackBar(content: Text(err)));
                                      },
                                icon: const Icon(Icons.play_arrow_rounded, color: orange),
                                label: const Text('ENTER APP PREVIEW', style: TextStyle(fontWeight: FontWeight.w800, color: orange)),
                              ),
                            ],
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: busy ? null : () => setState(() => register = !register),
                              child: Text(
                                register ? 'Already registered? Sign in' : 'Create a secure account',
                                style: const TextStyle(fontWeight: FontWeight.w700, color: navy),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      );
}
