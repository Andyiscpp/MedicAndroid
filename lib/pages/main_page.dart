// lib/pages/main_page.dart

import 'package:demo_conut/data/models/user.dart';
import 'package:demo_conut/pages/home_page.dart';
import 'package:demo_conut/pages/login_page.dart';
import 'package:demo_conut/pages/profile_page.dart';
import 'package:demo_conut/pages/upload_data_page.dart';
import 'package:demo_conut/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final UserService _userService = UserService();
  User? _currentUser;

  // 页面列表，现在它们不应该包含Scaffold
  final List<Widget> _pages = [
    const HomePage(),
    const UploadDataPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await _userService.fetchAndSaveUserProfile();
    if (mounted) {
      setState(() => _currentUser = user);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() async {
    await _userService.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
    );
  }

  // 根据当前选中的索引，返回对应的AppBar
  AppBar _buildAppBar() {
    // 默认标题
    String title = '中医药材数据系统';
    List<Widget> actions = [];

    // 根据不同的页面设置不同的标题和actions
    switch (_selectedIndex) {
      case 0: // 首页
        title = '中医药材数据系统';
        actions = [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                // 跳转到个人信息页，通过切换tab实现
                _onItemTapped(2);
              } else if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(value: 'profile', child: Row(children: [Icon(Icons.person_outline), SizedBox(width: 8), Text('个人信息')])),
              const PopupMenuItem<String>(value: 'logout', child: Row(children: [Icon(Icons.logout), SizedBox(width: 8), Text('退出登录')])),
            ],
            child: Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: CircleAvatar(
                radius: 18.r,
                backgroundColor: AppColors.primaryLight,
                backgroundImage: (_currentUser?.avatarUrl != null && _currentUser!.avatarUrl!.isNotEmpty) ? NetworkImage(_currentUser!.avatarUrl!) : null,
                child: (_currentUser == null || (_currentUser!.avatarUrl != null && _currentUser!.avatarUrl!.isNotEmpty))
                    ? null
                    : Text(_currentUser!.username.isNotEmpty ? _currentUser!.username[0].toUpperCase() : '?', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ];
        break;
      case 1: // 上传页面
        title = '上传药材数据';
        break;
      case 2: // 我的页面
        title = '个人中心';
        break;
    }

    return AppBar(
      automaticallyImplyLeading: false, // 移除所有页面的返回按钮
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      actions: actions,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(), // 使用统一管理的AppBar
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.cloud_upload_outlined), activeIcon: Icon(Icons.cloud_upload), label: '上传'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: '我的'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}