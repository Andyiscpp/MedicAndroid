import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_conut/pages/home_page.dart'; // 导入以使用AppColors

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

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
          '关于我们',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 24.h),
            _buildSectionTitle('我们的使命'),
            SizedBox(height: 8.h),
            _buildSectionContent(
              '致力于打造一个现代化、信息化的中医药数据平台，通过数字化技术，传承和发扬中医药文化，为研究人员、从业者和爱好者提供全面、准确、便捷的数据支持。',
            ),
            SizedBox(height: 20.h),
            _buildSectionTitle('系统功能'),
            SizedBox(height: 8.h),
            _buildFeatureItem(Icons.grass_outlined, '药材信息总览', '提供数千种中药材的详细信息，包括性味、归经、功效、主治等。'),
            _buildFeatureItem(Icons.cloud_upload_outlined, '用户数据上传', '用户可以上传和分享自己的药材数据和研究成果，共建知识库。'),
            _buildFeatureItem(Icons.map_outlined, '地理分布可视化', '通过地图直观展示药材的地理分布，帮助理解道地药材的概念。'),
            _buildFeatureItem(Icons.history_outlined, '个人记录追踪', '安全地记录和管理您的个人信息及上传历史。'),
            SizedBox(height: 20.h),
            _buildSectionTitle('联系我们'),
            SizedBox(height: 8.h),
            _buildSectionContent(
              '我们是一个充满热情的开源项目开发团队，欢迎任何形式的贡献和建议。\n\n'
                  '邮箱: contact@tcm-data.com\n'
                  '项目地址: github.com/your-repo/tcm-data-system',
            ),
            SizedBox(height: 30.h),
            Center(
              child: Text(
                '© 2024 中医药材数据系统',
                style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 45.r,
            backgroundColor: AppColors.primaryLight,
            child: Text('药',
                style: TextStyle(
                    fontFamily: 'KaiTi',
                    fontSize: 42.sp,
                    color: AppColors.primary)),
          ),
          SizedBox(height: 12.h),
          Text(
            '中医药材数据系统',
            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          SizedBox(height: 4.h),
          Text(
            '版本 1.0.0',
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.primary),
    );
  }

  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: TextStyle(fontSize: 15.sp, color: AppColors.textSecondary, height: 1.6),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 22.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                SizedBox(height: 4.h),
                Text(subtitle, style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}