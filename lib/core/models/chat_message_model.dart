class ChatMessageModel {
  final int? id;
  final String role; // 'user' or 'assistant'
  final String message;
  final String? imagePath;
  final String? createdAt;

  ChatMessageModel({
    this.id,
    required this.role,
    required this.message,
    this.imagePath,
    this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
      role: json['role'] ?? 'user',
      message: json['message'] ?? '',
      imagePath: json['image_path'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role,
        'message': message,
        'image_path': imagePath,
        'created_at': createdAt,
      };

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
}
