import 'dart:convert';

class Message {
  final String id;
  final String userId;
  final String petId;
  final String context;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.userId,
    required this.petId,
    required this.context,
    required this.createdAt,
  });

  factory Message.fromMap(Map<String, dynamic> map, {String? myUserId}) {
    print('Message.fromMap received data: $map');

    return Message(
      id: map['id'].toString(),
      context: map['context'].toString() ?? '',
      createdAt: DateTime.parse(map['created_at']),
      userId: myUserId ?? (map['user_id']?.toString() ?? ''),
      petId: map['pet_id']?.toString() ?? '',
    );
  }

  factory Message.empty() {
    return Message(
      id: '0',
      userId: '',
      petId: '',
      context: '',
      createdAt: DateTime.now(),
    );
  }
}