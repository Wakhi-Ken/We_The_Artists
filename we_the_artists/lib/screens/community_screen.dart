import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'event_screen.dart';

class CommunityCategory {
  final String title;
  final String description;
  final String id;
  final List<String> followerUids;
  final String creatorId;
  final Timestamp createdAt;

  const CommunityCategory({
    required this.title,
    required this.description,
    required this.id,
    required this.followerUids,
    required this.creatorId,
    required this.createdAt,
  });

  factory CommunityCategory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return CommunityCategory(
      id: doc.id,
      title: data?['name'] as String? ?? 'Unnamed Community',
      description: data?['details'] as String? ?? 'No description available.',
      followerUids: List<String>.from(data?['followerUids'] ?? []),
      creatorId: data?['creatorId'] as String? ?? '',
      createdAt: data?['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': title,
      'details': description,
      'followerUids': followerUids,
      'creatorId': creatorId,
      'createdAt': createdAt,
    };
  }
}

class Workshop {
  final String title;
  final String presenter;
  final String date;
  final String description;
  final String communityId;
  final String? id;
  final String creatorId;
  final Timestamp createdAt;
  final String location;
  final String time;

  const Workshop({
    required this.title,
    required this.presenter,
    required this.date,
    required this.description,
    required this.communityId,
    this.id,
    required this.creatorId,
    required this.createdAt,
    required this.location,
    required this.time,
  });

