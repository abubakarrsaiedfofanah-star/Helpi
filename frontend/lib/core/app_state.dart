import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api.dart';
import 'biometric_service.dart';
import 'localization.dart';

const bool helpiDemoMode =
    bool.fromEnvironment('HELPI_DEMO', defaultValue: false);

class AppState extends ChangeNotifier with WidgetsBindingObserver {
  final api = Api();
  final storage = const FlutterSecureStorage();
  bool loading = true;
  String? access;
  String? lastDevelopmentVerificationToken;
  Map<String, dynamic>? user;
  DateTime? _pausedAt;

  AppState() {
    WidgetsBinding.instance.addObserver(this);
    api.onUnauthorized = _refreshExpiredSession;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pausedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed && _pausedAt != null) {
      final diff = DateTime.now().difference(_pausedAt!);
      if (diff.inMinutes >= 2 && authenticated && !helpiDemoMode) {
        BiometricService.authenticate(
            reason:
                'Session locked due to inactivity. Authenticate to unlock.');
      }
      _pausedAt = null;
    }
  }

  bool get authenticated => access != null;
  bool get demoMode => helpiDemoMode;
  String get displayName {
    final current = user ?? const <String, dynamic>{};
    final mode = current['publicIdentityMode']?.toString();
    final alias = current['publicAlias']?.toString().trim() ?? '';
    if (mode == 'ANONYMOUS') return alias.isEmpty ? 'Anonymous' : alias;
    if (mode == 'ALIAS' && alias.isNotEmpty) return alias;
    final name = current['name']?.toString().trim() ?? '';
    return name.isEmpty ? 'Your account' : name;
  }

  Future<bool> _refreshExpiredSession() async {
    if (helpiDemoMode) return false;
    final refreshToken = await storage.read(key: 'refresh');
    if (refreshToken == null || refreshToken.isEmpty) return false;
    try {
      await _set(await api.refresh(refreshToken));
      return true;
    } catch (_) {
      await _clear();
      notifyListeners();
      return false;
    }
  }

  bool isDarkMode = false;
  String locale = 'en';

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  Future<void> setLocale(String l) async {
    if (!AppLocalizations.supportedLanguages.containsKey(l)) return;
    locale = l;
    unawaited(storage.write(key: 'preferred_locale', value: l));
    notifyListeners();
  }

  List<Map<String, dynamic>> get demoCases => const [
        {
          'id': 'demo-hardship-1',
          'title': 'Orphan support request',
          'description':
              'Seeking financial support. Contact directly to discuss details.',
          'category': 'ORPHAN',
          'countryCode': 'KE',
          'city': 'Nairobi',
          'currency': 'KES',
          'goalMinor': 180000,
        },
        {
          'id': 'demo-widow-1',
          'title': 'Widow support request',
          'description':
              'Seeking financial support. Contact directly to discuss details.',
          'category': 'WIDOW',
          'countryCode': 'KE',
          'city': 'Kajiado',
          'currency': 'KES',
          'goalMinor': 95000,
        },
        {
          'id': 'demo-jobless-1',
          'title': 'War survivor support request',
          'description':
              'Seeking financial support. Contact directly to discuss details.',
          'category': 'WAR_SURVIVOR',
          'countryCode': 'KE',
          'city': 'Mombasa',
          'currency': 'KES',
          'goalMinor': 120000,
        },
        {
          'id': 'demo-family-1',
          'title': 'Single-parent family support request',
          'description':
              'Seeking financial support. Contact directly to discuss details.',
          'category': 'SINGLE_PARENT',
          'countryCode': 'KE',
          'city': 'Kisumu',
          'currency': 'KES',
          'goalMinor': 85000,
        },
      ];

  Future<void> restore() async {
    final savedLocale = await storage.read(key: 'preferred_locale');
    if (AppLocalizations.supportedLanguages.containsKey(savedLocale)) {
      locale = savedLocale!;
    }
    if (helpiDemoMode) {
      access = 'demo-access';
      user = {
        'id': 'demo-user',
        'name': 'Helpi Demo User',
        'email': 'demo@helpi.local',
        'countryCode': 'KE',
        'publicAlias': 'Demo Member',
      };
      loading = false;
      notifyListeners();
      return;
    }

    access = await storage.read(key: 'access');
    if (access != null) {
      api.token = access;
      try {
        user = await api.me();
      } catch (_) {
        final refresh = await storage.read(key: 'refresh');
        if (refresh != null) {
          try {
            final r = await api.refresh(refresh);
            await _set(r);
          } catch (_) {
            await _clear();
          }
        } else {
          await _clear();
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  Future<String?> login(String email, String password, {String? mfa}) async {
    if (helpiDemoMode) {
      access = 'demo-access';
      user = {
        'id': 'demo-user',
        'name': 'Helpi Demo User',
        'email': email.isEmpty ? 'demo@helpi.local' : email,
        'countryCode': 'KE',
        'publicAlias': 'Demo Member',
      };
      notifyListeners();
      return null;
    }
    try {
      final r = await api.login(email, password, mfa: mfa);
      await _set(r);
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<String?> register(
    String name,
    String email,
    String password,
    String country, {
    bool anonymousPublic = false,
    String? publicAlias,
    String? supportGroup,
  }) async {
    lastDevelopmentVerificationToken = null;
    if (helpiDemoMode) {
      access = 'demo-access';
      user = {
        'id': 'demo-user',
        'name': name.isEmpty ? 'Helpi Demo User' : name,
        'email': email.isEmpty ? 'demo@helpi.local' : email,
        'countryCode': country,
        'supportGroup': supportGroup,
        'publicAlias': (publicAlias == null || publicAlias.isEmpty)
            ? 'Demo Member'
            : publicAlias,
        'publicIdentityMode': anonymousPublic
            ? 'ANONYMOUS'
            : (publicAlias != null && publicAlias.trim().isNotEmpty
                ? 'ALIAS'
                : 'REAL_NAME'),
      };
      notifyListeners();
      return null;
    }
    try {
      final r = await api.register(name, email, password, country,
          anonymousPublic: anonymousPublic,
          publicAlias: publicAlias,
          supportGroup: supportGroup);
      lastDevelopmentVerificationToken =
          r['verificationTokenForDevelopment']?.toString();
      if (r['accessToken'] != null) await _set(r);
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<String?> verifyEmail(String token) async {
    try {
      await api.verifyEmail(token);
      return null;
    } catch (error) {
      return error.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<void> _set(Map<String, dynamic> r) async {
    access = r['accessToken'];
    user = r['user'];
    api.token = access;
    await storage.write(key: 'access', value: r['accessToken']);
    await storage.write(key: 'refresh', value: r['refreshToken']);
    notifyListeners();
  }

  Future<void> _clear() async {
    access = null;
    user = null;
    api.token = null;
    await storage.delete(key: 'access');
    await storage.delete(key: 'refresh');
  }

  Future<void> logout() async {
    if (helpiDemoMode) {
      access = null;
      user = null;
      notifyListeners();
      return;
    }
    final refresh = await storage.read(key: 'refresh');
    try {
      if (refresh != null) await api.logout(refresh);
    } finally {
      await _clear();
      notifyListeners();
    }
  }
}
