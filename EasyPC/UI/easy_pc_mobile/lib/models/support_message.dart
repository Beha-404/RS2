class SupportMessage {
  final int? id;
  final int? senderId;
  final int? conversationUserId;
  final String senderName;
  final String message;
  final bool isAdmin;
  final DateTime timestamp;
  final bool isRead;

  SupportMessage({
    this.id,
    this.senderId,
    this.conversationUserId,
    required this.senderName,
    required this.message,
    required this.isAdmin,
    required this.timestamp,
    this.isRead = false,
  });

  factory SupportMessage.fromJson(Map<String, dynamic> json) {
    return SupportMessage(
      id: json['id'] as int?,
      senderId: json['senderId'] as int?,
      conversationUserId: json['conversationUserId'] as int?,
      senderName: json['senderName'] as String,
      message: json['message'] as String,
      isAdmin: json['isAdmin'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (senderId != null) 'senderId': senderId,
      if (conversationUserId != null) 'conversationUserId': conversationUserId,
      'senderName': senderName,
      'message': message,
      'isAdmin': isAdmin,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }
}
