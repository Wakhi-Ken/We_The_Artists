import 'package:flutter/material.dart';
import '../utils/avatar_gradients.dart';
import '../widgets/animated_gradient_avatar.dart';

class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key});

  List<Map<String, String>> _getRecommendedArtists() {
    return [
      {
        'id': '6',
        'name': 'Lisa Anderson',
        'role': 'Abstract Artist',
        'location': 'Lagos',
      },
      {
        'id': '7',
        'name': 'James Mwangi',
        'role': 'Street Artist',
        'location': 'Nairobi',
      },
      {
        'id': '8',
        'name': 'Amara Okafor',
        'role': 'Digital Illustrator',
        'location': 'Accra',
      },
      {
        'id': '9',
        'name': 'Sophie Laurent',
        'role': 'Watercolor Artist',
        'location': 'Kigali',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final artists = _getRecommendedArtists();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Recommended Artists',
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        itemCount: artists.length,
        itemBuilder: (context, index) {
          final artist = artists[index];
          final colors = AvatarGradients.getGradientForUser(
            artist['id']!,
          );

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                AnimatedGradientAvatar(
                  initials: artist['name']!
                      .split(' ')
                      .map((n) => n[0])
                      .take(2)
                      .join()
                      .toUpperCase(),
                  size: 60,
                  gradientColors: colors,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        artist['name']!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${artist['role']} · ${artist['location']}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Following ${artist['name']}'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                  ),
                  child: const Text('Follow'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
