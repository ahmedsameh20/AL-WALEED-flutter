class ChatMessage {
  final int senderId;
  final String message;
  final String createdAt;

  const ChatMessage({required this.senderId, required this.message, required this.createdAt});

  factory ChatMessage.fromMap(Map<String, Object?> map) {
    return ChatMessage(
      senderId: map['sender_id'] as int,
      message: map['message'] as String,
      createdAt: map['created_at'] as String? ?? '',
    );
  }
}

class ChatContact {
  final int id;
  final String name;

  const ChatContact({required this.id, required this.name});
}
