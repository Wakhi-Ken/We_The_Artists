// ignore_for_file: deprecated_member_use, unnecessary_to_list_in_spreads, avoid_print

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
      title: '5 Minute Grounding Exercises',
      description: 'Quick techniques to center yourself and reduce anxiety',
    ),
    WellnessResource(
      title: 'How to Handle Critique without losing Confidence',
      description:
          'Strategies for receiving feedback while maintaining self-esteem',
    ),
    WellnessResource(
      title: 'Local Counseling and peer groups',
      description: 'Find professional support and community resources near you',
    ),
  ];

  final Map<String, List<WellnessResource>> expandedResources = {
    '5 Minute Grounding Exercises': [
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
    'Local Counseling and peer groups': [
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wellness Resources'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mental Health & Wellness',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Resources to support your mental health and creative journey',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ...wellnessResources.map((resource) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.health_and_safety,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    resource.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    resource.description,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _navigateToResourceDetail(context, resource),
                ),
              );
            }).toList(),
          ],
        ),
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

  void _startExercise(String title) {
    print('Starting exercise: $title');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(mainResource.title),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: const Icon(
                            Icons.health_and_safety,
                            color: Colors.green,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mainResource.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                mainResource.description,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (expandedResources.isNotEmpty) ...[
              const Text(
                'Related Exercises & Resources',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap on any exercise to get started',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ...expandedResources.map(
                (resource) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      resource.title,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(resource.description),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _startExercise(resource.title),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Need Immediate Help?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'If you\'re experiencing a mental health crisis, please contact emergency services or a crisis helpline immediately.',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Crisis Helpline: 988',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
