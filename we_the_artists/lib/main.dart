import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'package:we_the_artists/presentation/screens/home_feed_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'screens/community_screen.dart';
import 'screens/event_screen.dart';
import 'screens/wellness_screen.dart';
import 'package:we_the_artists/presentation/screens/my_account_screen.dart';
import 'screens/auth/log_in_screen.dart';
import 'package:we_the_artists/presentation/screens/create_post_screen_v2.dart';
import 'package:we_the_artists/presentation/bloc/post_bloc.dart';
import 'package:we_the_artists/presentation/bloc/notification_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    const ProviderScope(
      // <-- Wrap everything here
      child: WeTheArtistsApp(),
    ),
  );
}

class WeTheArtistsApp extends StatelessWidget {
  const WeTheArtistsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PostBloc>(create: (context) => PostBloc()),
        BlocProvider<NotificationBloc>(create: (context) => NotificationBloc()),
      ],
      child: MaterialApp(
        title: 'We The Artists',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
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
      ),
    );
  }
}
