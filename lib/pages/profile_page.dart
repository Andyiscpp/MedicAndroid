// lib/pages/profile_page.dart

import 'package:demo_conut/data/models/user.dart';
import 'package:demo_conut/pages/about_us_page.dart';
import 'package:demo_conut/pages/account_security_page.dart';
import 'package:demo_conut/pages/edit_profile_page.dart';
import 'package:demo_conut/pages/my_uploads_page.dart';
import 'package:demo_conut/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_conut/pages/home_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _userService = UserService();
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final user = await _userService.fetchAndSaveUserProfile();
    if (mounted) {
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    }
  }

  void _navigateToEditProfile() {
    if (_currentUser == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(user: _currentUser!),
      ),
    ).then((updated) {
      if (updated == true) {
        _loadCurrentUser();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ *** 核心修改点: 移除Scaffold和AppBar, 直接返回页面内容 ***
    return Container(
      color: AppColors.background,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
        onRefresh: _loadCurrentUser,
        child: _currentUser == null
            ? Center(child: TextButton(onPressed: _loadCurrentUser, child: const Text('加载失败，点击重试')))
            : SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            children: [
              _buildProfileHeader(),
              SizedBox(height: 30.h),
              _buildOptionsList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final hasAvatar = _currentUser?.avatarUrl != null && _currentUser!.avatarUrl!.isNotEmpty;
    return Column(
      children: [
        CircleAvatar(
          radius: 50.r,
          backgroundImage: hasAvatar ? NetworkImage(_currentUser!.avatarUrl!) : null,
          backgroundColor: AppColors.primaryLight,
          child: hasAvatar ? null : Text(
            _currentUser!.username.isNotEmpty ? _currentUser!.username[0].toUpperCase() : '?',
            style: TextStyle(fontSize: 40.sp, color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          _currentUser!.displayName,
          style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        SizedBox(height: 4.h),
        Text('用户名: ${_currentUser!.username}', style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary)),
        SizedBox(height: 4.h),
        if (_currentUser!.bio != null && _currentUser!.bio!.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            child: Text('简介: ${_currentUser!.bio}', textAlign: TextAlign.center, style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary, height: 1.5)),
          ),
      ],
    );
  }

  Widget _buildOptionsList(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: AppColors.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      color: AppColors.cardBackground,
      child: Column(
        children: [
          _buildOptionItem(Icons.edit_outlined, '编辑资料', _navigateToEditProfile),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildOptionItem(Icons.shield_outlined, '账号与安全', () {
            if (_currentUser != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AccountSecurityPage(user: _currentUser!)),
              );
            }
          }),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildOptionItem(Icons.history_outlined, '我的上传', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyUploadsPage()),
            );
          }),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildOptionItem(Icons.info_outline, '关于我们', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutUsPage()));
          }),
        ],
      ),
    );
  }

  Widget _buildOptionItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}
