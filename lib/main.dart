import 'package:demo_conut/services/oss_service.dart';
import 'package:flutter/material.dart';
import 'package:demo_conut/app.dart';
import 'package:demo_conut/services/user_service.dart';

void main() async {
  // 确保 Flutter 绑定已初始化
  WidgetsFlutterBinding.ensureInitialized();

  final userService = UserService();
  final bool loggedIn = await userService.isLoggedIn();

  runApp(MyApp(isLoggedIn: loggedIn));
}