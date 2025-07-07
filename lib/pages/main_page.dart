// lib/pages/main_page.dart

import 'package:demo_conut/data/models/medicinal_data.dart';
import 'package:demo_conut/data/models/user.dart';
import 'package:demo_conut/pages/home_page.dart';
import 'package:demo_conut/pages/login_page.dart';
import 'package:demo_conut/pages/profile_page.dart';
import 'package:demo_conut/pages/upload_data_page.dart';
import 'package:demo_conut/services/medicinal_data_service.dart';
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

  // 1. 将数据获取服务和数据Future移到此处
  final MedicinalDataService _medicinalDataService = MedicinalDataService();
  late Future<List<MedicinalData>> _allUploadsFuture;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    // 2. 页面初始化时获取数据
    _refreshData();
  }

  // 3. 创建一个集中的数据刷新方法
  Future<void> _refreshData() async {
    if (mounted) {
      setState(() {
        _allUploadsFuture = _medicinalDataService.getAllUploadsData();
      });
      // 等待新的 Future 完成，以便 RefreshIndicator 显示加载动画
      await _allUploadsFuture;
    }
  }

  // 4. 创建上传成功后的回调方法
  void _onUploadSuccess() {
    // 切换到首页
    _onItemTapped(0);
    // 刷新数据
    _refreshData();
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

  AppBar _buildAppBar() {
    String title = '中医药材数据系统';
    List<Widget> actions = [];

    switch (_selectedIndex) {
      case 0:
        title = '中医药材数据系统';
        actions = [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
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
      case 1:
        title = '上传药材数据';
        break;
      case 2:
        title = '个人中心';
        break;
    }

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      actions: actions,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 5. 在 build 方法中构建页面列表，确保每次都能传递最新的状态
    final List<Widget> pages = [
      HomePage(
        allUploadsFuture: _allUploadsFuture,
        onRefresh: _refreshData, // 传递刷新回调
      ),
      UploadDataPage(
        onUploadSuccess: _onUploadSuccess, // 传递上传成功回调
      ),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _selectedIndex,
        children: pages, // 使用这里构建的 pages
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
        backgroundColor: AppColors.cardBackground,
      ),
    );
  }
}