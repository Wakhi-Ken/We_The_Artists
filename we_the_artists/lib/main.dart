import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';

// Screens
import 'package:we_the_artists/presentation/screens/home_feed_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'screens/auth/log_in_screen.dart';
import 'package:we_the_artists/presentation/screens/create_post_screen_v2.dart';
import 'package:we_the_artists/presentation/screens/my_account_screen.dart';
import 'package:we_the_artists/presentation/screens/Settings.dart';
import 'screens/community_screen.dart';
import 'screens/event_screen.dart';
import 'screens/wellness_screen.dart';

// Blocs
import 'package:we_the_artists/presentation/bloc/post_bloc.dart';
import 'package:we_the_artists/presentation/bloc/notification_bloc.dart';
import 'package:we_the_artists/presentation/bloc/theme_bloc.dart';
import 'package:we_the_artists/presentation/bloc/theme_state.dart';
import 'package:we_the_artists/presentation/bloc/theme_event.dart';
import 'package:we_the_artists/presentation/bloc/user_bloc.dart'; // <-- added

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebase();

  runApp(const ProviderScope(child: WeTheArtistsApp()));
}

Future<void> _initializeFirebase() async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print("✅ Firebase initialized successfully");
    } else {
      print("✅ Firebase already initialized");
    }
  } catch (e) {
    print("❌ Firebase initialization failed: $e");
  }
}

class WeTheArtistsApp extends StatelessWidget {
  const WeTheArtistsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PostBloc>(create: (_) => PostBloc()),
        BlocProvider<NotificationBloc>(create: (_) => NotificationBloc()),
        BlocProvider<ThemeBloc>(create: (_) => ThemeBloc()..add(LoadTheme())),
        BlocProvider<UserBloc>(create: (_) => UserBloc()), // <-- added
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'We The Artists',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              brightness: themeState.isDarkMode
                  ? Brightness.dark
                  : Brightness.light,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              useMaterial3: true,
            ),
            initialRoute: '/signup',
            routes: {
              '/signup': (_) => const SignUpScreen(),
              '/login': (_) => const LoginScreen(),
              '/home': (_) => const HomeFeedScreen(),
              '/create_post': (_) => const CreatePostScreen(),
              '/my_account': (_) => const MyAccountScreen(),
              '/settings': (_) => SettingsScreen(),
              '/community': (_) => const CommunityScreen(),
              '/wellness': (_) => WellnessScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/event') {
                final event = settings.arguments as Event;
                return MaterialPageRoute(
                  builder: (_) => EventDetailPage(event: event),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
