import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:near_me/Frontend/Features/Auth/ViewModel/authViewModel.dart';
import 'package:near_me/Frontend/Features/Chat/Model/ChatModel.dart';
import 'package:near_me/Frontend/Features/Chat/Repository/ChatRepository.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final chatRepositoryProvider = Provider((ref) => ChatRepository());

// --- Inbox Provider ---
final inboxProvider = FutureProvider<List<ConversationModel>>((ref) async {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.getInbox();
});

// --- Selected Chat ID Provider ---
final selectedChatIdProvider = StateProvider<String>((ref) => "");

// --- Active Chat Provider ---
class ChatNotifier extends AsyncNotifier<List<MessageModel>> {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  bool isOtherUserTyping = false;

  @override
  FutureOr<List<MessageModel>> build() async {
    final conversationId = ref.watch(selectedChatIdProvider);
    if (conversationId.isEmpty) return [];

    final repo = ref.watch(chatRepositoryProvider);
    final user = ref.watch(authprovider).value;
    final currentUserId = user?.id ?? '';

    ref.onDispose(() {
      _subscription?.cancel();
      _channel?.sink.close();
    });

    final history = await repo.getMessages(conversationId);

    if (currentUserId.isNotEmpty) {
      _channel = repo.connectWebSocket(currentUserId);
      _subscription = _channel!.stream.listen((event) {
        _handleSocketEvent(jsonDecode(event), conversationId);
      });
      repo.markRead(conversationId);
    }

    return history;
  }

  void _handleSocketEvent(Map<String, dynamic> payload, String conversationId) {
    final event = payload['event'];
    final data = payload['data'];

    if (event == 'message_received') {
      final newMsg = MessageModel.fromJson(data);
      if (newMsg.conversationId == conversationId) {
        final currentMessages = state.value ?? [];
        if (!currentMessages.any((m) => m.id == newMsg.id)) {
          state = AsyncValue.data([...currentMessages, newMsg]);
        }
      }
    } else if (event == 'typing_indicator') {
      if (data['conversation_id'] == conversationId) {
        isOtherUserTyping = data['is_typing'] ?? false;
        state = AsyncValue.data([...state.value ?? []]);
      }
    }
  }

  Future<void> sendMessage(String text, String receiverId) async {
    final conversationId = ref.read(selectedChatIdProvider);
    if (text.trim().isEmpty || conversationId.isEmpty) return;

    final repo = ref.read(chatRepositoryProvider);
    final user = ref.read(authprovider).value;
    final currentUserId = user?.id ?? '';

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final tempMsg = MessageModel(
      id: tempId,
      conversationId: conversationId,
      senderId: currentUserId,
      receiverId: receiverId,
      text: text,
      messageType: 'text',
      status: 'sending',
      timestamp: DateTime.now(),
    );
    
    final currentMessages = state.value ?? [];
    state = AsyncValue.data([...currentMessages, tempMsg]);

    try {
      final savedMsg = await repo.sendMessage(
        conversationId: conversationId,
        receiverId: receiverId,
        text: text,
      );
      
      final updatedMessages = state.value ?? [];
      state = AsyncValue.data(
        updatedMessages.map((m) => m.id == tempId ? savedMsg : m).toList(),
      );
    } catch (e) {
      final updatedMessages = state.value ?? [];
      state = AsyncValue.data(
        updatedMessages.map((m) {
          if (m.id == tempId) {
            return MessageModel(
              id: m.id,
              conversationId: m.conversationId,
              senderId: m.senderId,
              receiverId: m.receiverId,
              text: m.text,
              messageType: m.messageType,
              status: 'error',
              timestamp: m.timestamp,
            );
          }
          return m;
        }).toList(),
      );
    }
  }

  void sendTypingStatus(bool isTyping, String receiverId) {
    final conversationId = ref.read(selectedChatIdProvider);
    if (_channel == null || conversationId.isEmpty) return;
    ref.read(chatRepositoryProvider).sendSocketMessage(_channel!, {
      'event': 'typing',
      'data': {
        'conversation_id': conversationId,
        'receiver_id': receiverId,
        'is_typing': isTyping,
      }
    });
  }
}

final activeChatProvider = AsyncNotifierProvider<ChatNotifier, List<MessageModel>>(
  ChatNotifier.new,
);
