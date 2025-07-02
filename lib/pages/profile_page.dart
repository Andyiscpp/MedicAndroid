// lib/pages/profile_page.dart

import 'package:demo_conut/data/models/user.dart';
import 'package:demo_conut/pages/about_us_page.dart';
import 'package:demo_conut/pages/account_security_page.dart';
import 'package:demo_conut/pages/all_uploads_page.dart';
import 'package:demo_conut/pages/edit_profile_page.dart';
import 'package:demo_conut/services/medicinal_data_service.dart';
import 'package:demo_conut/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_conut/pages/home_page.dart'; // 导入以使用AppColors

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _userService = UserService();
  final MedicinalDataService _medicinalDataService = MedicinalDataService();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  // 加载当前登录用户的信息
  Future<void> _loadCurrentUser() async {
    final user = await _userService.getLoggedInUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  // 导航到编辑页面并处理返回结果
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
          '个人信息',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _currentUser == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
        child: Padding(
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

  // 构建个人信息头部的小部件
  Widget _buildProfileHeader() {
    if (_currentUser == null) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        CircleAvatar(
          radius: 50.r,
          backgroundColor: AppColors.primaryLight,
          child: Text(
            _currentUser!.userName.isNotEmpty ? _currentUser!.userName[0].toUpperCase() : '?',
            style: TextStyle(fontSize: 40.sp, color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          _currentUser!.realName,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '邮箱: ${_currentUser!.email}',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 4.h),
        if (_currentUser!.location != null && _currentUser!.location!.isNotEmpty)
          Text(
            '所在地: ${_currentUser!.location}',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }

  // 构建功能选项列表的小部件
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AccountSecurityPage()),
            );
          }),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildOptionItem(Icons.history_outlined, '我的上传', () async {
            // **[MODIFIED]** Filtering logic is implemented here
            if (_currentUser == null) return; // Guard clause

            final allData = await _medicinalDataService.getAllData();

            // Filter the data to get only the current user's uploads
            final myUploads = allData
                .where((data) => data.herb.uploaderName == _currentUser!.realName)
                .toList();

            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllUploadsPage(
                    title: '我的上传',
                    uploads: myUploads, // Pass the filtered list
                  ),
                ),
              );
            }
          }),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildOptionItem(Icons.info_outline, '关于我们', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutUsPage()),
            );
          }),
        ],
      ),
    );
  }

  // 构建单个功能选项
  Widget _buildOptionItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}
