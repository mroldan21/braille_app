// lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/ble_provider.dart';
import '../presentation/providers/braille_provider.dart';
import '../presentation/providers/settings_provider.dart';
import '../presentation/widgets/welcome/welcome_screen.dart';
import '../presentation/widgets/home/home_screen.dart';
import '../presentation/themes/app_theme.dart';

class BrailleApp extends StatelessWidget {
  const BrailleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => BLEProvider()),
        ChangeNotifierProvider(create: (_) => BrailleProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: 'Braille App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsProvider.settings.themeMode,
            routes: {
              '/': (context) => const WelcomeScreen(),
              '/home': (context) => const HomeScreen(),
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}