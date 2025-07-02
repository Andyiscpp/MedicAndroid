// lib/data/models/user.dart

import 'package:floor/floor.dart';

@Entity(tableName: 'users')
class User {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: 'user_name')
  final String userName;

  @ColumnInfo(name: 'password_hash')
  final String passwordHash;

  @ColumnInfo(name: 'real_name')
  final String realName;

  // Floor会自动将字段名 'email' 转换为数据库列名 'email'
  final String email;

  // 同样，'location' 会被自动映射
  final String? location;

  // 这是Floor使用的构造函数
  User({
    this.id,
    required this.userName,
    required this.passwordHash,
    required this.realName,
    required this.email,
    this.location,
  });

  // A factory constructor to create a User from a map (e.g., when reading from the database).
  //  用于将从数据库或JSON读取的Map转换为User对象的工厂构造函数
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      userName: map['user_name'],
      passwordHash: map['password_hash'],
      realName: map['real_name'],
      email: map['email'],
      location: map['location'],
    );
  }

  // A method to convert a User instance into a map (e.g., when writing to the database).
  // 用于将User对象转换为Map以便存入数据库或转为JSON的方法
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_name': userName,
      'password_hash': passwordHash,
      'real_name': realName,
      'email': email,
      'location': location,
    };
  }
}