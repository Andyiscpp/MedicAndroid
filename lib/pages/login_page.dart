import 'package:flutter/material.dart';
// 需要添加 flutter_svg 依赖
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart';

import 'package:demo_conut/pages/home_page.dart';
import 'package:demo_conut/pages/main_page.dart'; // 1. 导入 MainPage
import 'package:demo_conut/pages/register_page.dart';
import '../services/user_service.dart';


// 您需要在 pubspec.yaml 中添加 flutter_svg: ^2.0.10+1
// 并在项目根目录下创建 assets/images/ 文件夹，将下面的 SVG 代码保存为 herb_pattern.svg
/* SVG 代码 (herb_pattern.svg):
<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100" viewBox="0 0 100 100">
  <defs>
    <pattern id="p" width="100" height="100" patternUnits="userSpaceOnUse">
      <path d="M25 15 a 10 10 0 0 1 20 0 l-10 20 Z" fill="#E8F5E9" opacity="0.5"/>
      <path d="M75 45 a 10 10 0 0 1 20 0 l-10 20 Z" fill="#E8F5E9" opacity="0.5"/>
      <path d="M15 75 a 10 10 0 0 1 20 0 l-10 20 Z" fill="#E8F5E9" opacity="0.5"/>
    </pattern>
  </defs>
  <rect width="100%" height="100%" fill="url(#p)"/>
</svg>
*/

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final UserService _userService = UserService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      showToast('用户名和密码不能为空');
      return;
    }

    showToast('正在登录...', duration: const Duration(seconds: 3));

    // 调用更新后的登录服务
    final result = await _userService.login(username, password);

    if (mounted) {
      if (result['success']) {
        showToast(result['message']);
        // 2. ✅ *** 核心修复点 ***
        // 将导航目标从 HomePage 更改为 MainPage
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      } else {
        showToast(result['message']); // 显示后端返回的错误信息
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // // 如果您添加了 SVG 背景图
          // Positioned.fill(
          //   child: SvgPicture.asset(
          //     'assets/images/herb_pattern.svg',
          //     fit: BoxFit.cover,
          //   ),
          // ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 80.h),
                    _buildHeader(),
                    SizedBox(height: 50.h),
                    _buildTextField(
                      controller: _usernameController,
                      hint: '请输入用户名',
                      icon: Icons.person_outline,
                    ),
                    SizedBox(height: 20.h),
                    _buildTextField(
                      controller: _passwordController,
                      hint: '请输入密码',
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    SizedBox(height: 40.h),
                    _buildLoginButton(),
                    SizedBox(height: 16.h),
                    _buildRegisterButton(context),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 40.r,
          backgroundColor: AppColors.primaryLight,
          child: Text(
            '药',
            style: TextStyle(
              fontFamily: 'KaiTi', // 可以考虑引入一个中文字体
              fontSize: 38.sp,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          '中医药材数据系统',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          '欢迎回来，请登录',
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5)),
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.primaryLight.withOpacity(0.5),
        contentPadding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 20.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _login,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        padding: EdgeInsets.symmetric(vertical: 18.h),
      ),
      child: Text(
        '登 录',
        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const RegisterPage()),
        );
      },
      child: Text(
        '没有账号？立即注册',
        style: TextStyle(color: AppColors.primary, fontSize: 14.sp),
      ),
    );
  }
}