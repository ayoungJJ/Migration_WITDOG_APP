class Message {
  Message({
    required this.id,
    required this.userId,
    required this.petId,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String petId;
  final String content;
  final DateTime createdAt;

  Message.fromMap({
    required Map<String, dynamic> map,
    required String myUserId,
  })  : id = map['id'].toString(),
        userId = (map['user_id'] ?? myUserId).toString(),
        petId = map['pet_id'].toString(),
        content = map['content'].toString(),
        createdAt = map['created_at'] != null
            ? DateTime.parse(map['created_at'])
            : DateTime.now();
}