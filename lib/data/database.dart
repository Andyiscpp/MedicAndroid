// lib/data/database.dart
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

// 【关键修复】引入新的 UserEntity 和更新后的 UserDao
import 'package:demo_conut/data/dao/user_dao.dart';
import 'package:demo_conut/data/models/user_entity.dart';

part 'database.g.dart'; // 指向将要生成的文件

// 【关键修复】在 entities 列表中使用 UserEntity 而不是 User
@Database(version: 1, entities: [UserEntity])
abstract class AppDatabase extends FloorDatabase {
  UserDao get userDao;
}