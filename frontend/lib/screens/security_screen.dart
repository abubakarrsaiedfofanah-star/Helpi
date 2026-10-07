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
    try {
      final setup = await a.setupMfa();
      if (!mounted) return;
      final code = TextEditingController();
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Enable MFA'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Save this setup secret somewhere secure, then enter the generated 6-digit code.'),
              const SizedBox(height: 12),
              SelectableText(setup['secret'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(controller: code, keyboardType: TextInputType.number, maxLength: 6, decoration: const InputDecoration(labelText: '6-digit code')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Enable')),
          ],
        ),
      );
      if (ok == true) {
        await a.enableMfa(code.text);
        await load();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
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
                    subtitle: Text(mfaEnabled ? 'MFA is enabled.' : 'Enable MFA for stronger account protection.'),
                    trailing: mfaEnabled
                        ? const Icon(Icons.check_circle, color: green)
                        : FilledButton(onPressed: mfa, child: const Text('Enable')),
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
