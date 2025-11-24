import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/theme_bloc.dart';
import '../bloc/theme_state.dart';
import '../bloc/theme_event.dart';

class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final isDark = state.isDarkMode;

        return PopupMenuButton<bool>(
          icon: Icon(
            isDark ? Icons.dark_mode : Icons.light_mode,
            color: isDark ? Colors.white : null,
          ),
          tooltip: 'Change theme',
          onSelected: (bool darkMode) {
            context.read<ThemeBloc>().add(SetTheme(darkMode));
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<bool>(
              value: false,
              child: Row(
                children: [
                  const Icon(Icons.light_mode),
                  const SizedBox(width: 12),
                  const Text('Light'),
                  const Spacer(),
                  if (!isDark) const Icon(Icons.check, color: Colors.blue),
                ],
              ),
            ),
            PopupMenuItem<bool>(
              value: true,
              child: Row(
                children: [
                  const Icon(Icons.dark_mode),
                  const SizedBox(width: 12),
                  const Text('Dark'),
                  const Spacer(),
                  if (isDark) const Icon(Icons.check, color: Colors.blue),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
