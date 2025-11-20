class SupportMessage {
  final int id;
  final int senderId;
  final int conversationUserId;
  final String senderName;
  final String message;
  final bool isAdmin;
  final DateTime timestamp;
  final bool isRead;

  SupportMessage({
    required this.id,
    required this.senderId,
    required this.conversationUserId,
    required this.senderName,
    required this.message,
    required this.isAdmin,
    required this.timestamp,
    required this.isRead,
  });

  factory SupportMessage.fromJson(Map<String, dynamic> json) {
    return SupportMessage(
      id: json['id'] ?? 0,
      senderId: json['senderId'] ?? 0,
      conversationUserId: json['conversationUserId'] ?? 0,
      senderName: json['senderName'] ?? '',
      message: json['message'] ?? '',
      isAdmin: json['isAdmin'] ?? false,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'conversationUserId': conversationUserId,
      'senderName': senderName,
      'message': message,
      'isAdmin': isAdmin,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }
}

class Conversation {
  final int userId;
  final String username;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  Conversation({
    required this.userId,
    required this.username,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      userId: json['userId'] ?? 0,
      username: json['username'] ?? '',
      lastMessage: json['lastMessage'] ?? '',
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'])
          : DateTime.now(),
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}
