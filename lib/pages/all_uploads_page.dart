// lib/pages/all_uploads_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_conut/data/models/medicinal_data.dart';
import 'package:demo_conut/pages/home_page.dart'; // For AppColors
import 'package:demo_conut/pages/upload_detail_page_v2.dart';

class AllUploadsPage extends StatelessWidget {
  final String title;
  final List<MedicinalData> uploads;

  const AllUploadsPage({super.key, required this.title, required this.uploads});

  @override
  Widget build(BuildContext context) {
    uploads.sort((a, b) => (b.herb.id ?? 0).compareTo(a.herb.id ?? 0));

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
          title,
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: uploads.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        itemCount: uploads.length,
        itemBuilder: (context, index) {
          final data = uploads[index];
          return _buildUploadCard(context, data);
        },
      ),
    );
  }

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
              // ✅ 修改点: 从 Image.file 改为 Image.network
              child: primaryImage != null
                  ? Image.network( // <-- 使用 Image.network
                primaryImage.url,
                fit: BoxFit.cover,
                // 网络图片加载时的占位符
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                },
                // 网络图片加载失败时的后备显示
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
                    _buildInfoChip(Icons.person_outline, uploaderName), // 显示上传者
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
            '还没有任何上传记录',
            style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
