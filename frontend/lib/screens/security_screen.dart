import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../core/theme.dart';
import '../core/biometric_service.dart';
import '../features/security/user_activity_screen.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  List<dynamic> events = [];
  List<dynamic> sessions = [];
  Map<String, dynamic>? profile;
  bool busy = true;
  bool mfaBusy = false;
  bool biometricSupported = false;

  @override
  void initState() {
    super.initState();
    checkBiometrics();
    load();
  }

  Future<void> checkBiometrics() async {
    final supported = await BiometricService.canAuthenticate();
    if (mounted) setState(() => biometricSupported = supported);
  }

  Future<void> load() async {
    final a = context.read<AppState>().api;
    try {
      final r = await Future.wait([a.securityEvents(), a.sessions(), a.profile()]);
      events = r[0] as List<dynamic>;
      sessions = r[1] as List<dynamic>;
      profile = r[2] as Map<String, dynamic>;
    } catch (_) {
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> testBiometric() async {
    HapticFeedback.lightImpact();
    final ok = await BiometricService.authenticate(reason: 'Verify biometric identity for Helpi security check');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'Biometric verification successful.' : 'Biometric verification failed or cancelled.')),
      );
    }
  }

  Future<void> mfa() async {
    HapticFeedback.mediumImpact();
    final a = context.read<AppState>().api;
    TextEditingController? code;
    setState(() => mfaBusy = true);
    try {
      final setup = await a.setupMfa();
      if (!mounted) return;
      code = TextEditingController();
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Set up two-factor authentication'),
          content: SingleChildScrollView(child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Helpi to an authenticator app (such as Google Authenticator, Microsoft Authenticator, or 1Password). Enter this setup key manually:'),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: orange.withValues(alpha: .08), borderRadius: BorderRadius.circular(12)),
                child: SelectableText(setup['secret']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2)),
              ),
              Align(alignment: Alignment.centerRight, child: TextButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: setup['secret']?.toString() ?? ''));
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Setup key copied.')));
                },
                icon: const Icon(Icons.copy, size: 18), label: const Text('Copy setup key'),
              )),
              const SizedBox(height: 8),
              const Text('Then enter the current 6-digit code from the app to confirm setup.'),
              const SizedBox(height: 10),
              TextField(controller: code, keyboardType: TextInputType.number, maxLength: 6, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(labelText: '6-digit code', prefixIcon: Icon(Icons.password), counterText: '')),
            ],
          )),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirm and enable')),
          ],
        ),
      );
      if (ok == true) {
        await a.enableMfa(code.text.trim());
        await load();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      code?.dispose();
      if (mounted) setState(() => mfaBusy = false);
    }
  }

  Future<void> disableMfa() async {
    final code = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Turn off two-factor authentication?'),
        content: TextField(
          controller: code,
          keyboardType: TextInputType.number,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(labelText: 'Authenticator code', counterText: ''),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Keep it on')),
          FilledButton.tonal(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Turn off')),
        ],
      ),
    );
    if (confirmed != true || !mounted) { code.dispose(); return; }
    setState(() => mfaBusy = true);
    try {
      await context.read<AppState>().api.disableMfa(code.text.trim());
      await load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Two-factor authentication turned off.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      code.dispose();
      if (mounted) setState(() => mfaBusy = false);
    }
  }

  @override
  Widget build(BuildContext c) {
    final mfaEnabled = profile != null && profile!['mfaEnabled'] == true;
    return Scaffold(
      appBar: AppBar(title: const Text('Security Center')),
      body: busy
          ? const Center(child: CircularProgressIndicator(color: orange))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.verified_user, color: green),
                    title: const Text('Security controls'),
                    subtitle: Text(mfaEnabled ? 'An authenticator code is required at sign-in.' : 'Use an authenticator app to add a second sign-in check.'),
                    trailing: mfaEnabled
                        ? TextButton(onPressed: mfaBusy ? null : disableMfa, child: const Text('Turn off'))
                        : FilledButton(onPressed: mfaBusy ? null : mfa, child: mfaBusy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Set up')),
                  ),
                ),
                if (biometricSupported) ...[
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.fingerprint, color: orange),
                      title: const Text('Biometric Authentication'),
                      subtitle: const Text('Device biometrics are supported and active for secure actions.'),
                      trailing: FilledButton.tonal(onPressed: testBiometric, child: const Text('Test')),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.history, color: navy),
                    title: const Text('Account Activity & Audit Log'),
                    subtitle: const Text('View detailed active sessions and security event history.'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => const UserActivityScreen())),
                  ),
                ),
                const SizedBox(height: 18),
                const Text('Active sessions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                ...sessions.map((s) => ListTile(
                      leading: const Icon(Icons.devices),
                      title: Text(s['userAgent'] ?? 'Device'),
                      subtitle: Text('${s['ipAddress'] ?? 'hidden'} • expires ${s['expiresAt']}'),
                    )),
                const SizedBox(height: 18),
                const Text('Security activity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                ...events.map((e) => ListTile(
                      leading: const Icon(Icons.shield_outlined),
                      title: Text(e['action'] ?? ''),
                      subtitle: Text('${e['createdAt']} • ${e['ipAddress'] ?? ''}'),
                    )),
              ],
            ),
    );
  }
}
