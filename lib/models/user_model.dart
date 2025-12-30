class User {
  final String id;
  final String? email;
  final String? username;
  final String? name;
  final String? displayName;
  final String? avatar;
  final String plan;
  final bool isGuest;
  final bool isOnline;
  final DateTime? lastActive;
  final DateTime createdAt;
  final GhostProfile? ghostProfile;
  final UsageStats? usageStats;
  final Subscription? subscription;

  User({
    required this.id,
    this.email,
    this.username,
    this.name,
    this.displayName,
    this.avatar,
    required this.plan,
    required this.isGuest,
    required this.isOnline,
    this.lastActive,
    required this.createdAt,
    this.ghostProfile,
    this.usageStats,
    this.subscription,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String?,
      username: json['username'] as String?,
      name: json['name'] as String?,
      displayName: json['displayName'] as String?,
      avatar: json['avatar'] as String?,
      plan: json['plan'] as String? ?? 'free',
      isGuest: json['isGuest'] as bool? ?? false,
      isOnline: json['isOnline'] as bool? ?? false,
      lastActive: json['lastActive'] != null
          ? DateTime.parse(json['lastActive'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      ghostProfile: json['ghostProfile'] != null
          ? GhostProfile.fromJson(json['ghostProfile'])
          : null,
      usageStats: json['usageStats'] != null
          ? UsageStats.fromJson(json['usageStats'])
          : null,
      subscription: json['subscription'] != null
          ? Subscription.fromJson(json['subscription'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'name': name,
      'displayName': displayName,
      'avatar': avatar,
      'plan': plan,
      'isGuest': isGuest,
      'isOnline': isOnline,
      'lastActive': lastActive?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'ghostProfile': ghostProfile?.toJson(),
      'usageStats': usageStats?.toJson(),
      'subscription': subscription?.toJson(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? username,
    String? name,
    String? displayName,
    String? avatar,
    String? plan,
    bool? isGuest,
    bool? isOnline,
    DateTime? lastActive,
    DateTime? createdAt,
    GhostProfile? ghostProfile,
    UsageStats? usageStats,
    Subscription? subscription,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      avatar: avatar ?? this.avatar,
      plan: plan ?? this.plan,
      isGuest: isGuest ?? this.isGuest,
      isOnline: isOnline ?? this.isOnline,
      lastActive: lastActive ?? this.lastActive,
      createdAt: createdAt ?? this.createdAt,
      ghostProfile: ghostProfile ?? this.ghostProfile,
      usageStats: usageStats ?? this.usageStats,
      subscription: subscription ?? this.subscription,
    );
  }
}

class GhostProfile {
  final String id;
  final String userId;
  final String personality;
  final String? tone;
  final String mode;
  final int evolutionStage;
  final String ghostForm;
  final int totalXP;
  final int level;
  final int xpToNextLevel;
  final int coins;
  final String avatarStyle;
  final String skinColor;
  final String glowColor;
  final String auraColor;
  final String currentAnimation;
  final String currentMood;
  final bool isSleeping;
  final List<String> mainFocusAreas;
  final String motivationStyle;

  GhostProfile({
    required this.id,
    required this.userId,
    required this.personality,
    this.tone,
    required this.mode,
    required this.evolutionStage,
    required this.ghostForm,
    required this.totalXP,
    required this.level,
    required this.xpToNextLevel,
    required this.coins,
    required this.avatarStyle,
    required this.skinColor,
    required this.glowColor,
    required this.auraColor,
    required this.currentAnimation,
    required this.currentMood,
    required this.isSleeping,
    required this.mainFocusAreas,
    required this.motivationStyle,
  });

  factory GhostProfile.fromJson(Map<String, dynamic> json) {
    return GhostProfile(
      id: json['id'] as String,
      userId: json['userId'] as String,
      personality: json['personality'] as String? ?? 'chill',
      tone: json['tone'] as String?,
      mode: json['mode'] as String? ?? 'normal',
      evolutionStage: json['evolutionStage'] as int? ?? 1,
      ghostForm: json['ghostForm'] as String? ?? 'baby',
      totalXP: json['totalXP'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      xpToNextLevel: json['xpToNextLevel'] as int? ?? 100,
      coins: json['coins'] as int? ?? 0,
      avatarStyle: json['avatarStyle'] as String? ?? 'basic',
      skinColor: json['skinColor'] as String? ?? '#FFFFFF',
      glowColor: json['glowColor'] as String? ?? '#A020F0',
      auraColor: json['auraColor'] as String? ?? 'pink',
      currentAnimation: json['currentAnimation'] as String? ?? 'float',
      currentMood: json['currentMood'] as String? ?? 'happy',
      isSleeping: json['isSleeping'] as bool? ?? false,
      mainFocusAreas: (json['mainFocusAreas'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      motivationStyle: json['motivationStyle'] as String? ?? 'positive',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'personality': personality,
      'tone': tone,
      'mode': mode,
      'evolutionStage': evolutionStage,
      'ghostForm': ghostForm,
      'totalXP': totalXP,
      'level': level,
      'xpToNextLevel': xpToNextLevel,
      'coins': coins,
      'avatarStyle': avatarStyle,
      'skinColor': skinColor,
      'glowColor': glowColor,
      'auraColor': auraColor,
      'currentAnimation': currentAnimation,
      'currentMood': currentMood,
      'isSleeping': isSleeping,
      'mainFocusAreas': mainFocusAreas,
      'motivationStyle': motivationStyle,
    };
  }
}

class UsageStats {
  final int chatCount;
  final int chatLimit;
  final int scanCount;
  final int scanLimit;
  final int schoolScanCount;
  final int schoolScanLimit;

  UsageStats({
    required this.chatCount,
    required this.chatLimit,
    required this.scanCount,
    required this.scanLimit,
    required this.schoolScanCount,
    required this.schoolScanLimit,
  });

  factory UsageStats.fromJson(Map<String, dynamic> json) {
    return UsageStats(
      chatCount: json['chatCount'] as int? ?? 0,
      chatLimit: json['chatLimit'] as int? ?? 50,
      scanCount: json['scanCount'] as int? ?? 0,
      scanLimit: json['scanLimit'] as int? ?? 10,
      schoolScanCount: json['schoolScanCount'] as int? ?? 0,
      schoolScanLimit: json['schoolScanLimit'] as int? ?? 5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatCount': chatCount,
      'chatLimit': chatLimit,
      'scanCount': scanCount,
      'scanLimit': scanLimit,
      'schoolScanCount': schoolScanCount,
      'schoolScanLimit': schoolScanLimit,
    };
  }
}

class Subscription {
  final String plan;
  final String status;

  Subscription({
    required this.plan,
    required this.status,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      plan: json['plan'] as String? ?? 'free',
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan': plan,
      'status': status,
    };
  }
}