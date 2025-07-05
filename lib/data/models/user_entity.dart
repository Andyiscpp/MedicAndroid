// lib/data/models/user_entity.dart

import 'package:floor/floor.dart';

// 这个类专门用于Floor数据库，字段与数据库表列完全对应
@Entity(tableName: 'users')
class UserEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: 'user_name')
  final String username;

  @ColumnInfo(name: 'password_hash')
  final String passwordHash;

  // Floor数据库需要具体的列，我们用 nickname 来对应
  @ColumnInfo(name: 'nickname')
  final String nickname;

  final String email;

  final String? bio;

  @ColumnInfo(name: 'avatar_url')
  final String? avatarUrl;

  final int? role;

  UserEntity({
    this.id,
    required this.username,
    required this.passwordHash,
    required this.nickname,
    required this.email,
    this.bio,
    this.avatarUrl,
    this.role,
  });
}