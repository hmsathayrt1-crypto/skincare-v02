import 'package:skincare_v02/core/models/chat_message_model.dart';
import 'package:skincare_v02/core/network/dio_client.dart';
import 'package:skincare_v02/core/constants/api_endpoints.dart';

class ChatService {
  final DioClient _client = DioClient();

  Future<List<ChatMessageModel>> getMessages() async {
    final resp = await _client.dio.get(ApiEndpoints.chat);
    final data = resp.data as Map<String, dynamic>;
    if (data['success'] == true) {
      return (data['messages'] as List)
          .map((m) => ChatMessageModel.fromJson(m))
          .toList();
    }
    throw Exception(data['error'] ?? 'Failed to load messages');
  }

  Future<ChatMessageModel> sendMessage({
    required String message,
    String? imagePath,
  }) async {
    final resp = await _client.dio.post(
      ApiEndpoints.chat,
      data: {'message': message},
    );
    final data = resp.data as Map<String, dynamic>;
    if (data['success'] == true) {
      return ChatMessageModel.fromJson(data['reply']);
    }
    throw Exception(data['error'] ?? 'Failed to send message');
  }
}
