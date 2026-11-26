import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_state.dart';
import '../../core/case_categories.dart';
import '../../core/localization.dart';
import '../../core/theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  static const _adminPortalUrl = String.fromEnvironment('ADMIN_PORTAL_URL');

  final _formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final alias = TextEditingController();
  final mfaCode = TextEditingController();
  String? supportGroup;
  bool register = false;
  bool showPassword = false;
  bool busy = false;
  bool anonymousPublic = false;
  bool requiresMfa = false;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    alias.dispose();
    mfaCode.dispose();
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
          supportGroup: supportGroup,
        );
        if (error == null && mounted) {
          final developmentToken = state.lastDevelopmentVerificationToken;
          if (developmentToken != null) {
            error = await state.verifyEmail(developmentToken);
          }
        }
        if (error == null && mounted) {
          final wasVerifiedLocally =
              state.lastDevelopmentVerificationToken != null;
          setState(() => register = false);
          messenger.showSnackBar(
            SnackBar(
              content: Text(wasVerifiedLocally
                  ? 'Account created and verified for local development. You can sign in.'
                  : 'Account created. Verify your email to sign in.'),
            ),
          );
        }
      } else {
        error = await state.login(email.text.trim(), password.text,
            mfa: requiresMfa ? mfaCode.text.trim() : null);
        if (!requiresMfa &&
            error != null &&
            error.toLowerCase().contains('mfa') &&
            mounted) {
          setState(() {
            requiresMfa = true;
            mfaCode.clear();
          });
          error = null;
        } else if (error == null) {
          requiresMfa = false;
        }
      }

      if (error != null && error.isNotEmpty && mounted) {
        messenger.showSnackBar(SnackBar(content: Text(error)));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
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

  Future<void> _openAdminPortal() async {
    final uri = Uri.tryParse(_adminPortalUrl);
    if (uri == null ||
        !uri.hasAuthority ||
        !['http', 'https'].contains(uri.scheme)) return;
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (opened || !mounted) return;
    } catch (_) {
      if (!mounted) return;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the admin portal.')),
      );
    }
  }

  String? _emailError(String? value) {
    final l = AppLocalizations(context.read<AppState>().locale);
    final candidate = (value ?? '').trim();
    if (candidate.isEmpty) return l.get('enter_email');
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(candidate)) {
      return l.get('invalid_email');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context.watch<AppState>().locale);
    return Scaffold(
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
              final tightHeight = constraints.maxHeight < 640;
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(compact ? 14 : 24),
                    child: Card(
                      elevation: 8,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(compact ? 20 : 32),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (!tightHeight)
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
                              SizedBox(height: tightHeight ? 8 : 18),
                              Text(
                                requiresMfa
                                    ? l.get('auth_mfa')
                                    : register
                                        ? l.get('auth_create')
                                        : l.get('auth_welcome'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: navy,
                                  fontSize: compact ? 25 : 29,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                requiresMfa
                                    ? l.get('auth_mfa_hint')
                                    : register
                                        ? l.get('auth_join_hint')
                                        : l.get('auth_signin_hint'),
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
                                    label: Text(l.get('preview_mode')),
                                    backgroundColor:
                                        orange.withValues(alpha: .1),
                                    side: BorderSide.none,
                                  ),
                                ),
                              ],
                              SizedBox(height: tightHeight ? 14 : 24),
                              if (register) ...[
                                TextFormField(
                                  controller: name,
                                  enabled: !busy,
                                  textCapitalization: TextCapitalization.words,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.name],
                                  validator: (value) =>
                                      (value ?? '').trim().length < 2
                                          ? l.get('enter_name')
                                          : null,
                                  decoration: InputDecoration(
                                    labelText: l.get('full_name'),
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                DropdownButtonFormField<String>(
                                  value: supportGroup,
                                  items: [
                                    DropdownMenuItem<String>(
                                      value: null,
                                      child: Text(l.get('helper_option')),
                                    ),
                                    ...caseCategoryLabels.entries.map(
                                      (entry) => DropdownMenuItem<String>(
                                        value: entry.key,
                                        child: Text(l.category(entry.key)),
                                      ),
                                    ),
                                  ],
                                  onChanged: busy
                                      ? null
                                      : (value) =>
                                          setState(() => supportGroup = value),
                                  decoration: InputDecoration(
                                    labelText: l.get('support_group_optional'),
                                    helperText: l.get('support_group_hint'),
                                    prefixIcon: Icon(Icons.groups_outlined),
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
                                decoration: InputDecoration(
                                  labelText: l.get('email'),
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
                                    return l.get('enter_password');
                                  if (register && candidate.length < 12) {
                                    return l.get('password_minimum');
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: l.get('password'),
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    tooltip: showPassword
                                        ? l.get('hide_password')
                                        : l.get('show_password'),
                                    onPressed: busy
                                        ? null
                                        : () => setState(
                                            () => showPassword = !showPassword),
                                    icon: Icon(showPassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined),
                                  ),
                                ),
                              ),
                              if (requiresMfa) ...[
                                const SizedBox(height: 14),
                                TextFormField(
                                  controller: mfaCode,
                                  enabled: !busy,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.done,
                                  autofillHints: const [
                                    AutofillHints.oneTimeCode
                                  ],
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  maxLength: 6,
                                  onFieldSubmitted: (_) => submit(),
                                  validator: (value) =>
                                      (value ?? '').trim().length != 6
                                          ? l.get('enter_sixdigit')
                                          : null,
                                  decoration: InputDecoration(
                                    labelText: l.get('auth_code'),
                                    prefixIcon: Icon(Icons.shield_outlined),
                                    counterText: '',
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton.icon(
                                    onPressed: busy
                                        ? null
                                        : () => setState(() {
                                              requiresMfa = false;
                                              mfaCode.clear();
                                            }),
                                    icon:
                                        const Icon(Icons.arrow_back, size: 18),
                                    label: Text(l.get('back_password')),
                                  ),
                                ),
                              ],
                              if (register) ...[
                                const SizedBox(height: 12),
                                SwitchListTile.adaptive(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    l.get('anonymous_toggle'),
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  subtitle: Text(
                                    l.get('anonymous_hint'),
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
                                    decoration: InputDecoration(
                                      labelText: l.get('public_alias_optional'),
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
                                      : Text(requiresMfa
                                          ? l.get('verify_signin')
                                          : register
                                              ? l.get('create_account')
                                              : l.get('sign_in')),
                                ),
                              ),
                              if (helpiDemoMode && !register) ...[
                                const SizedBox(height: 10),
                                OutlinedButton.icon(
                                  onPressed: busy ? null : _enterPreview,
                                  icon: const Icon(Icons.play_arrow_rounded),
                                  label: Text(l.get('enter_preview')),
                                ),
                              ],
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: busy || requiresMfa
                                    ? null
                                    : () => setState(() {
                                          register = !register;
                                          requiresMfa = false;
                                          _formKey.currentState?.reset();
                                        }),
                                child: Text(register
                                    ? l.get('already_registered')
                                    : l.get('need_account')),
                              ),
                              if (_adminPortalUrl.isNotEmpty)
                                TextButton.icon(
                                  onPressed: busy ? null : _openAdminPortal,
                                  icon: const Icon(
                                      Icons.admin_panel_settings_outlined),
                                  label: const Text('Administrator portal'),
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
}
