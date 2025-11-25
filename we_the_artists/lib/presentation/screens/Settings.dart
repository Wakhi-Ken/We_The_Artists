import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'en'; // Default language

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
  }

  // Load the language preference from SharedPreferences
  _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage =
          prefs.getString('language') ?? 'en'; // Default to 'en'
    });
  }

  // Save the selected language to SharedPreferences
  _saveLanguagePreference(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    setState(() {
      _selectedLanguage = language;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // You can navigate to settings screen
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: theme.cardColor,
            child: ListTile(
              title: const Text("Language"),
              subtitle: Text(
                _selectedLanguage == 'en' ? 'English' : 'Other Language',
                style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              ),
              onTap: () async {
                // Toggle between English and another language
                String newLanguage = _selectedLanguage == 'en' ? 'es' : 'en';
                _saveLanguagePreference(newLanguage);

                // Optionally update your app language here
                // For example, using the `Locale` class with your `MaterialApp` settings
              },
            ),
          ),
          const Divider(),
          Container(
            color: theme.cardColor,
            child: ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              onTap: () {
                // Navigate to Notifications Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                );
              },
            ),
          ),
          Container(
            color: theme.cardColor,
            child: ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                // Perform logout action (like FirebaseAuth sign out)
                // Add your logout logic here

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/signup', // Adjust the route as needed
                  (route) => false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: const Center(child: Text('Here are your notifications!')),
    );
  }
}
