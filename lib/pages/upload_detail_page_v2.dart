// lib/pages/upload_detail_page_v2.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:demo_conut/data/models/medicinal_data.dart';
import 'package:demo_conut/pages/home_page.dart';

class UploadDetailPageV2 extends StatelessWidget {
  final MedicinalData data;

  const UploadDetailPageV2({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(data.herb.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("基本信息"),
            _buildInfoRow("药材名称", data.herb.name),
            _buildInfoRow("学名", data.herb.scientificName),
            _buildInfoRow("描述", data.herb.description, isLongText: true),
            _buildInfoRow("上传者", data.herb.uploaderName ?? '匿名用户'),

            SizedBox(height: 16.h),
            _buildSectionTitle("地理位置"),
            ...data.locations.map((loc) => Card(
              margin: EdgeInsets.only(bottom: 10.h),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    _buildInfoRow("地址", "${loc.province} ${loc.city} ${loc.address}"),
                    _buildInfoRow("经纬度", "${loc.longitude}, ${loc.latitude}"),
                    _buildInfoRow("观测年份", loc.observationYear.toString()),
                  ],
                ),
              ),
            )),

            SizedBox(height: 16.h),
            _buildSectionTitle("生长数据"),
            ...data.growthData.map((growth) => Card(
              margin: EdgeInsets.only(bottom: 10.h),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    _buildInfoRow("指标", growth.metricName),
                    _buildInfoRow("数值", "${growth.metricValue} ${growth.metricUnit}"),
                    _buildInfoRow("记录时间", DateFormat('yyyy-MM-dd').format(growth.recordedAt)),
                  ],
                ),
              ),
            )),

            SizedBox(height: 16.h),
            _buildSectionTitle("图片信息"),
            ...data.images.map((img) => Card(
              margin: EdgeInsets.only(bottom: 10.h),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // ✅ 修改点: 从 Image.file 改为 Image.network
                    Image.network( // <-- 使用 Image.network
                      img.url,
                      // 网络图片加载时的占位符
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                            height: 150, // 给一个固定高度，避免闪烁
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(strokeWidth: 2)
                        );
                      },
                      // 网络图片加载失败时的后备显示
                      errorBuilder: (c,e,s) => const Icon(Icons.error, size: 40, color: Colors.red),
                    ),
                    SizedBox(height: 8.h),
                    Text(img.description),
                    if(img.isPrimary == 1)
                      const Chip(label: Text('主图'), backgroundColor: AppColors.primaryLight),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Text(
        title,
        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.primary),
      ),
    );
  }

  Widget _buildInfoRow(String title, String content, {bool isLongText = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: isLongText ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              '$title:',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              content,
              style: TextStyle(
                fontSize: 15.sp,
                color: AppColors.textSecondary,
                height: isLongText ? 1.5 : 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
