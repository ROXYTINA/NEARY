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
  final String salonId;
  final String salonName;
  final String salonAvatar;
  final String lastMessage;
  final DateTime lastTime;
  final int unreadCount;

  const ChatThread({
    required this.salonId,
    required this.salonName,
    required this.salonAvatar,
    required this.lastMessage,
    required this.lastTime,
    required this.unreadCount,
  });
}
