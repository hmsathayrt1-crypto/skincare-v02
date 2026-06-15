import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message_model.dart';
import '../services/chat_service.dart';

class ChatNotifier extends StateNotifier<AsyncValue<List<ChatMessageModel>>> {
  final ChatService _chatService = ChatService();
  bool _isLoadingReply = false;

  ChatNotifier() : super(const AsyncValue.data([]));

  bool get isLoadingReply => _isLoadingReply;

  Future<void> loadHistory() async {
    state = const AsyncValue.loading();
    try {
      final messages = await _chatService.getMessages();
      state = AsyncValue.data(messages);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> sendMessage(String text) async {
    final currentMessages = state.valueOrNull ?? [];

    // إضافة رسالة المستخدم محلياً
    final userMessage = ChatMessageModel(role: 'user', message: text);
    state = AsyncValue.data([...currentMessages, userMessage]);

    _isLoadingReply = true;

    try {
      final reply = await _chatService.sendMessage(message: text);
      final updatedMessages = state.valueOrNull ?? [];
      state = AsyncValue.data([...updatedMessages, reply]);
    } catch (e) {
      // إضافة رسالة خطأ
      final errorMsg = ChatMessageModel(
        role: 'assistant',
        message: 'عذراً، حدث خطأ. حاول مرة أخرى.',
      );
      final updatedMessages = state.valueOrNull ?? [];
      state = AsyncValue.data([...updatedMessages, errorMsg]);
    } finally {
      _isLoadingReply = false;
    }
  }
}

final chatMessagesProvider =
    StateNotifierProvider<ChatNotifier, AsyncValue<List<ChatMessageModel>>>((ref) {
  return ChatNotifier();
});

final chatLoadingProvider = Provider<bool>((ref) {
  final chatNotifier = ref.watch(chatMessagesProvider.notifier);
  return chatNotifier.isLoadingReply;
});
