// ignore_for_file: file_names, library_private_types_in_public_api, strict_top_level_inference

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
      _selectedLanguage = prefs.getString('language') ?? 'en';
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
              onTap: () {
                // Toggle between English and another language
                String newLanguage = _selectedLanguage == 'en' ? 'es' : 'en';
                _saveLanguagePreference(newLanguage);
              },
            ),
          ),
          const Divider(),
          Container(
            color: theme.cardColor,
            child: ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                // Perform logout action (like FirebaseAuth sign out)

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/signup',
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
