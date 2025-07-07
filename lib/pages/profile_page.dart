// lib/pages/profile_page.dart

import 'dart:io';
import 'dart:ui'; // 引入ImageFilter

import 'package:demo_conut/data/models/user.dart';
import 'package:demo_conut/pages/about_us_page.dart';
import 'package:demo_conut/pages/account_security_page.dart';
import 'package:demo_conut/pages/edit_profile_page.dart';
import 'package:demo_conut/pages/my_uploads_page.dart';
import 'package:demo_conut/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_conut/pages/home_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _userService = UserService();
  User? _currentUser;
  bool _isLoading = true;

  String? _backgroundImagePath;
  static const String _backgroundKey = 'profile_background_image';

  final double _backgroundHeight = 200.h;
  final double _avatarRadius = 52.r;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadBackgroundImage();
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

  Future<void> _loadBackgroundImage() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_backgroundKey)) {
      setState(() {
        _backgroundImagePath = prefs.getString(_backgroundKey);
      });
    }
  }

  Future<void> _saveBackgroundImage(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_backgroundKey, path);
  }

  Future<void> _pickBackgroundImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _backgroundImagePath = pickedFile.path;
        });
        await _saveBackgroundImage(pickedFile.path);
      }
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('权限不足，无法访问相册: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('选择图片时发生未知错误: $e')),
      );
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
    return Container(
      color: AppColors.background,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
        onRefresh: _loadCurrentUser,
        child: _currentUser == null
            ? Center(child: TextButton(onPressed: _loadCurrentUser, child: const Text('加载失败，点击重试')))
            : Stack(
          children: [
            _buildProfileBackground(),
            _buildScrollableContent(),
            _buildFloatingHeader(),
            _buildChangeBackgroundButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          // ✅ *** 核心修改点 1: 再次增加顶部空间的高度 ***
          // 原高度为 _backgroundHeight + _avatarRadius + 40.h
          // 现增加到 60.h 的额外空间给下面的文字，避免重叠
          SizedBox(height: _backgroundHeight + _avatarRadius + 70.h),
          _buildOptionsList(context),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildProfileBackground() {
    ImageProvider backgroundImage;
    if (_backgroundImagePath != null && File(_backgroundImagePath!).existsSync()) {
      backgroundImage = FileImage(File(_backgroundImagePath!));
    } else {
      backgroundImage = const NetworkImage("https://picsum.photos/seed/profile_bg/800/600");
    }

    return Container(
      height: _backgroundHeight,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: backgroundImage,
          fit: BoxFit.cover,
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
        child: Container(
          color: Colors.black.withOpacity(0.2),
        ),
      ),
    );
  }

  Widget _buildFloatingHeader() {
    final hasAvatar = _currentUser?.avatarUrl != null && _currentUser!.avatarUrl!.isNotEmpty;
    // ✅ *** 核心修改点 2: 优化昵称和用户名的显示逻辑 ***
    final bool hasNickname = _currentUser!.nickname != null && _currentUser!.nickname!.isNotEmpty;

    return Positioned(
      top: _backgroundHeight - _avatarRadius,
      left: 0,
      right: 0,
      child: Column(
        children: [
          CircleAvatar(
            radius: _avatarRadius,
            backgroundColor: AppColors.background,
            child: CircleAvatar(
              radius: _avatarRadius - 4.r,
              backgroundImage: hasAvatar ? NetworkImage(_currentUser!.avatarUrl!) : null,
              backgroundColor: AppColors.primaryLight,
              child: hasAvatar
                  ? null
                  : Text(
                _currentUser!.username.isNotEmpty ? _currentUser!.username[0].toUpperCase() : '?',
                style: TextStyle(fontSize: 40.sp, color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          // 如果有昵称，就显示昵称作为主标题
          // 如果没有，就显示用户作为主标题
          Text(
            hasNickname ? _currentUser!.nickname! : _currentUser!.username,
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          SizedBox(height: 4.h),
          // 只有在有昵称的情况下，才额外显示用户名作为副标题
          if (hasNickname)
            Text(
              '用户名: ${_currentUser!.username}',
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
        ],
      ),
    );
  }


  Widget _buildChangeBackgroundButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 5.h,
      right: 15.w,
      child: IconButton(
        icon: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 28),
        tooltip: '更换背景图',
        style: IconButton.styleFrom(
          backgroundColor: Colors.black.withOpacity(0.3),
        ),
        onPressed: _pickBackgroundImage,
      ),
    );
  }


  Widget _buildOptionsList(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
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