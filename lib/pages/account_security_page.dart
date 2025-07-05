// lib/pages/account_security_page.dart

import 'package:demo_conut/data/models/user.dart';
import 'package:demo_conut/pages/login_page.dart';
import 'package:demo_conut/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart';
import 'home_page.dart';

class AccountSecurityPage extends StatefulWidget {
  final User user;
  const AccountSecurityPage({super.key, required this.user});

  @override
  _AccountSecurityPageState createState() => _AccountSecurityPageState();
}

class _AccountSecurityPageState extends State<AccountSecurityPage> {
  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();

  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// 【关键修复】调用新的 changePassword 服务
  void _changePassword() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    setState(() => _isSaving = true);

    final result = await _userService.changePassword(
      oldPassword: _oldPasswordController.text,
      newPassword: _newPasswordController.text,
      rePassword: _confirmPasswordController.text,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      showToast(result['message']); // 显示后端返回的提示信息

      if (result['success'] == true) { // 明确判断布尔值
        // 【关键修复】密码修改成功后，执行退出登录操作
        await _userService.logout();

        // 延迟一小段时间让用户看到提示
        await Future.delayed(const Duration(seconds: 2));

        // 强制退出到登录页，并清空所有历史路由
        // 增加 `!context.mounted` 检查，确保安全
        if (!context.mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
              (Route<dynamic> route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('账号与安全', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          children: [
            _buildSecurityNotice(),
            SizedBox(height: 24.h),
            _buildAccountInfoCard(),
            SizedBox(height: 24.h),
            _buildChangePasswordForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfoCard() {
    return Card(
      elevation: 2,
      shadowColor: AppColors.primary.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.person_outline, color: AppColors.primary),
          title: const Text('用户名', style: TextStyle(color: AppColors.textSecondary)),
          trailing: Text(
            widget.user.username,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }

  Widget _buildChangePasswordForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPasswordTextField(
            controller: _oldPasswordController,
            label: '原密码',
            isVisible: _isOldPasswordVisible,
            onVisibilityToggle: () => setState(() => _isOldPasswordVisible = !_isOldPasswordVisible),
            validator: (value) {
              if (value == null || value.isEmpty) return '请输入您的原密码';
              // 客户端校验原密码是否与登录时缓存的一致
              if (value != widget.user.passwordHash) return '原密码不正确';
              return null;
            },
          ),
          SizedBox(height: 20.h),
          _buildPasswordTextField(
            controller: _newPasswordController,
            label: '新密码',
            isVisible: _isNewPasswordVisible,
            onVisibilityToggle: () => setState(() => _isNewPasswordVisible = !_isNewPasswordVisible),
            validator: (value) {
              if (value == null || value.length < 6) return '新密码不能少于6位';
              if (value == _oldPasswordController.text) return '新密码不能与原密码相同';
              return null;
            },
          ),
          SizedBox(height: 20.h),
          _buildPasswordTextField(
            controller: _confirmPasswordController,
            label: '确认新密码',
            isVisible: _isConfirmPasswordVisible,
            onVisibilityToggle: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
            validator: (value) {
              if (value != _newPasswordController.text) return '两次输入的密码不一致';
              return null;
            },
          ),
          SizedBox(height: 40.h),
          ElevatedButton.icon(
            icon: _isSaving ? const SizedBox.shrink() : const Icon(Icons.save_outlined),
            label: Text(_isSaving ? '正在提交...' : '确认修改'),
            onPressed: _isSaving ? null : _changePassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              textStyle: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityNotice() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.security_outlined, color: AppColors.primary, size: 28.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '安全建议',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '为了保护您的账户安全，我们建议您定期修改密码，并使用包含字母、数字和符号的复杂密码组合。',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildPasswordTextField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
        ),
        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.grey,
          ),
          onPressed: onVisibilityToggle,
        ),
      ),
    );
  }
}