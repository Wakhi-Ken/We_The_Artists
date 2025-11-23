import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/bloc/post_bloc.dart';
import 'presentation/bloc/user_bloc.dart';
import 'presentation/bloc/user_event.dart';
import 'presentation/bloc/comment_bloc.dart';
import 'presentation/bloc/theme_bloc.dart';
import 'presentation/bloc/theme_event.dart';
import 'presentation/bloc/theme_state.dart';
import 'presentation/bloc/notification_bloc.dart';
import 'presentation/screens/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => PostBloc()),
        BlocProvider(
          create: (context) => UserBloc()..add(const LoadUserProfile()),
        ),
        BlocProvider(create: (context) => CommentBloc()),
        BlocProvider(
          create: (context) => ThemeBloc()..add(const LoadTheme()),
        ),
        BlocProvider(create: (context) => NotificationBloc()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'Artist Account',
            debugShowCheckedModeBanner: false,
            themeMode: themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              scaffoldBackgroundColor: Colors.grey[100],
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                iconTheme: IconThemeData(color: Colors.black),
              ),
              cardColor: Colors.white,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFF121212),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1E1E1E),
                iconTheme: IconThemeData(color: Colors.white),
              ),
              cardColor: const Color(0xFF1E1E1E),
            ),
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}
