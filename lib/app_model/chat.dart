class ChatMessage {
  final String id;
  final String salonId;
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.salonId,
    required this.text,
    required this.isMe,
    required this.timestamp,
    required this.isRead,
  });
}

class ChatThread {
  final String stylistId;
  final String stylistName;
  final String stylistAvatar;
  final String lastMessage;
  final DateTime lastTime;
  final int unreadCount;

  const ChatThread({
    required this.stylistId,
    required this.stylistName,
    required this.stylistAvatar,
    required this.lastMessage,
    required this.lastTime,
    required this.unreadCount,
  });

  factory ChatThread.fromJson(Map<String, dynamic> json) {
    return ChatThread(
      stylistId: json['user_id'] ?? '',
      stylistName: json['user_name'] ?? 'Stylist',
      stylistAvatar: json['user_avatar'] ?? '',
      lastMessage: json['last_message'] ?? '',
      lastTime: DateTime.parse(json['last_time']),
      unreadCount: json['unread_count'] ?? 0,
    );
  }
}
