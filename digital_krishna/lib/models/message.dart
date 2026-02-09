import 'verse.dart';

enum MessageRole { user, krishna }

class Message {
  final String id;
  final MessageRole role;
  final String text;
  final DateTime timestamp;
  final List<Verse>? verses;

  Message({
    required this.id,
    required this.role,
    required this.text,
    required this.timestamp,
    this.verses,
  });
}
