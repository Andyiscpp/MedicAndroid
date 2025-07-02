import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_conut/pages/home_page.dart'; // 导入以使用AppColors
import 'package:demo_conut/pages/medicinal_materials_overview_page.dart'; // 导入以使用Herb模型

/// 药材详情页面
class MedicinalMaterialDetailPage extends StatefulWidget {
  final List<Herb> herbs;
  final int initialIndex;

  const MedicinalMaterialDetailPage({
    super.key,
    required this.herbs,
    required this.initialIndex,
  });

  @override
  State<MedicinalMaterialDetailPage> createState() => _MedicinalMaterialDetailPageState();
}

class _MedicinalMaterialDetailPageState extends State<MedicinalMaterialDetailPage> {
  late int currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // 跳转到下一个药材
  void _goToNext() {
    if (currentIndex < widget.herbs.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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
        title: Text(
          widget.herbs[currentIndex].name, // 标题显示当前药材名
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.herbs.length,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return _buildHerbDetailPage(widget.herbs[index]);
        },
      ),
      // 底部导航按钮
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // 构建详情页主体内容
  Widget _buildHerbDetailPage(Herb herb) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderCard(herb),
          SizedBox(height: 16.h),
          _buildInfoCard('来源', herb.source, '古代事例', herb.ancientExamples),
          SizedBox(height: 16.h),
          _buildInfoCard('用法用量', herb.usageAndDosage, '症状主治', herb.medicalExamples),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  // 构建顶部包含图片、名称和简述的卡片
  Widget _buildHeaderCard(Herb herb) {
    return Card(
      elevation: 2,
      shadowColor: AppColors.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.only(top: 16.h, bottom: 16.h),
        child: Column(
          children: [
            SizedBox(
              width: 120.w, // 控制圆形图片的直径
              height: 120.w,
              child: ClipOval(
                child: Image.asset(
                  herb.imagePath,
                  fit: BoxFit.cover, // 确保图片填充整个圆形区域，可能会裁剪部分内容
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.grass, color: Colors.grey, size: 60);
                  },
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  Text(
                    herb.name,
                    style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    herb.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15.sp, color: AppColors.textSecondary, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建信息展示卡片
  Widget _buildInfoCard(String title1, String content1, String title2, String content2) {
    return Card(
      elevation: 2,
      shadowColor: AppColors.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(title1, content1),
            const Divider(height: 24, thickness: 1),
            _buildInfoRow(title2, content2),
          ],
        ),
      ),
    );
  }

  // 构建信息展示行
  Widget _buildInfoRow(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          content,
          style: TextStyle(
            fontSize: 15.sp,
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  // 构建底部导航栏
  Widget _buildBottomNavBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            label: const Text('返回', style: TextStyle(color: AppColors.textPrimary)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton.icon(
            icon: Text('下一个', style: TextStyle(color: currentIndex < widget.herbs.length - 1 ? AppColors.primary : Colors.grey)),
            label: Icon(Icons.arrow_forward, color: currentIndex < widget.herbs.length - 1 ? AppColors.primary : Colors.grey),
            onPressed: currentIndex < widget.herbs.length - 1 ? _goToNext : null,
          ),
        ],
      ),
    );
  }
}