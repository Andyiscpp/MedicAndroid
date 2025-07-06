// lib/app.dart
import 'package:demo_conut/pages/main_page.dart'; // 1. 导入 MainPage
import 'package:demo_conut/pages/home_page.dart';
import 'package:demo_conut/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart';


/// 获取设计稿尺寸
Size get designSize {
  // ... (代码保持不变)
  final firstView = WidgetsBinding.instance.platformDispatcher.views.first;
  final physicalSize = firstView.physicalSize;
  final devicePixelRatio = firstView.devicePixelRatio;
  final logicalShortestSide = physicalSize.shortestSide / devicePixelRatio;
  final logicalLongestSide = physicalSize.longestSide / devicePixelRatio;
  const scaleFactor = 0.95;
  return Size(logicalShortestSide * scaleFactor, logicalLongestSide * scaleFactor);
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: ScreenUtilInit(
        designSize: designSize,
        builder: (context, child) {
          return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
              useMaterial3: true,
            ),
            home: child,
          );
        },
        // 2. 将 isLoggedIn 的判断逻辑修改为加载 MainPage
        child: isLoggedIn ? const MainPage() : const LoginPage(),
      ),
    );
  }
}