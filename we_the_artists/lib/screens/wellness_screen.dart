import 'package:flutter/material.dart';

class WellnessResource {
  final String title;
  final String description;

  const WellnessResource({required this.title, required this.description});
}

class WellnessScreen extends StatelessWidget {
  WellnessScreen({super.key});

  final List<WellnessResource> wellnessResources = const [
    WellnessResource(
      title: '5 Minute Gronding Exercises',
      description: 'Quick techniques to center yourself and reduce anxiety',
    ),
    WellnessResource(
      title: 'How to Handle Critique without losing Confidence',
      description:
          'Strategies for receiving feedback while maintaining self-esteem',
    ),
    WellnessResource(
      title: 'Local Councelling and peer groups',
      description: 'Find professional support and community resources near you',
    ),
  ];

  final Map<String, List<WellnessResource>> expandedResources = {
    '5 Minute Gronding Exercises': [
      const WellnessResource(
        title: 'Box Breathing',
        description: '4-second inhale, 4-second hold, 4-second exhale',
      ),
      const WellnessResource(
        title: '5-4-3-2-1 Sensory',
        description:
            'Name 5 things you see, 4 you feel, 3 you hear, 2 you smell, 1 you taste',
      ),
      const WellnessResource(
        title: 'Body Scan',
        description:
            'Progressively relax each part of your body from head to toe',
      ),
    ],
    'How to Handle Critique without losing Confidence': [
      const WellnessResource(
        title: 'Separate Work from Self',
        description: 'Your work is not your worth as a person',
      ),
      const WellnessResource(
        title: 'The Feedback Filter',
        description: 'Learn to identify constructive vs. destructive criticism',
      ),
      const WellnessResource(
        title: 'Growth Mindset Practice',
        description: 'View feedback as opportunities for improvement',
      ),
    ],
    'Local Councelling and peer groups': [
      const WellnessResource(
        title: 'Artist Support Groups',
        description: 'Weekly meetings for creative professionals',
      ),
      const WellnessResource(
        title: 'Therapist Directory',
        description:
            'Mental health professionals specializing in creative fields',
      ),
      const WellnessResource(
        title: 'Crisis Resources',
        description: '24/7 support for immediate mental health needs',
      ),
    ],
  };

  void _navigateToResourceDetail(
    BuildContext context,
    WellnessResource resource,
  ) {
    final expandedItems = expandedResources[resource.title] ?? [];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResourceDetailScreen(
          mainResource: resource,
          expandedResources: expandedItems,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: wellnessResources.map((resource) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 1,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              title: Text(
                resource.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _navigateToResourceDetail(context, resource),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Detail screen for wellness resources
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
      appBar: AppBar(title: Text(mainResource.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            if (expandedResources.isNotEmpty) ...[
              const Text(
                'Related Exercises & Resources',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...expandedResources.map(
                (resource) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      resource.title,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(resource.description),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => print('Starting: ${resource.title}'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
