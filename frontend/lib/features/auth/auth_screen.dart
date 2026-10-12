import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../core/theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final alias = TextEditingController();
  bool register = false;
  bool showPassword = false;
  bool busy = false;
  bool anonymousPublic = false;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    alias.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (busy || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() => busy = true);
    final state = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      String? error;
      if (register) {
        error = await state.register(
          name.text.trim(),
          email.text.trim(),
          password.text,
          'KE',
          anonymousPublic: anonymousPublic,
          publicAlias: anonymousPublic ? alias.text.trim() : null,
        );
        if (error == null && mounted) {
          setState(() => register = false);
          messenger.showSnackBar(
            const SnackBar(
                content:
                    Text('Account created. Verify your email to sign in.')),
          );
        }
      } else {
        error = await state.login(email.text.trim(), password.text);
        if (error != null && error.toLowerCase().contains('mfa') && mounted) {
          final code = await _mfaDialog();
          if (code != null && code.isNotEmpty) {
            error =
                await state.login(email.text.trim(), password.text, mfa: code);
          }
        }
      }

      if (error != null && error.isNotEmpty && mounted) {
        messenger.showSnackBar(SnackBar(content: Text(error)));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<String?> _mfaDialog() async {
    final code = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Security code'),
        content: TextField(
          controller: code,
          autofocus: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(labelText: '6-digit code'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, code.text.trim()),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    code.dispose();
    return result;
  }

  Future<void> _enterPreview() async {
    setState(() => busy = true);
    try {
      final error =
          await context.read<AppState>().login('demo@helpi.local', 'demo');
      if (error != null && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error)));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  String? _emailError(String? value) {
    final candidate = (value ?? '').trim();
    if (candidate.isEmpty) return 'Enter your email.';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(candidate)) {
      return 'Enter a valid email.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [orange, orangeDark],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 430;
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(compact ? 16 : 24),
                      child: Card(
                        elevation: 8,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(compact ? 22 : 32),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Center(
                                  child: CircleAvatar(
                                    radius: compact ? 38 : 44,
                                    backgroundColor:
                                        orange.withValues(alpha: .1),
                                    child: Image.asset(
                                      'assets/helpi_logo.png',
                                      height: compact ? 54 : 62,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.volunteer_activism_outlined,
                                        color: orange,
                                        size: 42,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  register
                                      ? 'Create your account'
                                      : 'Welcome back',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: navy,
                                    fontSize: compact ? 25 : 29,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  register
                                      ? 'Give or receive financial help.'
                                      : 'Sign in to continue.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.black54),
                                ),
                                if (helpiDemoMode) ...[
                                  const SizedBox(height: 14),
                                  Center(
                                    child: Chip(
                                      avatar: const Icon(
                                          Icons.visibility_outlined,
                                          size: 17,
                                          color: orangeDark),
                                      label: const Text('Preview mode'),
                                      backgroundColor:
                                          orange.withValues(alpha: .1),
                                      side: BorderSide.none,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 24),
                                if (register) ...[
                                  TextFormField(
                                    controller: name,
                                    enabled: !busy,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    textInputAction: TextInputAction.next,
                                    autofillHints: const [AutofillHints.name],
                                    validator: (value) =>
                                        (value ?? '').trim().length < 2
                                            ? 'Enter your name.'
                                            : null,
                                    decoration: const InputDecoration(
                                      labelText: 'Full name',
                                      prefixIcon: Icon(Icons.person_outline),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                ],
                                TextFormField(
                                  controller: email,
                                  enabled: !busy,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.email],
                                  validator: _emailError,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(Icons.email_outlined),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                TextFormField(
                                  controller: password,
                                  enabled: !busy,
                                  obscureText: !showPassword,
                                  textInputAction: TextInputAction.done,
                                  autofillHints: [
                                    register
                                        ? AutofillHints.newPassword
                                        : AutofillHints.password,
                                  ],
                                  onFieldSubmitted: (_) => submit(),
                                  validator: (value) {
                                    final candidate = value ?? '';
                                    if (candidate.isEmpty)
                                      return 'Enter your password.';
                                    if (register && candidate.length < 12) {
                                      return 'Use at least 12 characters.';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      tooltip: showPassword
                                          ? 'Hide password'
                                          : 'Show password',
                                      onPressed: busy
                                          ? null
                                          : () => setState(() =>
                                              showPassword = !showPassword),
                                      icon: Icon(showPassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined),
                                    ),
                                  ),
                                ),
                                if (register) ...[
                                  const SizedBox(height: 12),
                                  SwitchListTile.adaptive(
                                    contentPadding: EdgeInsets.zero,
                                    title: const Text(
                                      'Use an anonymous profile',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700),
                                    ),
                                    subtitle: const Text(
                                      'Others see an alias or “Anonymous”.',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    value: anonymousPublic,
                                    onChanged: busy
                                        ? null
                                        : (value) => setState(
                                            () => anonymousPublic = value),
                                  ),
                                  if (anonymousPublic) ...[
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: alias,
                                      enabled: !busy,
                                      maxLength: 40,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      decoration: const InputDecoration(
                                        labelText: 'Public alias (optional)',
                                        prefixIcon:
                                            Icon(Icons.visibility_off_outlined),
                                      ),
                                    ),
                                  ],
                                ],
                                const SizedBox(height: 20),
                                SizedBox(
                                  height: 52,
                                  child: FilledButton(
                                    onPressed: busy ? null : submit,
                                    child: busy
                                        ? const SizedBox.square(
                                            dimension: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(register
                                            ? 'Create account'
                                            : 'Sign in'),
                                  ),
                                ),
                                if (helpiDemoMode && !register) ...[
                                  const SizedBox(height: 10),
                                  OutlinedButton.icon(
                                    onPressed: busy ? null : _enterPreview,
                                    icon: const Icon(Icons.play_arrow_rounded),
                                    label: const Text('Enter preview'),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: busy
                                      ? null
                                      : () => setState(() {
                                            register = !register;
                                            _formKey.currentState?.reset();
                                          }),
                                  child: Text(register
                                      ? 'Already registered? Sign in'
                                      : 'Create an account'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
}
