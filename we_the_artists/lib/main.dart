import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/community_screen.dart';
import 'screens/event_screen.dart';
import 'screens/wellness_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const WeTheArtistsApp());
}

class WeTheArtistsApp extends StatelessWidget {
  const WeTheArtistsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'We The Artists',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      initialRoute: '/wellness',
      routes: {
        '/onboarding': (_) => const OnboardingScreen(),
        '/home': (_) => const HomeScreen(),
        '/community': (_) => const CommunityScreen(),
        '/wellness': (_) => const WellnessScreen(),
        '/event': (_) =>  EventDetailPage(
              event: Event(
                title: 'Event Details',
                presenter: 'Presenter Name',
                location: 'Location',
                date: DateTime.now(),
                time: 'Time',
                description: 'Event description',
              ),
            ),
      },
      onGenerateRoute: (settings) {
        // Handle event routes with parameters
        if (settings.name == '/event') {
          final event = settings.arguments as Event;
          return MaterialPageRoute(
            builder: (_) => EventDetailPage(event: event),
          );
        }
        return null;
      },
    );
  }
}

