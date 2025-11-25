import 'package:flutter/material.dart';
import 'event_screen.dart';

class CommunityCategory {
  final String title;
  final String description;
  final String id;

  const CommunityCategory({
    required this.title,
    required this.description,
    required this.id,
  });
}

class Workshop {
  final String title;
  final String presenter;
  final String date;
  final String description;
  final String communityId;

  const Workshop({
    required this.title,
    required this.presenter,
    required this.date,
    required this.description,
    required this.communityId,
  });
}

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  final List<CommunityCategory> categories = const [
    CommunityCategory(
      title: 'Visual Arts',
      description: 'Painting, Photography, Videography and the likes',
      id: 'visual_arts',
    ),
    CommunityCategory(
      title: 'Music Production',
      description: 'Everything from EDM, Pop, Afrobeats and Rap',
      id: 'music_production',
    ),
    CommunityCategory(
      title: 'Graphic Design',
      description: 'Adobe Suite, Canvas, Figma Power Users',
      id: 'graphic_design',
    ),
  ];

  final List<Workshop> workshops = const [
    Workshop(
      title: 'Branding For Artists',
      presenter: 'By Indiba Series',
      date: 'October 20, 2025',
      description:
          'Learn how to present yourself best in the music industry, and the best practices when displaying yourself to the world',
      communityId: 'music_production',
    ),
    Workshop(
      title: 'Digital Tools for Painters',
      presenter: 'By Indiba Series',
      date: 'October 28, 2025',
      description:
          'Use Tech to your advantage! Get to learn the various tools you can use to step up your game in painting.',
      communityId: 'visual_arts',
    ),
  ];

  void _navigateToCategoryEvents(
    BuildContext context,
    CommunityCategory category,
  ) {
    final categoryWorkshops = workshops
        .where((w) => w.communityId == category.id)
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryEventsScreen(
          category: category,
          workshops: categoryWorkshops,
        ),
      ),
    );
  }

  void _navigateToEventDetail(BuildContext context, Workshop workshop) {
    final event = Event(
      title: workshop.title,
      presenter: workshop.presenter.replaceFirst('By ', ''),
      location: 'Norrsken, Kigali',
      date: DateTime(2025, 10, 20),
      time: '12:00 pm',
      description: workshop.description,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EventDetailPage(event: event)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories
          ...categories.map((category) {
            return Column(
              children: [
                InkWell(
                  onTap: () => _navigateToCategoryEvents(context, category),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category.description,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (categories.indexOf(category) != categories.length - 1)
                  const Divider(height: 32),
              ],
            );
          }),

          const SizedBox(height: 32),
          const Text(
            'Workshops',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Column(
            children: workshops
                .map(
                  (w) => Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    child: InkWell(
                      onTap: () => _navigateToEventDetail(context, w),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              w.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${w.presenter} • ${w.date}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'View More',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    w.description,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

/// Screen for category events
class CategoryEventsScreen extends StatelessWidget {
  final CommunityCategory category;
  final List<Workshop> workshops;

  const CategoryEventsScreen({
    super.key,
    required this.category,
    required this.workshops,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category.title)),
      body: workshops.isEmpty
          ? const Center(child: Text('No events scheduled yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: workshops.length,
              itemBuilder: (context, index) {
                final workshop = workshops[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      workshop.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(workshop.presenter),
                        const SizedBox(height: 4),
                        Text(
                          workshop.date,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      final event = Event(
                        title: workshop.title,
                        presenter: workshop.presenter.replaceFirst('By ', ''),
                        location: 'Norrsken, Kigali',
                        date: DateTime(2025, 10, 20),
                        time: '12:00 pm',
                        description: workshop.description,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventDetailPage(event: event),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
