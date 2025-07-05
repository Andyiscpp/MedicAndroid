// lib/data/models/user.dart

// 最终版用户模型，与后端数据库结构完全对应
class User {
  // --- From `users` table ---
  final int id;
  final String username;
  final String? passwordHash; // 仅在本地使用，服务器不会返回
  final int? role;
  final int? status;
  final String? createdAt;

  // --- From `user_profiles` table ---
  final String? nickname;
  final String? avatarUrl;
  final String? gender;
  final String? bio;

  // --- App-specific field (not from server) ---
  final String? email;

  User({
    required this.id,
    required this.username,
    this.passwordHash,
    this.role,
    this.status,
    this.createdAt,
    this.nickname,
    this.avatarUrl,
    this.gender,
    this.bio,
    this.email,
  });

  /// 一个方便的 getter，用于在UI中显示用户的最佳名称。
  /// 优先显示昵称，如果昵称为空，则回退到用户名。
  String get displayName => (nickname != null && nickname!.isNotEmpty) ? nickname! : username;

  /// 用于轻松创建用户对象修改后副本的方法。
  User copyWith({
    int? id,
    String? username,
    String? passwordHash,
    int? role,
    int? status,
    String? createdAt,
    String? nickname,
    String? avatarUrl,
    String? gender,
    String? bio,
    String? email,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
      email: email ?? this.email,
    );
  }

  /// 从Map（例如来自服务器的JSON）创建User对象的工厂构造函数。
  /// 这个构造函数非常健壮，能优雅地处理缺失字段。
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: (map['id'] as num?)?.toInt() ?? 0,
      username: map['username'] ?? '',
      passwordHash: map['passwordHash'], // 服务器不发送此字段
      role: (map['role'] as num?)?.toInt(),
      status: (map['status'] as num?)?.toInt(),
      createdAt: map['createdAt'],
      nickname: map['nickname'],
      avatarUrl: map['avatarUrl'],
      gender: map['gender'],
      bio: map['bio'],
      email: map['email'], // 服务器不发送此字段
    );
  }

  /// 将User实例转换为Map的方法（例如，用于保存到本地存储）。
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'passwordHash': passwordHash,
      'role': role,
      'status': status,
      'createdAt': createdAt,
      'nickname': nickname,
      'avatarUrl': avatarUrl,
      'gender': gender,
      'bio': bio,
      'email': email,
    };
  }
}