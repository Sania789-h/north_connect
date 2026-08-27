import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';
import 'services/settings_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Future.wait([
    Supabase.initialize(
      url: 'https://orscgozycprnnhphltvr.supabase.co',
      publishableKey:
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9yc2Nnb3p5Y3Bybm5ocGhsdHZyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA0NjQ4ODksImV4cCI6MjA5NjA0MDg4OX0.Y233GfgNCWY_zoZydjTgkiyVAowwMaomu64H5VzPHzY',
    ),
    SettingsNotifier.instance.load(),
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: SettingsNotifier.instance,
      builder: (context, _) {
        final dark = SettingsNotifier.instance.darkMode;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'North Connect',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: dark ? ThemeMode.dark : ThemeMode.light,
          home: const SplashScreen(),
        );
      },
    );
  }
}