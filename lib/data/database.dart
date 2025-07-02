// lib/data/database.dart
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

// --- 这是需要修正的关键部分 ---
import 'package:demo_conut/data/dao/user_dao.dart';
import 'package:demo_conut/data/models/user.dart';
// --- 修正结束 ---

part 'database.g.dart'; // 关键部分：指向将要生成的文件

@Database(version: 1, entities: [User])
abstract class AppDatabase extends FloorDatabase {
  UserDao get userDao;
}