  factory Workshop.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return Workshop(
      id: doc.id,
      title: data?['title'] as String? ?? 'Untitled Workshop',
      presenter: data?['presenter'] as String? ?? 'Unknown Presenter',
      date: data?['date'] as String? ?? 'Date TBD',
      description: data?['description'] as String? ?? 'No description available.',
      communityId: data?['communityId'] as String? ?? '',
      creatorId: data?['creatorId'] as String? ?? '',
      createdAt: data?['createdAt'] as Timestamp? ?? Timestamp.now(),
      location: data?['location'] as String? ?? 'Location TBD',
      time: data?['time'] as String? ?? 'Time TBD',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'presenter': presenter,
      'date': date,
      'description': description,
      'communityId': communityId,
      'creatorId': creatorId,
      'createdAt': createdAt,
      'location': location,
      'time': time,
    };
  }
}

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  void _navigateToCategoryEvents(
    BuildContext context,
    CommunityCategory category,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryEventsScreen(category: category),
      ),
    );
  }

  void _navigateToEventDetail(BuildContext context, Workshop workshop) {
    DateTime eventDate;
    try {
      eventDate = DateTime.parse(workshop.date);
    } catch (e) {
      eventDate = DateTime(2025, 10, 20);
    }

    final event = Event(
      title: workshop.title,
      presenter: workshop.presenter.replaceFirst('By ', ''),
      location: workshop.location,
      date: eventDate,
      time: workshop.time,
      description: workshop.description,
      eventId: workshop.id,
      communityId: workshop.communityId,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EventDetailPage(event: event)),
    );
  }

  Future<void> _toggleFollowCommunity(CommunityCategory category, String userId) async {
    final docRef = FirebaseFirestore.instance.collection('Community').doc(category.id);
    
    if (category.followerUids.contains(userId)) {
      await docRef.update({
        'followerUids': FieldValue.arrayRemove([userId])
      });
    } else {
      await docRef.update({
        'followerUids': FieldValue.arrayUnion([userId])
      });
    }
  }

  void _showCreateCommunityDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Community'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Community Name',
                  hintText: 'e.g., Digital Artists Collective',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe what your community is about...',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isNotEmpty && 
                    descriptionController.text.trim().isNotEmpty) {
                  await _createCommunity(
                    nameController.text.trim(),
                    descriptionController.text.trim(),
                    'user123', // Replace with actual user ID
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createCommunity(String name, String description, String userId) async {
    try {
      await FirebaseFirestore.instance.collection('Community').add({
        'name': name,
        'details': description,
        'followerUids': [userId],
        'creatorId': userId,
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error creating community: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = 'user123';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Communities'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateCommunityDialog(context),
            tooltip: 'Create Community',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Art Communities',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Join communities to connect with artists in your field',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // Communities from Firestore
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Community').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading communities: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final List<CommunityCategory> firestoreCategories = snapshot.data!.docs
                    .map((doc) => CommunityCategory.fromFirestore(doc))
                    .toList();

                firestoreCategories.sort((a, b) => a.title.compareTo(b.title));

                if (firestoreCategories.isEmpty) {
                  return Column(
                    children: [
                      const Icon(
                        Icons.group,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No communities yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Be the first to create a community!',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _showCreateCommunityDialog(context),
                        child: const Text('Create First Community'),
                      ),
                    ],
                  );
                }

                return Column(
                  children: firestoreCategories.map((category) {
                    final isFollowing = category.followerUids.contains(currentUserId);
                    final isCreator = category.creatorId == currentUserId;
                    
                    return Column(
                      children: [
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                category.title,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (isCreator) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: const Text(
                                                    'Creator',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.blue,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
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
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        isFollowing ? Icons.favorite : Icons.favorite_border,
                                        color: isFollowing ? Colors.red : Colors.grey,
                                        size: 28,
                                      ),
                                      onPressed: () => _toggleFollowCommunity(category, currentUserId),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Text(
                                      '${category.followerUids.length} followers',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Spacer(),
                                    ElevatedButton(
                                      onPressed: () => _navigateToCategoryEvents(context, category),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context).primaryColor,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                      child: const Text('View Events'),
                                    ),
                                    if (isCreator) ...[
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline),
                                        onPressed: () => _showCreateEventDialog(context, category),
                                        tooltip: 'Add Event',
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (firestoreCategories.indexOf(category) != firestoreCategories.length - 1)
                          const SizedBox(height: 16),
                      ],
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 32),
            
            // Upcoming Workshops
            const Text(
              'Upcoming Workshops',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Join workshops to learn and grow with fellow artists',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('workshops')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading workshops: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<Workshop> firestoreWorkshops = snapshot.data!.docs
                    .map((doc) => Workshop.fromFirestore(doc))
                    .toList();

                firestoreWorkshops.sort((a, b) => a.date.compareTo(b.date));

                if (firestoreWorkshops.isEmpty) {
                  return Column(
                    children: [
                      const Icon(
                        Icons.event,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No workshops yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Create the first workshop in a community!',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  );
                }

                return Column(
                  children: firestoreWorkshops.map((workshop) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () => _navigateToEventDetail(context, workshop),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 4,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          workshop.title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${workshop.presenter} • ${workshop.date}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              size: 12,
                                              color: Colors.grey[500],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              workshop.location,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Icon(
                                              Icons.access_time,
                                              size: 12,
                                              color: Colors.grey[500],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              workshop.time,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                workshop.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'Tap to view details →',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateEventDialog(BuildContext context, CommunityCategory category) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController presenterController = TextEditingController();
    final TextEditingController dateController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Event in ${category.title}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Event Title *',
                    hintText: 'e.g., Digital Painting Workshop',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: presenterController,
                  decoration: const InputDecoration(
                    labelText: 'Presenter *',
                    hintText: 'e.g., By Jane Smith',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'Date *',
                    hintText: 'e.g., December 15, 2024',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location *',
                    hintText: 'e.g., Norrsken House, Kigali',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(
                    labelText: 'Time *',
                    hintText: 'e.g., 14:30 (2:30 PM)',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description *',
                    hintText: 'Describe your event...',
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 8),
                const Text(
                  '* Required fields',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isNotEmpty && 
                    presenterController.text.trim().isNotEmpty &&
                    dateController.text.trim().isNotEmpty &&
                    locationController.text.trim().isNotEmpty &&
                    timeController.text.trim().isNotEmpty &&
                    descriptionController.text.trim().isNotEmpty) {
                  await _createEvent(
                    titleController.text.trim(),
                    presenterController.text.trim(),
                    dateController.text.trim(),
                    descriptionController.text.trim(),
                    category.id,
                    'user123', // Replace with actual user ID
                    locationController.text.trim(),
                    timeController.text.trim(),
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Create Event'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createEvent(
    String title, 
    String presenter, 
    String date, 
    String description, 
    String communityId,
    String userId,
    String location,
    String time,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('workshops').add({
        'title': title,
        'presenter': presenter,
        'date': date,
        'description': description,
        'communityId': communityId,
        'creatorId': userId,
        'createdAt': Timestamp.now(),
        'location': location,
        'time': time,
      });
    } catch (e) {
      print('Error creating event: $e');
    }
  }
}

class CategoryEventsScreen extends StatelessWidget {
  final CommunityCategory category;

  const CategoryEventsScreen({
    super.key,
    required this.category,
  });

  void _navigateToEventDetail(BuildContext context, Workshop workshop) {
    DateTime eventDate;
    try {
      eventDate = DateTime.parse(workshop.date);
    } catch (e) {
      eventDate = DateTime(2025, 10, 20);
    }

    final event = Event(
      title: workshop.title,
      presenter: workshop.presenter.replaceFirst('By ', ''),
      location: workshop.location,
      date: eventDate,
      time: workshop.time,
      description: workshop.description,
      eventId: workshop.id,
      communityId: workshop.communityId,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EventDetailPage(event: event)),
    );
  }

  void _showCreateEventDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController presenterController = TextEditingController();
    final TextEditingController dateController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Event in ${category.title}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Event Title *',
                    hintText: 'e.g., Digital Painting Workshop',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: presenterController,
                  decoration: const InputDecoration(
                    labelText: 'Presenter *',
                    hintText: 'e.g., By Jane Smith',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'Date *',
                    hintText: 'e.g., December 15, 2024',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location *',
                    hintText: 'e.g., Norrsken House, Kigali',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(
                    labelText: 'Time *',
                    hintText: 'e.g., 14:30 (2:30 PM)',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description *',
                    hintText: 'Describe your event...',
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 8),
                const Text(
                  '* Required fields',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isNotEmpty && 
                    presenterController.text.trim().isNotEmpty &&
                    dateController.text.trim().isNotEmpty &&
                    locationController.text.trim().isNotEmpty &&
                    timeController.text.trim().isNotEmpty &&
                    descriptionController.text.trim().isNotEmpty) {
                  await _createEvent(
                    titleController.text.trim(),
                    presenterController.text.trim(),
                    dateController.text.trim(),
                    descriptionController.text.trim(),
                    category.id,
                    'user123', // Replace with actual user ID
                    locationController.text.trim(),
                    timeController.text.trim(),
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Create Event'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createEvent(
    String title, 
    String presenter, 
    String date, 
    String description, 
    String communityId,
    String userId,
    String location,
    String time,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('workshops').add({
        'title': title,
        'presenter': presenter,
        'date': date,
        'description': description,
        'communityId': communityId,
        'creatorId': userId,
        'createdAt': Timestamp.now(),
        'location': location,
        'time': time,
      });
    } catch (e) {
      print('Error creating event: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = 'user123'; // Replace with actual user ID
    final bool isCreator = category.creatorId == currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: Text('${category.title} Events'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (isCreator)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showCreateEventDialog(context),
              tooltip: 'Create Event',
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('workshops')
            .where('communityId', isEqualTo: category.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading events: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Workshop> categoryWorkshops = snapshot.data!.docs
              .map((doc) => Workshop.fromFirestore(doc))
              .toList();

          categoryWorkshops.sort((a, b) => a.date.compareTo(b.date));

          if (categoryWorkshops.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No events scheduled yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isCreator 
                      ? 'Create the first event for your community!'
                      : 'Check back later for upcoming workshops',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  if (isCreator) ...[
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _showCreateEventDialog(context),
                      child: const Text('Create First Event'),
                    ),
                  ],
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categoryWorkshops.length,
            itemBuilder: (context, index) {
              final workshop = categoryWorkshops[index];
              final isEventCreator = workshop.creatorId == currentUserId;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      Icons.event,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          workshop.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (isEventCreator)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Your Event',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        workshop.presenter,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        workshop.date,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            workshop.location,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            workshop.time,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _navigateToEventDetail(context, workshop),
                ),
              );
            },
          );
        },
      ),
    );
  }
}