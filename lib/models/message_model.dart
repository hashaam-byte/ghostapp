class Message {
  final String id;
  final String userId;
  final String role;
  final String content;
  final int? xpAwarded;
  final String? category;
  final String? mood;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.userId,
    required this.role,
    required this.content,
    this.xpAwarded,
    this.category,
    this.mood,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      userId: json['userId'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      xpAwarded: json['xpAwarded'] as int?,
      category: json['category'] as String?,
      mood: json['mood'] as String?,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'role': role,
      'content': content,
      'xpAwarded': xpAwarded,
      'category': category,
      'mood': mood,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
  bool get isSystem => role == 'system';
}