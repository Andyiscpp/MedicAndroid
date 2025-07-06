// lib/pages/all_uploads_page.dart

import 'package:demo_conut/services/medicinal_data_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_conut/data/models/medicinal_data.dart';
import 'package:demo_conut/pages/home_page.dart'; // For AppColors
import 'package:demo_conut/pages/upload_detail_page_v2.dart';

class AllUploadsPage extends StatefulWidget {
  final String title;

  const AllUploadsPage({super.key, required this.title});

  @override
  State<AllUploadsPage> createState() => _AllUploadsPageState();
}

class _AllUploadsPageState extends State<AllUploadsPage> {
  final MedicinalDataService _dataService = MedicinalDataService();
  final TextEditingController _searchController = TextEditingController();

  // 用于存储从服务器获取的原始数据列表
  List<MedicinalData> _allUploads = [];
  // 用于存储经过筛选和排序后，最终在界面上显示的数据列表
  List<MedicinalData> _filteredUploads = [];
  // 标记是否正在加载数据
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // 添加监听器，当搜索框内容变化时，触发筛选
    _searchController.addListener(_filterUploads);
    // 页面初始化时，获取所有数据
    _fetchData();
  }

  @override
  void dispose() {
    // 页面销毁时，移除监听器并释放控制器
    _searchController.removeListener(_filterUploads);
    _searchController.dispose();
    super.dispose();
  }

  /// 1. 从服务器获取数据并进行初始排序
  Future<void> _fetchData() async {
    // 如果页面还未加载完成，则不重复获取数据
    if (!mounted) return;

    // 开始加载，显示加载动画
    setState(() {
      _isLoading = true;
    });

    final data = await _dataService.getAllUploadsData();

    // ==================== 排序规则应用处 ====================
    // 根据 locationId 进行降序排序
    data.sort((a, b) {
      final idA = a.locations.isNotEmpty ? a.locations.first.id ?? 0 : 0;
      final idB = b.locations.isNotEmpty ? b.locations.first.id ?? 0 : 0;
      return idB.compareTo(idA);
    });
    // ==========================================================

    // 如果页面还未销毁，则更新状态
    if (mounted) {
      setState(() {
        _allUploads = data;
        _filteredUploads = data; // 初始状态下，显示所有数据
        _isLoading = false; // 加载完成
      });
    }
  }

  /// 2. 根据搜索框的文本筛选列表
  void _filterUploads() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUploads = _allUploads.where((data) {
        // 将药材名称也转为小写进行不区分大小写的匹配
        final herbName = data.herb.name.toLowerCase();
        return herbName.contains(query);
      }).toList();
    });
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
          widget.title,
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ==================== 新增的搜索框 ====================
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '按药材名称搜索...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.r),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
                    : null,
              ),
            ),
          ),
          // ======================================================

          // 使用 Expanded 包裹列表，使其填充剩余空间
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _filteredUploads.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              onRefresh: _fetchData, // 支持下拉刷新
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                itemCount: _filteredUploads.length,
                itemBuilder: (context, index) {
                  final data = _filteredUploads[index];
                  return _buildUploadCard(context, data);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI 构建相关的辅助方法 (基本保持不变) ---

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
          Icon(Icons.search_off_outlined, size: 80.sp, color: Colors.grey.shade400),
          SizedBox(height: 16.h),
          Text(
            _searchController.text.isEmpty ? '还没有任何上传记录' : '未找到匹配的药材',
            style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}