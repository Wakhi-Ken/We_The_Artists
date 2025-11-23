import 'package:flutter/material.dart';

class WellnessResource {
  final String title;
  final String description;

  const WellnessResource({
    required this.title,
    required this.description,
  });
}

class WellnessScreen extends StatefulWidget {
  const WellnessScreen({super.key});

  @override
  State<WellnessScreen> createState() => _WellnessScreenState();
}

class _WellnessScreenState extends State<WellnessScreen> {
  // Sample wellness resources matching the reference image exactly
  final List<WellnessResource> wellnessResources = const [
    WellnessResource(
      title: '5 Minute Gronding Exercises',
      description: 'Quick techniques to center yourself and reduce anxiety',
    ),
    WellnessResource(
      title: 'How to Handle Critique without losing Confidence',
      description: 'Strategies for receiving feedback while maintaining self-esteem',
    ),
    WellnessResource(
      title: 'Local Councelling and peer groups',
      description: 'Find professional support and community resources near you',
    ),
  ];

  // Additional mental health features (hidden behind the main items)
  final Map<String, List<WellnessResource>> _expandedResources = {
    '5 Minute Gronding Exercises': const [
      WellnessResource(title: 'Box Breathing', description: '4-second inhale, 4-second hold, 4-second exhale'),
      WellnessResource(title: '5-4-3-2-1 Sensory', description: 'Name 5 things you see, 4 you feel, 3 you hear, 2 you smell, 1 you taste'),
      WellnessResource(title: 'Body Scan', description: 'Progressively relax each part of your body from head to toe'),
    ],
    'How to Handle Critique without losing Confidence': const [
      WellnessResource(title: 'Separate Work from Self', description: 'Your work is not your worth as a person'),
      WellnessResource(title: 'The Feedback Filter', description: 'Learn to identify constructive vs. destructive criticism'),
      WellnessResource(title: 'Growth Mindset Practice', description: 'View feedback as opportunities for improvement'),
    ],
    'Local Councelling and peer groups': const [
      WellnessResource(title: 'Artist Support Groups', description: 'Weekly meetings for creative professionals'),
      WellnessResource(title: 'Therapist Directory', description: 'Mental health professionals specializing in creative fields'),
      WellnessResource(title: 'Crisis Resources', description: '24/7 support for immediate mental health needs'),
    ],
  };

  void _navigateToResourceDetail(WellnessResource resource) {
    final expandedItems = _expandedResources[resource.title] ?? [];
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResourceDetailScreen(
          mainResource: resource,
          expandedResources: expandedItems,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wellness'),
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
            // Music Production Sections (repeated as in the reference)
            _buildCategoryCard(
              title: 'Music Production',
              description: 'Everything from EDM, Pop, Afrobeats and Rap',
            ),
            const SizedBox(height: 16),
            _buildCategoryCard(
              title: 'Music Production',
              description: 'Everything from EDM, Pop, Afrobeats and Rap',
            ),
            const SizedBox(height: 24),
            
            // Resources Section
            const Text(
              'Resources',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Wellness Corner Subsection - Exactly like reference
            const Text(
              'Wellness Corner',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            // Wellness Resources List - No descriptions as per reference
            Column(
              children: wellnessResources.map((resource) {
                return _buildWellnessResourceItem(resource);
              }).toList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Quick mental health check-in
          _showQuickCheckIn();
        },
        child: const Icon(Icons.self_improvement),
      ),
    );
  }

  Widget _buildCategoryCard({required String title, required String description}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWellnessResourceItem(WellnessResource resource) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(
          resource.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        // No subtitle/description as per reference image
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _navigateToResourceDetail(resource),
      ),
    );
  }

  void _showQuickCheckIn() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Check-in'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('How are you feeling right now?'),
            SizedBox(height: 16),
            // Simple mood check could be added here
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to full mental health assessment
            },
            child: const Text('Check In'),
          ),
        ],
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

class ResourceDetailScreen extends StatelessWidget {
  final WellnessResource mainResource;
  final List<WellnessResource> expandedResources;

  const ResourceDetailScreen({
    super.key,
    required this.mainResource,
    required this.expandedResources,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(mainResource.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main resource description
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mainResource.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(mainResource.description),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Expanded resources
            if (expandedResources.isNotEmpty) ...[
              const Text(
                'Related Exercises & Resources',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...expandedResources.map((resource) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      resource.title,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(resource.description),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Start the specific exercise
                      print('Starting: ${resource.title}');
                    },
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}