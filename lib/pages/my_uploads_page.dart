// lib/pages/my_uploads_page.dart

import 'package:demo_conut/data/models/user.dart';
import 'package:demo_conut/services/medicinal_data_service.dart';
import 'package:demo_conut/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_conut/data/models/medicinal_data.dart';
import 'package:demo_conut/pages/home_page.dart'; // For AppColors
import 'package:demo_conut/pages/upload_detail_page_v2.dart';

class MyUploadsPage extends StatefulWidget {
  const MyUploadsPage({super.key});

  @override
  State<MyUploadsPage> createState() => _MyUploadsPageState();
}

class _MyUploadsPageState extends State<MyUploadsPage> {
  late Future<List<MedicinalData>> _myUploadsFuture;
  final MedicinalDataService _dataService = MedicinalDataService();
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    // 页面初始化时，调用方法获取“我的”上传记录
    _myUploadsFuture = _fetchMyUploads();
  }

  /// 异步方法：获取并筛选出当前用户的上传记录
  Future<List<MedicinalData>> _fetchMyUploads() async {
    // 1. 获取当前登录的用户信息
    final User? currentUser = await _userService.getLoggedInUser();
    if (currentUser?.nickname == null) {
      // 如果获取不到用户或昵称，返回空列表
      return [];
    }

    // 2. 获取所有的上传记录
    final List<MedicinalData> allUploads = await _dataService.getAllUploadsData();

    // 3. 根据当前用户的昵称进行筛选
    final List<MedicinalData> myUploads = allUploads
        .where((data) => data.herb.uploaderName == currentUser?.nickname)
        .toList();

    return myUploads;
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
          '我的上传',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<MedicinalData>>(
        future: _myUploadsFuture,
        builder: (context, snapshot) {
          // 正在加载
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          // 加载出错
          if (snapshot.hasError) {
            return Center(child: Text('加载失败: ${snapshot.error}'));
          }

          // 数据为空或没有数据
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final myUploads = snapshot.data!;
          myUploads.sort((a, b) => (b.herb.id ?? 0).compareTo(a.herb.id ?? 0));

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            itemCount: myUploads.length,
            itemBuilder: (context, index) {
              final data = myUploads[index];
              return _buildUploadCard(context, data);
            },
          );
        },
      ),
    );
  }

  // --- 以下UI构建代码与 all_uploads_page.dart 保持一致，确保风格统一 ---

  Widget _buildUploadCard(BuildContext context, MedicinalData data) {
    final herbName = data.herb.name;
    final primaryImage = data.images.isNotEmpty ? data.images.firstWhere((img) => img.isPrimary == 1, orElse: () => data.images.first) : null;
    final location = data.locations.isNotEmpty ? data.locations.first : null;
    final locationText = location != null ? "${location.province} ${location.city}" : "未知地点";
    final uploaderName = data.herb.uploaderName ?? '匿名用户';

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shadowColor: AppColors.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UploadDetailPageV2(data: data),
            ),
          );
        },
        child: Row(
          children: [
            SizedBox(
              width: 100.w,
              height: 100.h,
              child: primaryImage != null
                  ? Image.network(
                primaryImage.url,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                },
                errorBuilder: (ctx, err, stack) => const Icon(Icons.grass, color: Colors.grey, size: 40),
              )
                  : const Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 40),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      herbName,
                      style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    _buildInfoChip(Icons.location_on_outlined, locationText),
                    SizedBox(height: 6.h),
                    _buildInfoChip(Icons.person_outline, uploaderName),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: AppColors.textSecondary),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80.sp, color: Colors.grey.shade400),
          SizedBox(height: 16.h),
          Text(
            '您还没有上传过任何记录',
            style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}