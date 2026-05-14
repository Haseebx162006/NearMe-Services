import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:near_me/core/Network/dioClient.dart';
import 'package:near_me/Frontend/Features/Chat/Model/ChatModel.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatRepository {
  final Dio _dio = Dioclient.dio;

  // --- HTTP Methods ---

  Future<ConversationModel> startConversation(String freelancerId, String gigId) async {
    final response = await _dio.post('/chat/start', data: {
      'freelancer_id': freelancerId,
      'gig_id': gigId,
    });
    return ConversationModel.fromJson(response.data);
  }

  Future<MessageModel> sendMessage({
    required String conversationId,
    required String receiverId,
    required String text,
    String messageType = 'text',
  }) async {
    final response = await _dio.post('/chat/send', data: {
      'conversation_id': conversationId,
      'receiver_id': receiverId,
      'text': text,
      'message_type': messageType,
    });
    return MessageModel.fromJson(response.data);
  }

  Future<List<ConversationModel>> getInbox() async {
    final response = await _dio.get('/chat/inbox');
    return (response.data as List)
        .map((e) => ConversationModel.fromJson(e))
        .toList();
  }

  Future<List<MessageModel>> getMessages(String conversationId, {int limit = 50, int skip = 0}) async {
    final response = await _dio.get('/chat/messages/$conversationId', queryParameters: {
      'limit': limit,
      'skip': skip,
    });
    return (response.data as List)
        .map((e) => MessageModel.fromJson(e))
        .toList();
  }

  Future<void> markRead(String conversationId) async {
    await _dio.post('/chat/read/$conversationId');
  }

  // --- WebSocket Methods ---

  WebSocketChannel connectWebSocket(String userId) {
    // Replace with your actual server WS URL
    final wsUrl = 'ws://192.168.100.4:8000/chat/ws/$userId';
    return WebSocketChannel.connect(Uri.parse(wsUrl));
  }

  void sendSocketMessage(WebSocketChannel channel, Map<String, dynamic> data) {
    channel.sink.add(jsonEncode(data));
  }
}
