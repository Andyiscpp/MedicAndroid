// lib/pages/home_page.dart

import 'dart:async';

import 'package:demo_conut/map/map_page.dart';
import 'package:demo_conut/data/models/medicinal_data.dart';
import 'package:demo_conut/data/models/user.dart';
import 'package:demo_conut/pages/all_uploads_page.dart';
import 'package:demo_conut/pages/login_page.dart';
import 'package:demo_conut/pages/medicinal_material_detail_page.dart';
import 'package:demo_conut/pages/medicinal_materials_overview_page.dart' as overview;
import 'package:demo_conut/pages/profile_page.dart';
import 'package:demo_conut/pages/upload_data_page.dart';
import 'package:demo_conut/pages/upload_detail_page_v2.dart';
import 'package:demo_conut/services/medicinal_data_service.dart';
import 'package:demo_conut/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_conut/pages/help_center_page.dart';

class AppColors {
  static const Color background = Color(0xFFF5F5F5);
  static const Color primary = Color(0xFF4A6741);
  static const Color primaryLight = Color(0xFFE8F5E9);
  static const Color accent = Color(0xFFD4AF37);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color cardBackground = Colors.white;
}

class NavigationItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  NavigationItem({required this.title, required this.icon, required this.onTap});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  late final List<NavigationItem> navigationItems;
  final UserService _userService = UserService();
  final MedicinalDataService _medicinalDataService = MedicinalDataService();
  User? _currentUser;

  late PageController _pageController;
  late final List<overview.Herb> _carouselHerbs;
  int _currentPage = 0;
  Timer? _timer;

  late Future<List<MedicinalData>> _recentUploadsFuture;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _currentPage,
      viewportFraction: 0.85,
    );
    _recentUploadsFuture = _medicinalDataService.getAllData();
    _carouselHerbs = const overview.MedicinalMaterialsOverviewPage().herbs.take(5).toList();

    navigationItems = [
      NavigationItem(
          title: '药材总览',
          icon: Icons.grass_outlined,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const overview.MedicinalMaterialsOverviewPage()),
            );
          }),
      NavigationItem(
          title: '上传数据',
          icon: Icons.cloud_upload_outlined,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UploadDataPage()),
            ).then((result) {
              if (result == true) {
                setState(() {
                  _recentUploadsFuture = _medicinalDataService.getAllData();
                });
              }
            });
          }),
      NavigationItem(
          title: '查看所有',
          icon: Icons.grid_view_outlined,
          onTap: () async {
            final allData = await _medicinalDataService.getAllData();
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllUploadsPage(title: '所有上传记录', uploads: allData),
                ),
              );
            }
          }),
      NavigationItem(title: '使用帮助',
          icon: Icons.help_outline,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HelpCenterPage()),
            );
          }
      ),
    ];
    _loadCurrentUser();

    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients && _carouselHerbs.isNotEmpty) {
        if (_currentPage < _carouselHerbs.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });

    _pageController.addListener(() {
      if (_pageController.page != null) {
        setState(() {
          _currentPage = _pageController.page!.round() % _carouselHerbs.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _loadCurrentUser() async {
    final user = await _userService.getLoggedInUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  void _logout() async {
    await _userService.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '中医药材数据系统',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                ).then((_) => _loadCurrentUser());
              } else if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Text('个人信息'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Text('退出登录'),
                  ],
                ),
              ),
            ],
            child: Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: CircleAvatar(
                radius: 18.r,
                backgroundColor: AppColors.primaryLight,
                child: _currentUser != null
                    ? Text(
                  _currentUser!.userName.isNotEmpty ? _currentUser!.userName.substring(0, 1).toUpperCase() : '?',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                )
                    : const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              _buildSectionTitle('核心功能', Icons.widgets_outlined),
              SizedBox(height: 16.h),
              _buildNavigationGrid(),
              SizedBox(height: 24.h),
              _buildSectionTitle('药材地理分布', Icons.map_outlined),
              SizedBox(height: 16.h),
              _buildMapSection(),
              SizedBox(height: 24.h),
              _buildSectionTitle('本草拾遗', Icons.local_florist_outlined),
              SizedBox(height: 16.h),
              _buildHerbCarousel(),
              SizedBox(height: 8.h),
              _buildCarouselIndicator(),
              SizedBox(height: 24.h),
              _buildSectionTitle('最新上传记录', Icons.history_outlined),
              SizedBox(height: 16.h),
              _buildRecentUploadsList(),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22.sp),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildNavigationGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: navigationItems.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 1.5,
      ),
      itemBuilder: (context, index) {
        final item = navigationItems.elementAt(index);
        return Card(
          color: AppColors.cardBackground,
          elevation: 2,
          shadowColor: AppColors.primary.withOpacity(0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          child: InkWell(
            onTap: item.onTap,
            borderRadius: BorderRadius.circular(12.r),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 22.r,
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(item.icon, size: 24.r, color: AppColors.primary),
                ),
                SizedBox(height: 12.h),
                Text(
                  item.title,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.sp, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMapSection() {
    return Card(
      elevation: 2,
      shadowColor: AppColors.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MapPage()),
          );
        },
        child: Container(
          height: 160.h,
          decoration: const BoxDecoration(
            image: DecorationImage(
              // ✅ 修正点: 替换为一个不会被禁止访问的占位图URL
              image: NetworkImage("https://picsum.photos/seed/map_preview/600/400"),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken),
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fullscreen, color: Colors.white, size: 40.r),
                SizedBox(height: 8.h),
                Text(
                  '查看药材分布大图',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHerbCarousel() {
    return SizedBox(
      height: 220.h,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _carouselHerbs.length,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final herb = _carouselHerbs.elementAt(index);
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double value = 1.0;
              if (_pageController.position.haveDimensions) {
                value = (_pageController.page! - index).abs();
                value = (1 - (value * 0.15)).clamp(0.85, 1.0);
              }
              return Center(
                child: SizedBox(
                  height: Curves.easeOut.transform(value) * 220.h,
                  width: Curves.easeOut.transform(value) * 300.w,
                  child: child,
                ),
              );
            },
            child: _buildHerbCard(herb),
          );
        },
      ),
    );
  }

  Widget _buildHerbCard(overview.Herb herb) {
    return Card(
      elevation: 4,
      shadowColor: AppColors.primary.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MedicinalMaterialDetailPage(
                  herbs: const overview.MedicinalMaterialsOverviewPage().herbs,
                  initialIndex: const overview.MedicinalMaterialsOverviewPage().herbs.indexOf(herb),
                )),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(herb.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      herb.name,
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      herb.description,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _carouselHerbs.asMap().entries.map((entry) {
        int index = entry.key;
        return Container(
          width: 8.0.w,
          height: 8.0.h,
          margin: EdgeInsets.symmetric(horizontal: 4.0.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (_currentPage % _carouselHerbs.length) == index ? AppColors.primary : Colors.grey.withOpacity(0.5),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentUploadsList() {
    return FutureBuilder<List<MedicinalData>>(
      future: _recentUploadsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (snapshot.hasError) {
          return Center(child: Text('加载失败: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Card(
            color: AppColors.cardBackground,
            elevation: 2,
            shadowColor: AppColors.primary.withOpacity(0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            child: const ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryLight,
                child: Icon(Icons.info_outline, color: AppColors.primary),
              ),
              title: Text('暂无上传记录', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('点击核心功能区的"上传数据"开始吧！'),
            ),
          );
        }

        final allData = snapshot.data!;
        allData.sort((a, b) => (b.herb.id ?? 0).compareTo(a.herb.id ?? 0));
        final recentUploads = allData.take(3).toList();

        return Card(
          color: AppColors.cardBackground,
          elevation: 2,
          shadowColor: AppColors.primary.withOpacity(0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          child: Column(
            children: recentUploads.map((item) {
              final primaryImage = item.images.isNotEmpty ? item.images.firstWhere((img) => img.isPrimary == 1, orElse: () => item.images.first) : null;
              final locationText = item.locations.isNotEmpty ? "${item.locations.first.province} ${item.locations.first.city}" : "未知地点";

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: primaryImage != null ? NetworkImage(primaryImage.url) : null,
                  onBackgroundImageError: (exception, stackTrace) {},
                  child: primaryImage == null
                      ? const Icon(Icons.image_not_supported)
                      : null,
                ),
                title: Text(item.herb.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('产地: $locationText'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UploadDetailPageV2(data: item),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
