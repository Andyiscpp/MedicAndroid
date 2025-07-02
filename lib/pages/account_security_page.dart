import 'package:demo_conut/data/models/user.dart';
import 'package:demo_conut/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart';
import 'home_page.dart'; // 导入以使用 AppColors

class AccountSecurityPage extends StatefulWidget {
  const AccountSecurityPage({super.key});

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

  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _userService.getLoggedInUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _changePassword() async {
    // 首先，确保用户信息已加载
    if (_currentUser == null) {
      showToast('无法获取用户信息，请稍后重试');
      return;
    }

    if (_formKey.currentState!.validate()) {
      // 验证原密码是否正确
      if (_oldPasswordController.text != _currentUser!.passwordHash) {
        showToast('原密码不正确');
        return;
      }

      // 更新用户密码
      final updatedUser = User(
        id: _currentUser!.id,
        userName: _currentUser!.userName, // ✅ 用户名保持不变
        passwordHash: _newPasswordController.text, // 使用新密码
        realName: _currentUser!.realName,
        email: _currentUser!.email,
        location: _currentUser!.location,
      );

      final success = await _userService.updateUser(updatedUser);

      if (mounted) {
        if (success) {
          showToast('密码修改成功！');
          // 成功后清空输入框并返回
          _oldPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
          Navigator.of(context).pop();
        } else {
          showToast('密码更新失败，请稍后重试');
        }
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
        title: const Text(
          '账号与安全',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          children: [
            _buildSecurityNotice(),
            SizedBox(height: 24.h),
            // ✅ 新增：账户信息卡片，仅用于显示
            _buildAccountInfoCard(),
            SizedBox(height: 24.h),
            _buildChangePasswordForm(),
          ],
        ),
      ),
    );
  }

  // ✅ 新增：账户信息卡片，仅显示用户名
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
            _currentUser?.userName ?? '加载中...',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }

  // 安全提示区域
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

  // 修改密码表单区域
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
            onVisibilityToggle: () {
              setState(() => _isOldPasswordVisible = !_isOldPasswordVisible);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入您的原密码';
              }
              return null;
            },
          ),
          SizedBox(height: 20.h),
          _buildPasswordTextField(
            controller: _newPasswordController,
            label: '新密码',
            isVisible: _isNewPasswordVisible,
            onVisibilityToggle: () {
              setState(() => _isNewPasswordVisible = !_isNewPasswordVisible);
            },
            validator: (value) {
              if (value == null || value.length < 6) {
                return '新密码不能少于6位';
              }
              if (value == _oldPasswordController.text) {
                return '新密码不能与原密码相同';
              }
              return null;
            },
          ),
          SizedBox(height: 20.h),
          _buildPasswordTextField(
            controller: _confirmPasswordController,
            label: '确认新密码',
            isVisible: _isConfirmPasswordVisible,
            onVisibilityToggle: () {
              setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
            },
            validator: (value) {
              if (value != _newPasswordController.text) {
                return '两次输入的密码不一致';
              }
              return null;
            },
          ),
          SizedBox(height: 40.h),
          ElevatedButton.icon(
            icon: const Icon(Icons.save_outlined),
            label: const Text('确认修改'),
            onPressed: _changePassword,
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

  // 可切换可见性的密码输入框
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