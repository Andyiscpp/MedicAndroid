// lib/pages/profile_page.dart

import 'dart:io';
import 'package:demo_conut/data/models/user.dart';
import 'package:demo_conut/pages/about_us_page.dart';
import 'package:demo_conut/pages/account_security_page.dart';
import 'package:demo_conut/pages/edit_profile_page.dart';
import 'package:demo_conut/pages/my_uploads_page.dart';
import 'package:demo_conut/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/widgets.dart';
import 'package:demo_conut/pages/home_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui'; // Needed for ImageFilter

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
      print("--- [DEBUG] Calling image_picker...");
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      print("--- [DEBUG] image_picker call finished.");

      if (pickedFile != null) {
        print("--- [DEBUG] Image picked successfully: ${pickedFile.path}");
        setState(() {
          _backgroundImagePath = pickedFile.path;
        });
        await _saveBackgroundImage(pickedFile.path);
      } else {
        print("--- [DEBUG] User cancelled image picking.");
      }
    } on PlatformException catch (e) {
      print("--- [ERROR] PlatformException (likely permissions): ${e.code} - ${e.message}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to access gallery, please check permissions: ${e.message}')),
      );
    } catch (e) {
      print("--- [ERROR] An unknown error occurred while picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unknown error occurred: $e')),
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
            ? Center(child: TextButton(onPressed: _loadCurrentUser, child: const Text('Failed to load, tap to retry')))
            : Stack(
          children: [
            // ✅ 核心修正：调整了Stack内子控件的顺序
            // 1. 先绘制可滚动的主体内容
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    SizedBox(height: 140.h),
                    _buildProfileHeader(),
                    SizedBox(height: 20.h),
                    _buildOptionsList(context),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
            // 2. 再绘制顶部的 Header，确保它在最上层，这样按钮就可以被点击
            _buildWavyHeader(),
          ],
        ),
      ),
    );
  }

  Widget _buildWavyHeader() {
    ImageProvider backgroundImage;
    if (_backgroundImagePath != null && File(_backgroundImagePath!).existsSync()) {
      backgroundImage = FileImage(File(_backgroundImagePath!));
    } else {
      backgroundImage = const NetworkImage("https://picsum.photos/seed/profile_bg/800/600");
    }

    return Stack(
      children: [
        ClipPath(
          clipper: WaveClipper(),
          child: Container(
            height: 180.h,
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
          ),
        ),
        Positioned(
          top: 40.h,
          right: 15.w,
          child: IconButton(
            icon: const Icon(Icons.camera_alt_outlined, color: Colors.white70),
            tooltip: 'Change background image',
            onPressed: _pickBackgroundImage,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    final hasAvatar = _currentUser?.avatarUrl != null && _currentUser!.avatarUrl!.isNotEmpty;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 52.r,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 49.r,
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
        SizedBox(height: 12.h),
        Text(
          _currentUser!.displayName,
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        SizedBox(height: 6.h),
        Text(
          '用户名: ${_currentUser!.username}',
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
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

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30.0);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width - (size.width / 3.25), size.height - 65);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
