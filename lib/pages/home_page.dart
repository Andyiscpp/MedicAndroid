// lib/pages/home_page.dart

import 'dart:async';

import 'package:demo_conut/map/map_page.dart';
import 'package:demo_conut/data/models/medicinal_data.dart';
import 'package:demo_conut/data/models/user.dart';
import 'package:demo_conut/pages/all_uploads_page.dart';
import 'package:demo_conut/pages/medicinal_material_detail_page.dart';
import 'package:demo_conut/pages/medicinal_materials_overview_page.dart' as overview;
import 'package:demo_conut/pages/upload_data_page.dart';
import 'package:demo_conut/pages/upload_detail_page_v2.dart';
import 'package:demo_conut/services/medicinal_data_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_conut/pages/help_center_page.dart';
import 'package:oktoast/oktoast.dart';

// AppColors 和 NavigationItem 类的定义保持不变
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
  // 1. 添加新的参数，用于接收来自 MainPage 的数据和回调
  final Future<List<MedicinalData>> allUploadsFuture;
  final Future<void> Function() onRefresh;

  const HomePage({
    super.key,
    required this.allUploadsFuture,
    required this.onRefresh,
  });

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  // 2. 移除 HomePage 自己的数据服务和 Future
  // final MedicinalDataService _medicinalDataService = MedicinalDataService();
  // late Future<List<MedicinalData>> _allUploadsFuture;
  late PageController _pageController;
  late final List<overview.Herb> _carouselHerbs;
  int _currentPage = 0;
  Timer? _timer;
  late final List<overview.Herb> _overviewHerbs;
  late final List<NavigationItem> _coreFunctionItems;


  @override
  void initState() {
    super.initState();
    // 3. 不再需要在这里初始化数据
    // _allUploadsFuture = _medicinalDataService.getAllUploadsData();
    _pageController = PageController(initialPage: 0, viewportFraction: 0.85);
    const overviewPage = overview.MedicinalMaterialsOverviewPage();
    _carouselHerbs = overviewPage.herbs.take(5).toList();
    _startCarouselTimer();
    _overviewHerbs = overviewPage.herbs;
  }

  void _startCarouselTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients && _carouselHerbs.isNotEmpty) {
        int nextPage = (_pageController.page?.round() ?? 0) + 1;
        if (nextPage >= _carouselHerbs.length) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
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

  @override
  Widget build(BuildContext context) {
    // 4. 将主内容包裹在 RefreshIndicator 中
    return RefreshIndicator(
      onRefresh: widget.onRefresh, // 5. 使用从 MainPage 传递过来的刷新函数
      child: Container(
        color: AppColors.background,
        child: SingleChildScrollView(
          // 6. 确保 SingleChildScrollView 可以被下拉
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionWrapper(child: _buildHerbCarouselSection()),
                _buildSectionWrapper(child: _buildRecentUploadsSection()),
                _buildSectionWrapper(child: _buildMedicinalOverviewSection()),
                _buildSectionWrapper(child: _buildMapSection()),
                _buildSectionWrapper(child: _buildSharedUploadsSection()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Wrapper for consistent padding ---
  Widget _buildSectionWrapper({required Widget child}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, {bool isSeeMore = false, VoidCallback? onSeeMoreTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22.sp),
            SizedBox(width: 8.w),
            Text(title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ],
        ),
        if (isSeeMore)
          TextButton(
            onPressed: onSeeMoreTap,
            child: const Text('查看更多 >', style: TextStyle(color: AppColors.textSecondary)),
          ),
      ],
    );
  }

  Widget _buildHerbCarouselSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('本草拾遗', Icons.local_florist_outlined),
        SizedBox(height: 16.h),
        SizedBox(
          height: 220.h,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _carouselHerbs.length,
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
                  return Center(child: SizedBox(height: Curves.easeOut.transform(value) * 220.h, width: Curves.easeOut.transform(value) * 300.w, child: child));
                },
                child: _buildHerbCard(herb, isCarousel: true),
              );
            },
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _carouselHerbs.asMap().entries.map((entry) {
            return Container(
              width: 8.0.w,
              height: 8.0.h,
              margin: EdgeInsets.symmetric(horizontal: 4.0.w),
              decoration: BoxDecoration(shape: BoxShape.circle, color: (_currentPage % _carouselHerbs.length) == entry.key ? AppColors.primary : Colors.grey.withOpacity(0.5)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentUploadsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('最新上传记录', Icons.history_outlined),
        SizedBox(height: 16.h),
        // 7. 将 FutureBuilder 的 future 指向 widget.allUploadsFuture
        FutureBuilder<List<MedicinalData>>(
          future: widget.allUploadsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return const Card(child: ListTile(title: Text('暂无上传记录')));
            }
            // 根据 ID 降序排序，确保最新上传的在最前面
            final sortedData = snapshot.data!;
            sortedData.sort((a, b) {
              final idA = a.locations.isNotEmpty ? a.locations.first.id ?? 0 : 0;
              final idB = b.locations.isNotEmpty ? b.locations.first.id ?? 0 : 0;
              return idB.compareTo(idA);
            });
            final recentUploads = sortedData.take(3).toList();
            return Card(
              elevation: 2, shadowColor: AppColors.primary.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              child: Column(
                children: recentUploads.map((item) {
                  final primaryImage = item.images.isNotEmpty ? item.images.firstWhere((img) => img.isPrimary == 1, orElse: () => item.images.first) : null;
                  return ListTile(
                    leading: CircleAvatar(backgroundImage: primaryImage != null ? NetworkImage(primaryImage.url) : null, child: primaryImage == null ? const Icon(Icons.image) : null),
                    title: Text(item.herb.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('产地: ${item.locations.first.province} ${item.locations.first.city}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => UploadDetailPageV2(data: item))),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMedicinalOverviewSection() {
    final previewHerbs = _overviewHerbs.take(8).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('药材总览', Icons.grass_outlined, isSeeMore: true, onSeeMoreTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const overview.MedicinalMaterialsOverviewPage()));
        }),
        SizedBox(height: 16.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: previewHerbs.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16.w, mainAxisSpacing: 16.h, childAspectRatio: 0.8),
          itemBuilder: (context, index) => _buildHerbCard(previewHerbs[index], isCarousel: false),
        ),
      ],
    );
  }

  Widget _buildMapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('药材地理分布', Icons.map_outlined),
        SizedBox(height: 16.h),
        Card(
          elevation: 2, shadowColor: AppColors.primary.withOpacity(0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MapPage())),
            child: Container(
              height: 160.h,
              decoration: const BoxDecoration(image: DecorationImage(image: NetworkImage("https://picsum.photos/seed/map_preview/600/400"), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken))),
              child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.fullscreen, color: Colors.white, size: 40.r), SizedBox(height: 8.h), Text('查看药材分布大图', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold))])),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSharedUploadsSection() {
    final MedicinalDataService _medicinalDataService = MedicinalDataService();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('上传共享', Icons.people_alt_outlined, isSeeMore: true, onSeeMoreTap: () async {
          showToast('正在查询所有记录...');
          if (mounted) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AllUploadsPage(title: '所有上传记录')));
          }
        }),
        SizedBox(height: 16.h),
        FutureBuilder<List<MedicinalData>>(
          future: widget.allUploadsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(height: 180.h, child: const Center(child: CircularProgressIndicator()));
            }
            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return SizedBox(height: 180.h, child: const Center(child: Text('暂无共享内容')));
            }
            final allUploads = snapshot.data!;
            allUploads.sort((a, b) {
              final idA = a.locations.isNotEmpty ? a.locations.first.id ?? 0 : 0;
              final idB = b.locations.isNotEmpty ? b.locations.first.id ?? 0 : 0;
              return idB.compareTo(idA);
            });
            final itemCount = allUploads.length + 1;

            return SizedBox(
              height: 180.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  if (index == allUploads.length) {
                    return _buildSeeAllCard();
                  }
                  final item = allUploads[index];
                  return _buildSharedUploadCard(item);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSharedUploadCard(MedicinalData data) {
    //... remains same
    final primaryImage = data.images.isNotEmpty ? data.images.firstWhere((img) => img.isPrimary == 1, orElse: () => data.images.first) : null;
    return Container(
      width: 150.w,
      margin: EdgeInsets.only(right: 12.w),
      child: Card(
        elevation: 2, shadowColor: AppColors.primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => UploadDetailPageV2(data: data))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  color: Colors.white,
                  child: primaryImage != null
                      ? Image.network(primaryImage.url, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.image_not_supported, color: Colors.grey))
                      : const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data.herb.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
                      SizedBox(height: 4.h),
                      Text(data.herb.uploaderName ?? '匿名用户', style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeeAllCard() {
    final MedicinalDataService _medicinalDataService = MedicinalDataService();
    return Container(
      width: 150.w,
      margin: EdgeInsets.only(right: 12.w),
      child: InkWell(
        onTap: () async {
          showToast('正在查询所有记录...');
          if (mounted) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AllUploadsPage(title: '所有上传记录')));
          }
        },
        child: Card(
          elevation: 2, shadowColor: AppColors.primary.withOpacity(0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_forward, color: AppColors.primary, size: 30.sp),
                SizedBox(height: 8.h),
                Text('了解更多', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14.sp)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHerbCard(overview.Herb herb, {required bool isCarousel}) {
    // ... remains same
    final cardContent = isCarousel
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(flex: 3, child: Container(decoration: BoxDecoration(image: DecorationImage(image: AssetImage(herb.imagePath), fit: BoxFit.cover)))),
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(herb.name, style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                SizedBox(height: 6.h),
                Text(herb.description, style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
      ],
    )
        : Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: Container(color: Colors.white, padding: const EdgeInsets.all(8.0), child: Image.asset(herb.imagePath, fit: BoxFit.contain, errorBuilder: (c,e,s) => const Icon(Icons.grass, color: Colors.grey, size: 40)))),
        Container(
          height: 60.h,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(herb.name, textAlign: TextAlign.center, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              SizedBox(height: 4.h),
              Text(herb.description, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );

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
                  herbs: _overviewHerbs,
                  initialIndex: _overviewHerbs.indexOf(herb),
                )),
          );
        },
        child: cardContent,
      ),
    );
  }
}