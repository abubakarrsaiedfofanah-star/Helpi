import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/app_state.dart';
import 'core/localization.dart';
import 'core/theme.dart';
import 'features/auth/auth_screen.dart';
import 'screens/main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorWidget.builder = (details) => const Material(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
                'Helpi could not display this screen. Please go back and try again.',
                textAlign: TextAlign.center),
          ),
        ),
      );
  runApp(ChangeNotifierProvider(
      create: (_) => AppState()..restore(), child: const HelpiApp()));
}

class HelpiApp extends StatelessWidget {
  const HelpiApp({super.key});

  @override
  Widget build(BuildContext c) => Consumer<AppState>(
        builder: (_, s, __) {
          if (s.loading) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: helpiTheme,
              darkTheme: helpiDarkTheme,
              themeMode: s.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              locale: Locale(s.locale),
              supportedLocales: AppLocalizations.supportedLanguages.keys
                  .map(Locale.new)
                  .toList(),
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              home: const Scaffold(
                  body:
                      Center(child: CircularProgressIndicator(color: orange))),
            );
          }
          return MaterialApp(
            title: 'Helpi',
            debugShowCheckedModeBanner: false,
            theme: helpiTheme,
            darkTheme: helpiDarkTheme,
            themeMode: s.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            locale: Locale(s.locale),
            supportedLocales: AppLocalizations.supportedLanguages.keys
                .map(Locale.new)
                .toList(),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            home: s.authenticated ? const MainShell() : const AuthScreen(),
          );
        },
      );
}
