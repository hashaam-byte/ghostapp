class Task {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String category;
  final String priority;
  final String status;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final int xpReward;
  final bool xpAwarded;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.category,
    required this.priority,
    required this.status,
    this.dueDate,
    this.completedAt,
    required this.xpReward,
    required this.xpAwarded,
    required this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String? ?? 'personal',
      priority: json['priority'] as String? ?? 'medium',
      status: json['status'] as String? ?? 'pending',
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      xpReward: json['xpReward'] as int? ?? 10,
      xpAwarded: json['xpAwarded'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'status': status,
      'dueDate': dueDate?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'xpReward': xpReward,
      'xpAwarded': xpAwarded,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Task copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? category,
    String? priority,
    String? status,
    DateTime? dueDate,
    DateTime? completedAt,
    int? xpReward,
    bool? xpAwarded,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      xpReward: xpReward ?? this.xpReward,
      xpAwarded: xpAwarded ?? this.xpAwarded,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isOverdue =>
      dueDate != null && dueDate!.isBefore(DateTime.now()) && isPending;
}