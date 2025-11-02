import 'package:flutter/material.dart';
import 'event_detail_page.dart';
import 'models.dart';

class CommunityPage extends StatelessWidget {
  CommunityPage({super.key});

  final List<CommunitySection> communitySections = [
    CommunitySection(
      title: "Visual Arts",
      description: "Painting, Photography, Videography and the likes",
    ),
    CommunitySection(
      title: "Music Production",
      description: "Everything from EDM, Pop, Afrobeats and Rap",
    ),
    CommunitySection(
      title: "Graphic Design",
      description: "Branding, Illustration, UI Design and more",
    ),
  ];

  final List<Workshop> workshops = [
    Workshop(
      title: "Branding For Artists",
      presenter: "Indiba Series",
      date: DateTime(2025, 10, 20),
      description:
          "Learn how to present yourself best in the music industry...",
    ),
    Workshop(
      title: "Digital Tools for Painters",
      presenter: "Indiba Series",
      date: DateTime(2025, 10, 28),
      description: "Use Tech to your advantage! Get to learn...",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Community")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...communitySections.map((section) => InterestGroupCard(section: section)),
            const SizedBox(height: 24),
            const Text(
              "Workshops",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...workshops.map(
              (w) => WorkshopItem(
                workshop: w,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EventDetailPage(
                        event: Event(
                          title: w.title,
                          presenter: w.presenter,
                          location: "Norrsken, Kigali",
                          date: w.date,
                          time: "12:00 pm",
                          description: w.description,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InterestGroupCard extends StatelessWidget {
  final CommunitySection section;

  const InterestGroupCard({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(section.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(section.description,
            style: const TextStyle(fontSize: 14, color: Colors.black87)),
        const SizedBox(height: 12),
        const Divider(),
      ],
    );
  }
}

class WorkshopItem extends StatelessWidget {
  final Workshop workshop;
  final VoidCallback onTap;

  const WorkshopItem({
    super.key,
    required this.workshop,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(workshop.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text("By ${workshop.presenter}"),
        Text("${workshop.date.toLocal().toString().split(' ')[0]}"),
        const SizedBox(height: 6),
        TextButton(onPressed: onTap, child: const Text("View More")),
        const Divider(),
      ],
    );
  }
}
