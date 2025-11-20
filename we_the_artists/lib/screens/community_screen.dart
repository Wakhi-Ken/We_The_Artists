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

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
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
      description: 'Learn how to present yourself best in the music industry, and the best practices when displaying yourself to the world',
      communityId: 'music_production',
    ),
    Workshop(
      title: 'Digital Tools for Painters',
      presenter: 'By Indiba Series',
      date: 'October 28, 2025',
      description: 'Use Tech to your advantage! Get to learn the various tools you can use to step up your game in painting.',
      communityId: 'visual_arts',
    ),
  ];

  void _navigateToCategoryEvents(CommunityCategory category) {
    final categoryWorkshops = workshops.where((w) => w.communityId == category.id).toList();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryEventsScreen(
          category: category,
          workshops: categoryWorkshops,
        ),
      ),
    );
  }

  void _navigateToEventDetail(Workshop workshop) {
    final event = Event(
      title: workshop.title,
      presenter: workshop.presenter.replaceFirst('By ', ''),
      location: 'Norrsken, Kigali', // Default location
      date: DateTime(2025, 10, 20), // Default date
      time: '12:00 pm', // Default time
      description: workshop.description,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailPage(event: event),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: _buildDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Categories with dividers - Exactly like reference
            ...categories.map((category) {
              return Column(
                children: [
                  _buildCategoryItem(category),
                  if (categories.indexOf(category) != categories.length - 1)
                    const Divider(height: 32),
                ],
              );
            }),
            
            const SizedBox(height: 32),
            
            // Workshops Section - Exactly like reference
            const Text(
              'Workshops',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Workshops List - Exactly like reference format
            Column(
              children: workshops.map((workshop) {
                return _buildWorkshopItem(workshop);
              }).toList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new community or event
          print('Create new community/event');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryItem(CommunityCategory category) {
    return InkWell(
      onTap: () => _navigateToCategoryEvents(category),
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
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkshopItem(Workshop workshop) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToEventDetail(workshop),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Workshop Title
              Text(
                workshop.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Presenter and Date - Exactly like reference
              Text(
                '${workshop.presenter} • ${workshop.date}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              
              // View More section - Exactly like reference
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
                      workshop.description,
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
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircleAvatar(radius: 30, child: Text('AM')),
                SizedBox(height: 10),
                Text(
                  'Aline Mukarurangwa',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Visual Artist • Kigali',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('Chat'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.bookmark),
            title: const Text('Bookmarks'),
            onTap: () {},
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log Out'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

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
      appBar: AppBar(
        title: Text(category.title),
      ),
      body: workshops.isEmpty
          ? const Center(
              child: Text(
                'No events scheduled yet',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: workshops.length,
              itemBuilder: (context, index) {
                final workshop = workshops[index];
                return _buildWorkshopItem(context, workshop);
              },
            ),
    );
  }

  Widget _buildWorkshopItem(BuildContext context, Workshop workshop) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
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
              builder: (context) => EventDetailPage(event: event),
            ),
          );
        },
      ),
    );
  }
}