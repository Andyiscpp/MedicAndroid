import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'home_page.dart'; // 导入以使用 AppColors

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

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
          '使用帮助',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('常见问题 (FAQ)', Icons.quiz_outlined),
            _buildFaqSection(),
            SizedBox(height: 24.h),
            _buildSectionTitle('功能指南', Icons.menu_book_outlined),
            _buildGuideSection(),
            SizedBox(height: 24.h),
            _buildSectionTitle('联系我们', Icons.support_agent_outlined),
            _buildContactSection(),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  // 构建统一的段落标题
  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22.sp),
          SizedBox(width: 8.w),
          Text(
            title,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  // FAQ区域，使用可展开的卡片
  Widget _buildFaqSection() {
    return Card(
      elevation: 2,
      shadowColor: AppColors.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildExpansionTile(
            '如何上传我的药材数据？',
            '在主页点击“核心功能”区域的“上传数据”按钮，即可进入上传页面。请按照表单提示，填写药材名称、地理位置等信息，并从您的手机相册中选择至少一张清晰的图片。填写完毕后，点击底部的“确认上传”即可。',
          ),
          _buildExpansionTile(
            '我上传的图片有什么要求？',
            '为了保证数据质量，请尽量上传清晰、明亮、能够反映药材特征的图片。我们支持常见的图片格式如JPG、PNG等。单次最多可上传5张图片。',
          ),
          _buildExpansionTile(
            '忘记密码了怎么办？',
            '目前版本暂不支持在线找回密码。如果您忘记了密码，请联系我们的技术支持团队，我们将协助您进行身份验证和密码重置。联系方式请见页面底部的“联系我们”部分。',
          ),
        ],
      ),
    );
  }

  // 功能指南区域
  Widget _buildGuideSection() {
    return Column(
      children: [
        _buildGuideItem(
          '药材总览',
          '这里汇集了系统中收录的经典药材信息。您可以通过网格视图快速浏览，点击任意药材卡片即可查看其详细的来源、功效和用法用量等信息。',
        ),
        _buildGuideItem(
          '查看所有上传',
          '在主页的“核心功能”区，您可以查看所有用户上传分享的数据记录。这是一个开放的知识库，您可以通过它了解不同地区、不同生长环境下的药材形态。',
        ),
        _buildGuideItem(
          '个人中心',
          '通过点击主页右上角的头像，您可以进入个人中心。在这里，您可以编辑您的个人资料、查看您的上传历史、修改密码以及了解关于我们的信息。',
        ),
      ],
    );
  }

  // 联系我们区域
  Widget _buildContactSection() {
    return Card(
      elevation: 2,
      shadowColor: AppColors.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          '如果您在使用过程中遇到任何问题，或有任何宝贵的建议，欢迎随时通过以下方式联系我们：\n\n'
              '• 电子邮件: 2298786941@qq.com\n'
              '• 官方QQ群: 872798582',
          style: TextStyle(fontSize: 14, height: 1.6, color: AppColors.textSecondary),
        ),
      ),
    );
  }


  // ----- 辅助小部件 -----

  // 单个可展开的FAQ项
  Widget _buildExpansionTile(String title, String content) {
    return ExpansionTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      iconColor: AppColors.primary,
      collapsedIconColor: AppColors.textSecondary,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
          child: Text(
            content,
            style: const TextStyle(height: 1.5, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  // 单个功能指南项
  Widget _buildGuideItem(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Card(
        elevation: 0,
        color: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
            side: BorderSide(color: Colors.grey.shade200)
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  title,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.primary)
              ),
              SizedBox(height: 8.h),
              Text(
                  content,
                  style: const TextStyle(height: 1.5, color: AppColors.textSecondary)
              ),
            ],
          ),
        ),
      ),
    );
  }
}