import 'package:flutter/material.dart';
import 'utils/app_routes.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';

void main() {
  runApp(const WeTheArtistsApp());
}

class WeTheArtistsApp extends StatelessWidget {
  const WeTheArtistsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'We The Artists',
      debugShowCheckedModeBanner: false,
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (_) => const OnboardingScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}
