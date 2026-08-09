import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'screens/screens.dart';

void main() {
  runApp(const OpenWrtSetupApp());
}

class OpenWrtSetupApp extends StatefulWidget {
  const OpenWrtSetupApp({super.key});

  @override
  State<OpenWrtSetupApp> createState() => _OpenWrtSetupAppState();
}

class _OpenWrtSetupAppState extends State<OpenWrtSetupApp> {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _changeLanguage(Locale locale) {
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenWrt Setup',
      debugShowCheckedModeBanner: false,
      
      // Localization
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      locale: _locale,
      
      // Theme
      themeMode: _themeMode,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      
      // Home screen
      home: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context).appTitle),
            actions: [
              IconButton(
                icon: Icon(_themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
                onPressed: _toggleTheme,
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'en') _changeLanguage(const Locale('en'));
                  else if (value == 'ar') _changeLanguage(const Locale('ar'));
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'en', child: Text('English')),
                  const PopupMenuItem(value: 'ar', child: Text('العربية')),
                ],
              ),
            ],
          ),
          body: const HomeScreen(),
        ),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
    );
  }
}
