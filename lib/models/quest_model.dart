class Quest {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String type;
  final String category;
  final int target;
  final int progress;
  final String unit;
  final int xpReward;
  final int coinReward;
  final String? itemReward;
  final String status;
  final DateTime? expiresAt;
  final DateTime? completedAt;
  final String difficulty;
  final DateTime createdAt;

  Quest({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.target,
    required this.progress,
    required this.unit,
    required this.xpReward,
    required this.coinReward,
    this.itemReward,
    required this.status,
    this.expiresAt,
    this.completedAt,
    required this.difficulty,
    required this.createdAt,
  });

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      category: json['category'] as String,
      target: json['target'] as int,
      progress: json['progress'] as int? ?? 0,
      unit: json['unit'] as String? ?? 'count',
      xpReward: json['xpReward'] as int,
      coinReward: json['coinReward'] as int? ?? 0,
      itemReward: json['itemReward'] as String?,
      status: json['status'] as String? ?? 'active',
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      difficulty: json['difficulty'] as String? ?? 'easy',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'type': type,
      'category': category,
      'target': target,
      'progress': progress,
      'unit': unit,
      'xpReward': xpReward,
      'coinReward': coinReward,
      'itemReward': itemReward,
      'status': status,
      'expiresAt': expiresAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'difficulty': difficulty,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Quest copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? type,
    String? category,
    int? target,
    int? progress,
    String? unit,
    int? xpReward,
    int? coinReward,
    String? itemReward,
    String? status,
    DateTime? expiresAt,
    DateTime? completedAt,
    String? difficulty,
    DateTime? createdAt,
  }) {
    return Quest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      target: target ?? this.target,
      progress: progress ?? this.progress,
      unit: unit ?? this.unit,
      xpReward: xpReward ?? this.xpReward,
      coinReward: coinReward ?? this.coinReward,
      itemReward: itemReward ?? this.itemReward,
      status: status ?? this.status,
      expiresAt: expiresAt ?? this.expiresAt,
      completedAt: completedAt ?? this.completedAt,
      difficulty: difficulty ?? this.difficulty,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  double get progressPercentage => (progress / target * 100).clamp(0, 100);
  bool get isCompleted => status == 'completed';
  bool get isActive => status == 'active';
  bool get isExpired => status == 'expired';
  bool get isDaily => type == 'daily';
}