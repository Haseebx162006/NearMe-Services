class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String receiverId;
  final String text;
  final String messageType;
  final String status;
  final DateTime timestamp;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.messageType,
    required this.status,
    required this.timestamp,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'] ?? '',
      conversationId: json['conversation_id'] ?? '',
      senderId: json['sender_id'] ?? '',
      receiverId: json['receiver_id'] ?? '',
      text: json['text'] ?? '',
      messageType: json['message_type'] ?? 'text',
      status: json['status'] ?? 'sent',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'text': text,
      'message_type': messageType,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class ConversationModel {
  final String id;
  final String customerId;
  final String freelancerId;
  final String gigId;
  final String lastMessage;
  final int unreadCount;
  final DateTime updatedAt;
  final String? otherUserName;
  final String? otherUserImage;
  final String? gigTitle;

  ConversationModel({
    required this.id,
    required this.customerId,
    required this.freelancerId,
    required this.gigId,
    required this.lastMessage,
    required this.unreadCount,
    required this.updatedAt,
    this.otherUserName,
    this.otherUserImage,
    this.gigTitle,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['_id'] ?? '',
      customerId: json['customer_id'] ?? '',
      freelancerId: json['freelancer_id'] ?? '',
      gigId: json['gig_id'] ?? '',
      lastMessage: json['last_message'] ?? '',
      unreadCount: json['unread_count'] ?? 0,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
      otherUserName: json['other_user_name'],
      otherUserImage: json['other_user_image'],
      gigTitle: json['gig_title'],
    );
  }
}
