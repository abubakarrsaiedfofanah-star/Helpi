import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api.dart';
import 'biometric_service.dart';

const bool helpiDemoMode = bool.fromEnvironment('HELPI_DEMO', defaultValue: false);

class AppState extends ChangeNotifier with WidgetsBindingObserver {
  final api = Api();
  final storage = const FlutterSecureStorage();
  bool loading = true;
  String? access;
  Map<String, dynamic>? user;
  DateTime? _pausedAt;

  AppState() {
    WidgetsBinding.instance.addObserver(this);
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
        BiometricService.authenticate(reason: 'Session locked due to inactivity. Authenticate to unlock.');
      }
      _pausedAt = null;
    }
  }

  bool get authenticated => access != null;
  bool get demoMode => helpiDemoMode;
  bool isDarkMode = false;
  String locale = 'en';

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  void setLocale(String l) {
    locale = l;
    notifyListeners();
  }

  List<Map<String, dynamic>> get demoCases => const [
        {
          'id': 'demo-medical-1',
          'title': 'School medical support',
          'description': 'A verified community school needs support for essential medical supplies for learners.',
          'category': 'MEDICAL',
          'countryCode': 'KE',
          'city': 'Nairobi',
          'currency': 'KES',
          'goalMinor': 180000,
          'raisedMinor': 112000,
        },
        {
          'id': 'demo-food-1',
          'title': 'Emergency food support',
          'description': 'A local community group is coordinating verified food assistance for families facing an immediate shortage.',
          'category': 'FOOD',
          'countryCode': 'KE',
          'city': 'Kajiado',
          'currency': 'KES',
          'goalMinor': 95000,
          'raisedMinor': 67000,
        },
        {
          'id': 'demo-education-1',
          'title': 'Learning materials for students',
          'description': 'Verified students need textbooks and learning materials to continue the school term.',
          'category': 'EDUCATION',
          'countryCode': 'KE',
          'city': 'Mombasa',
          'currency': 'KES',
          'goalMinor': 120000,
          'raisedMinor': 54000,
        },
      ];

  Future<void> restore() async {
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
  }) async {
    if (helpiDemoMode) {
      access = 'demo-access';
      user = {
        'id': 'demo-user',
        'name': name.isEmpty ? 'Helpi Demo User' : name,
        'email': email.isEmpty ? 'demo@helpi.local' : email,
        'countryCode': country,
        'publicAlias': (publicAlias == null || publicAlias.isEmpty) ? 'Demo Member' : publicAlias,
      };
      notifyListeners();
      return null;
    }
    try {
      final r = await api.register(name, email, password, country, anonymousPublic: anonymousPublic, publicAlias: publicAlias);
      if (r['accessToken'] != null) await _set(r);
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
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
