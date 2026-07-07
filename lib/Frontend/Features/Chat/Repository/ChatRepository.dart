import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:near_me/core/Network/dioClient.dart';
import 'package:near_me/Frontend/Features/Chat/Model/ChatModel.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatRepository {
  final Dio _dio = Dioclient.dio;

  // --- HTTP Methods ---

  Future<ConversationModel> startConversation(
    String freelancerId,
    String gigId,
  ) async {
    final response = await _dio.post(
      '/chat/start',
      data: {'freelancer_id': freelancerId, 'gig_id': gigId},
    );
    return ConversationModel.fromJson(response.data);
  }

  Future<MessageModel> sendMessage({
    required String conversationId,
    required String receiverId,
    required String content,
  }) async {
    final response = await _dio.post(
      '/chat/send',
      data: {
        'conversation_id': conversationId,
        'receiver_id': receiverId,
        'content': content,
      },
    );
    return MessageModel.fromJson(response.data);
  }

  Future<List<ConversationModel>> getInbox() async {
    final response = await _dio.get('/chat/inbox');
    return (response.data as List)
        .map((e) => ConversationModel.fromJson(e))
        .toList();
  }

  Future<List<MessageModel>> getChatHistory(
    String conversationId, {
    int limit = 50,
    int skip = 0,
  }) async {
    final response = await _dio.get(
      '/chat/messages/$conversationId',
      queryParameters: {'limit': limit, 'skip': skip},
    );
    return (response.data as List)
        .map((e) => MessageModel.fromJson(e))
        .toList();
  }

  Future<void> markRead(String conversationId) async {
    await _dio.post('/chat/read/$conversationId');
  }

  // --- WebSocket Methods ---

  WebSocketChannel connectWebSocket(String userId) {
    // Check if a dedicated CHAT_BASE_URL is specified in the environment (e.g. for Render deployment of chat service)
    final String? chatBaseUrl = dotenv.env['CHAT_BASE_URL'];
    final String sourceUrl = (chatBaseUrl != null && chatBaseUrl.isNotEmpty)
        ? chatBaseUrl
        : Dioclient.baseUrl;

    // Convert https://... to wss://... or http://... to ws://...
    String wsBase;
    if (sourceUrl.startsWith('https://')) {
      wsBase = sourceUrl.replaceFirst('https://', 'wss://');
    } else if (sourceUrl.startsWith('http://')) {
      wsBase = sourceUrl.replaceFirst('http://', 'ws://');
    } else {
      // Fallback
      wsBase = 'ws://192.168.100.4:8000';
    }

    final wsUrl = '$wsBase/chat/ws/$userId';
    print('[WebSocket] Connecting to: $wsUrl');
    return WebSocketChannel.connect(Uri.parse(wsUrl));
  }

  void sendSocketMessage(WebSocketChannel channel, Map<String, dynamic> data) {
    channel.sink.add(jsonEncode(data));
  }
}
