// ignore_for_file: unused_local_variable, unused_element, deprecated_member_use

import 'package:flutter/material.dart';

class Event {
  final String title;
  final String presenter;
  final String location;
  final DateTime date;
  final String time;
  final String description;
  final String? eventId;
  final String? communityId;

  const Event({
    required this.title,
    required this.presenter,
    required this.location,
    required this.date,
    required this.time,
    required this.description,
    this.eventId,
    this.communityId,
  });
}

class EventDetailPage extends StatefulWidget {
  final Event event;

  const EventDetailPage({super.key, required this.event});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  bool _isRSVPed = false;
  int _rsvpCount = 0;

  @override
  void initState() {
    super.initState();
    _checkRSVPStatus();
    _getRSVPCount();
  }

  Future<void> _checkRSVPStatus() async {
    // In a real app, you would check against the current user's ID
    final String currentUserId = 'user123';

    // For demo purposes, we'll use a simple check
    // In production, you'd query Firestore for the user's RSVP status
    setState(() {
      _isRSVPed = false; // Default to false for demo
    });
  }

  Future<void> _getRSVPCount() async {
    // In a real app, you would get the count from Firestore
    // For demo, we'll use a random number
    setState(() {
      _rsvpCount = 12; // Demo count
    });
  }

  Future<void> _toggleRSVP() async {
    final String currentUserId = 'user123'; // Replace with actual user ID

    // In a real app, you would update Firestore here
    // For demo, we'll just toggle the local state
    setState(() {
      _isRSVPed = !_isRSVPed;
      _rsvpCount = _isRSVPed ? _rsvpCount + 1 : _rsvpCount - 1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isRSVPed ? 'Successfully RSVPed!' : 'RSVP canceled'),
        backgroundColor: _isRSVPed ? Colors.green : Colors.orange,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String time) {
    // Format time to be more user-friendly
    // Handle both 24-hour and 12-hour formats
    try {
      if (time.contains(':')) {
        final parts = time.split(':');
        if (parts.length == 2) {
          int hour = int.tryParse(parts[0]) ?? 0;
          int minute = int.tryParse(parts[1]) ?? 0;

          String period = hour >= 12 ? 'PM' : 'AM';
          if (hour > 12) hour -= 12;
          if (hour == 0) hour = 12;

          return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
        }
      }
      return time; // Return original if parsing fails
    } catch (e) {
      return time; // Return original if any error occurs
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'By ${widget.event.presenter}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.people, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '$_rsvpCount attending',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      Icons.location_on,
                      'Location',
                      widget.event.location,
                    ),
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Date',
                      '${widget.event.date.year}-${widget.event.date.month.toString().padLeft(2, '0')}-${widget.event.date.day.toString().padLeft(2, '0')}',
                    ),
                    _buildInfoRow(
                      Icons.access_time,
                      'Time',
                      _formatTime(widget.event.time),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'About this Event',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.event.description,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _toggleRSVP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRSVPed
                        ? Colors.grey
                        : Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isRSVPed ? 'Cancel RSVP' : 'RSVP for this Event',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            if (_isRSVPed) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.green.withOpacity(0.1),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "You're attending this event! We'll send you reminders as the date approaches.",
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Card(
              color: Colors.blue.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Event Location Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.blue[600],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.event.location,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Make sure to arrive 15 minutes early to get settled in.',
                                style: TextStyle(
                                  fontSize: 12,
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
          ],
        ),
      ),
    );
  }
}

class _EventDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _EventDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
