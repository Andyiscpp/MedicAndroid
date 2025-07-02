// lib/app.dart
import 'package:demo_conut/pages/home_page.dart';
import 'package:demo_conut/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart';


/// 获取设计稿尺寸
Size get designSize {
  // 1.获取屏幕的物理尺寸
  final firstView = WidgetsBinding.instance.platformDispatcher.views.first;
  final physicalSize = firstView.physicalSize;
  // 2.获取像素比
  final devicePixelRatio = firstView.devicePixelRatio;
  // 3.计算逻辑尺寸
  final logicalShortestSide = physicalSize.shortestSide / devicePixelRatio;
  final logicalLongestSide = physicalSize.longestSide / devicePixelRatio;
  // 根据逻辑尺寸的短边大小，返回不同的设计稿尺寸，以进行适配
  const scaleFactor = 0.95;
  // 根据逻辑尺寸的短边返回大小
  return Size(logicalShortestSide * scaleFactor, logicalLongestSide * scaleFactor);
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn; // 添加此行

  const MyApp({super.key, required this.isLoggedIn}); // 修改构造函数

  @override
  Widget build(BuildContext context) {
    // toost/提示框/API初始化等预处理
    return OKToast(
      child: ScreenUtilInit(
        designSize: designSize,
        builder: (context, child) {
          return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            // ✅ 在这里使用 builder 提供的 child
            home: child,
          );
        },
        // ✅ 将需要进行屏幕适配的页面作为 child 传递
        child: isLoggedIn ? const HomePage() : const LoginPage(),
      ),
    );
  }
}