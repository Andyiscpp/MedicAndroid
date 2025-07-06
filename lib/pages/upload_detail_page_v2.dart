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
            _buildInfoRow("上传者", data.herb.uploaderName ?? '匿名用户'),
            // 依据新接口，其他详细信息可能为空，可以根据需要决定是否显示
            if (data.herb.scientificName.isNotEmpty)
              _buildInfoRow("学名", data.herb.scientificName),
            if (data.herb.description.isNotEmpty)
              _buildInfoRow("描述", data.herb.description, isLongText: true),


            SizedBox(height: 16.h),
            _buildSectionTitle("地理位置"),
            // 地理位置信息现在只有一个
            if (data.locations.isNotEmpty)
              Card(
                margin: EdgeInsets.only(bottom: 10.h),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      _buildInfoRow("地址", "${data.locations.first.province} ${data.locations.first.city} ${data.locations.first.address}"),
                      _buildInfoRow("经纬度", "${data.locations.first.longitude}, ${data.locations.first.latitude}"),
                      _buildInfoRow("观测年份", data.locations.first.observationYear.toString()),
                    ],
                  ),
                ),
              ),

            // ✅ *** 核心修复点 ***
            // 在显示“生长数据”标题之前，检查 data.growthData 是否有内容
            if (data.growthData.isNotEmpty) ...[
              SizedBox(height: 16.h),
              _buildSectionTitle("生长数据"),
              // 使用 map 正确遍历 growthData 列表
              ...data.growthData.map((growth) => Card(
                margin: EdgeInsets.only(bottom: 10.h),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      _buildInfoRow("指标", growth.metricName),
                      _buildInfoRow("数值", "${growth.metricValue} ${growth.metricUnit}"),
                      // 检查 recordedAt 是否是一个有效日期
                      _buildInfoRow("记录时间", DateFormat('yyyy-MM-dd').format(growth.recordedAt)),
                    ],
                  ),
                ),
              )),
            ],

            SizedBox(height: 16.h),
            _buildSectionTitle("图片信息"),
            // 图片信息也只有一个
            if (data.images.isNotEmpty)
              ...data.images.map((img) => Card(
                margin: EdgeInsets.only(bottom: 10.h),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Image.network(
                        img.url,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                              height: 150,
                              alignment: Alignment.center,
                              child: const CircularProgressIndicator(strokeWidth: 2)
                          );
                        },
                        errorBuilder: (c,e,s) => const Icon(Icons.error, size: 40, color: Colors.red),
                      ),
                      // 新接口中没有图片描述，可以不显示或显示默认值
                      // if (img.description.isNotEmpty) ...[
                      //   SizedBox(height: 8.h),
                      //   Text(img.description),
                      // ],
                      if(img.isPrimary == 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: const Chip(label: Text('主图'), backgroundColor: AppColors.primaryLight),
                        ),
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