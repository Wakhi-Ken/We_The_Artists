import 'package:flutter/material.dart';
import 'models.dart';

class EventDetailPage extends StatelessWidget {
  final Event event;

  const EventDetailPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Event")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text("By ${event.presenter}"),
            const SizedBox(height: 16),

            EventDetailRow(label: "Location:", value: event.location),
            EventDetailRow(
                label: "Date:",
                value: "${event.date.toLocal().toString().split(' ')[0]}"),
            EventDetailRow(label: "Time:", value: event.time),

            const SizedBox(height: 24),
            const Text("Description",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(event.description),
          ],
        ),
      ),
    );
  }
}

class EventDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const EventDetailRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
