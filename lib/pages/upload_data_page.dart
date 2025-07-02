// lib/pages/upload_data_page.dart

import 'dart:io';
import 'package:demo_conut/data/models/user.dart';
import 'package:demo_conut/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:oktoast/oktoast.dart';
import 'dart:async';

import 'package:demo_conut/data/models/medicinal_data.dart';
import 'package:demo_conut/services/medicinal_data_service.dart';
import 'package:demo_conut/pages/home_page.dart';
import 'package:demo_conut/services/oss_service.dart';
import 'package:geolocator/geolocator.dart';
// 导入 geocoding 插件，并隐藏其内部的 Location 类以避免冲突
import 'package:geocoding/geocoding.dart' hide Location;

class UploadDataPage extends StatefulWidget {
  const UploadDataPage({super.key});

  @override
  _UploadDataPageState createState() => _UploadDataPageState();
}

class _UploadDataPageState extends State<UploadDataPage> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();
  final OssService _ossService = OssService();
  final MedicinalDataService _medicinalDataService = MedicinalDataService();

  final _nameController = TextEditingController();
  final _scientificNameController = TextEditingController();
  final _herbDescController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _provinceController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _observationYearController = TextEditingController();
  final _metricValueController = TextEditingController();
  final _imageDescController = TextEditingController();


  // ✅ 新增：用于实现防抖的Timer
  Timer? _debounce;
  // ✅ 新增：用于显示搜索状态的加载指示器
  bool _isSearching = false;


  final Map<String, String> _metricUnitMap = {
    '预估产量': '公斤', '土壤PH值': '', '含糖量': '%', '平均株高': '厘米',
  };
  late final List<String> _metricNames;
  late final List<String> _metricUnits;
  String? _selectedMetricName;
  String? _selectedMetricUnit;
  User? _currentUser;
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];
  int _primaryImageIndex = 0;

  @override
  void initState() {
    super.initState();
    // 监听药材名称输入框的变化
    _nameController.addListener(_onHerbNameChanged);
    _metricNames = _metricUnitMap.keys.toList();
    _metricUnits = _metricUnitMap.values.toSet().toList();
    _observationYearController.text = DateTime.now().year.toString();
    _loadCurrentUser();
  }

  // ✅ 新增：处理药材名称变化的方法
  void _onHerbNameChanged() {
    // 如果存在正在计时的防抖器，则取消它
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // 如果输入框为空，则不进行任何操作
    if (_nameController.text.trim().isEmpty) {
      if (mounted) setState(() => _isSearching = false);
      return;
    }

    // 启动一个新的防抖器，延迟500毫秒后执行搜索
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (mounted) setState(() => _isSearching = true);

      // 调用服务进行搜索
      // 注意：这里需要您在 oss_service.dart 中添加 searchHerbByName 方法
      final Herb? foundHerb = await _ossService.searchHerbByName(_nameController.text);

      // 搜索结束后，无论成功与否，都取消加载状态
      if (mounted) setState(() => _isSearching = false);

      // 如果找到了药材，则填充学名
      if (foundHerb != null && mounted) {
        setState(() {
          _scientificNameController.text = foundHerb.scientificName;
        });
      }
    });
  }

  @override
  void dispose() {
    // 在页面销毁时，取消监听并销毁控制器和防抖器
    _nameController.removeListener(_onHerbNameChanged);
    _debounce?.cancel();
    _nameController.dispose();
    _scientificNameController.dispose();
    _herbDescController.dispose();
    _longitudeController.dispose();
    _latitudeController.dispose();
    _provinceController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _observationYearController.dispose();
    _metricValueController.dispose();
    _imageDescController.dispose();
    super.dispose();
  }


  Future<void> _getAddressFromCoordinates(Position position) async {
    try {
      print('【地址解析】开始将坐标 ${position.latitude}, ${position.longitude} 转换为地址');
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        print('【地址解析】成功，获取到地址信息: $place');

        if (mounted) {
          setState(() {
            _provinceController.text = place.administrativeArea ?? '';
            _cityController.text = place.locality ?? '';
            _addressController.text = '${place.street ?? ''} ${place.name ?? ''}'.trim();
          });
          showToast('地址解析成功！');
        }
      } else {
        print('【地址解析】错误: 返回的地址列表为空');
        showToast('无法将坐标解析为地址信息');
      }
    } catch (e) {
      print('【地址解析】捕获到错误: $e');
      showToast('地址解析失败，您的手机可能不支持此功能。错误: $e');
    }
  }

  void _getCurrentLocation() async {
    print('【定位调试】开始执行 _getCurrentLocation 方法...');

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showToast('定位服务已禁用，请在系统设置中开启');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showToast('您已拒绝定位权限，无法获取位置');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showToast('定位权限已被永久拒绝，请在应用设置中手动开启');
      Geolocator.openAppSettings();
      return;
    }

    try {
      showToast('正在获取高精度位置，请稍候...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 20),
        forceAndroidLocationManager: true,
      );

      print('【定位调试】成功获取到位置: $position');

      if (mounted) {
        setState(() {
          _longitudeController.text = position.longitude.toStringAsFixed(6);
          _latitudeController.text = position.latitude.toStringAsFixed(6);
        });
        showToast('位置获取成功！正在解析地址...');
        await _getAddressFromCoordinates(position);
      }

    } on TimeoutException catch (e) {
      print('【定位调试】捕获到 TimeoutException: $e');
      showToast('获取位置超时，请尝试到室外开阔地带重试');
    } on PlatformException catch (e) {
      print('【定位调试】捕获到 PlatformException: Code=${e.code}, Message=${e.message}');
      showToast('获取位置失败，平台错误: ${e.message}');
    } catch (e) {
      print('【定位调试】捕获到未知错误: $e');
      showToast('获取位置时发生未知错误，请查看控制台日志');
    }
  }

  Future<void> _loadCurrentUser() async {
    final user = await _userService.getLoggedInUser();
    if (mounted) { setState(() { _currentUser = user; }); }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      showToast('请检查所有必填项');
      return;
    }
    if (_selectedImages.isEmpty) {
      showToast('请至少上传一张图片');
      return;
    }

    showToast('正在处理，请稍候...', duration: const Duration(seconds: 30));

    try {
      final herbId = await _ossService.getOrCreateHerbId(
        name: _nameController.text,
        scientificName: _scientificNameController.text,
      );
      if (herbId == null) {
        showToast('获取药材ID失败，请重试');
        return;
      }

      final policy = await _ossService.getOssPolicy();
      if (policy == null) {
        showToast('获取上传许可失败');
        return;
      }

      final List<Future<String?>> uploadTasks = _selectedImages.map((xfile) {
        return _ossService.uploadFileToOss(file: File(xfile.path), policy: policy);
      }).toList();
      final List<String?> uploadedImageUrls = await Future.wait(uploadTasks);

      if (uploadedImageUrls.any((url) => url == null)) {
        showToast('部分图片上传失败，请重试');
        return;
      }
      final List<String> finalImageUrls = uploadedImageUrls.whereType<String>().toList();

      final locationData = {
        "herbId": herbId,
        "longitude": double.tryParse(_longitudeController.text) ?? 0.0,
        "latitude": double.tryParse(_latitudeController.text) ?? 0.0,
        "province": _provinceController.text,
        "city": _cityController.text,
        "address": _addressController.text,
        "observationYear": int.tryParse(_observationYearController.text) ?? DateTime.now().year,
        "description": _herbDescController.text,
      };

      final locationId = await _ossService.createLocation(locationData);
      if (locationId == null) {
        showToast('创建观测点记录失败');
        return;
      }

      final List<Map<String, dynamic>> imagesMetadata = [];
      for (int i = 0; i < finalImageUrls.length; i++) {
        imagesMetadata.add({
          "url": finalImageUrls[i],
          "isPrimary": i == _primaryImageIndex,
          "description": _imageDescController.text,
        });
      }

      final success = await _ossService.saveImagesForLocation(
        locationId: locationId,
        images: imagesMetadata,
      );

      if (success) {
        showToast('数据已成功提交！', duration: const Duration(seconds: 4));

        final List<ImageData> localImages = [];
        for (int i = 0; i < finalImageUrls.length; i++) {
          localImages.add(ImageData(
            url: finalImageUrls[i],
            isPrimary: i == _primaryImageIndex ? 1 : 0,
            description: _imageDescController.text,
          ));
        }

        final localLocation = Location(
          herbId: herbId,
          id: locationId,
          longitude: double.tryParse(_longitudeController.text) ?? 0.0,
          latitude: double.tryParse(_latitudeController.text) ?? 0.0,
          province: _provinceController.text,
          city: _cityController.text,
          address: _addressController.text,
          observationYear: int.tryParse(_observationYearController.text) ?? DateTime.now().year,
        );

        final localHerb = Herb(
          id: herbId,
          name: _nameController.text,
          scientificName: _scientificNameController.text,
          description: _herbDescController.text,
          uploaderName: _currentUser?.realName,
        );

        final newLocalData = MedicinalData(
          herb: localHerb,
          locations: [localLocation],
          images: localImages,
          growthData: [],
        );

        await _medicinalDataService.addDataToLocalCache(newLocalData);

        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        showToast('最终数据保存失败');
      }

    } catch (e) {
      showToast('上传过程中发生未知错误: $e');
    }
  }

  Future<void> _pickImages() async {
    final int maxImages = 5 - _selectedImages.length;
    if (maxImages <= 0) {
      showToast('最多上传5张图片');
      return;
    }
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(imageQuality: 85);
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(
              pickedFiles.length > maxImages ? pickedFiles.sublist(0, maxImages) : pickedFiles
          );
          if (_selectedImages.isNotEmpty && _primaryImageIndex >= _selectedImages.length) {
            _primaryImageIndex = 0;
          }
        });
      }
    } catch (e) {
      if(mounted) showToast('选择图片时发生错误: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      if (_primaryImageIndex == index) {
        _primaryImageIndex = 0;
      } else if (_primaryImageIndex > index) {
        _primaryImageIndex--;
      }
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
        title: const Text(
          '上传药材数据',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionCard(
                  title: '上传信息',
                  icon: Icons.person_pin_circle_outlined,
                  child: _buildUploaderInfoSection(),
                ),
                SizedBox(height: 16.h),
                _buildSectionCard(
                  title: '药材信息 (Herb)',
                  icon: Icons.grass_outlined,
                  child: Column(
                    children: [
                      _buildTextFormField(
                        _nameController,
                        '名称',
                        '例如：黄芪',
                        suffixIcon: _isSearching
                            ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                            : null,
                      ),
                      SizedBox(height: 16.h),
                      _buildTextFormField(_scientificNameController, '学名 (将自动填充)', '例如：Astragalus membranaceus', isRequired: false),
                      SizedBox(height: 16.h),
                      _buildTextFormField(_herbDescController, '描述', '功效、性状等', maxLines: 3),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                _buildSectionCard(
                  title: '图片信息 (Image)',
                  icon: Icons.image_outlined,
                  child: Column(
                    children: [
                      _buildImagePickerSection(),
                      SizedBox(height: 16.h),
                      _buildTextFormField(_imageDescController, '图片描述', '例如：黄芪植株全株图（适用于所有图片）'),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                _buildSectionCard(
                  title: '地理位置 (Location)',
                  icon: Icons.location_on_outlined,
                  child: Column(
                    children: [
                      _buildTextFormField(_provinceController, '省份', '例如：内蒙古自治区'),
                      SizedBox(height: 16.h),
                      _buildTextFormField(_cityController, '城市', '例如：呼和浩特市'),
                      SizedBox(height: 16.h),
                      _buildTextFormField(_addressController, '详细地址', '例如：武川县黄芪种植基地'),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(child: _buildTextFormField(_longitudeController, '经度', '例如：116.40', keyboardType: TextInputType.number)),
                          SizedBox(width: 16.w),
                          Expanded(child: _buildTextFormField(_latitudeController, '纬度', '例如：39.91', keyboardType: TextInputType.number)),
                          Padding(
                            padding: EdgeInsets.only(left: 8.w),
                            child: IconButton(
                              icon: const Icon(Icons.my_location, color: AppColors.primary),
                              tooltip: '自动获取当前位置',
                              onPressed: _getCurrentLocation,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      _buildTextFormField(_observationYearController, '观测年份', '例如：2024', keyboardType: TextInputType.number, isEnabled: false),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                _buildSectionCard(
                  title: '生长数据 (Growth Data)',
                  icon: Icons.eco_outlined,
                  child: Column(
                    children: [
                      _buildDropdownFormField(
                          items: _metricNames,
                          label: '指标名称',
                          value: _selectedMetricName,
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _selectedMetricName = value;
                              _selectedMetricUnit = _metricUnitMap[value];
                            });
                          }
                      ),
                      SizedBox(height: 16.h),
                      _buildTextFormField(_metricValueController, '指标值', '例如：500', keyboardType: TextInputType.number),
                      SizedBox(height: 16.h),
                      _buildDropdownFormField(
                          items: _metricUnits,
                          label: '指标单位',
                          value: _selectedMetricUnit,
                          onChanged: (value) {
                            setState(() {
                              _selectedMetricUnit = value;
                            });
                          }
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),
                _buildSubmitButton(),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Widget child}) {
    return Card(
      elevation: 2,
      shadowColor: AppColors.primary.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.h,
          ),
          itemCount: _selectedImages.length + 1,
          itemBuilder: (context, index) {
            if (index == _selectedImages.length) {
              return Visibility(
                visible: _selectedImages.length < 5,
                child: _buildAddImageButton(),
              );
            }
            return _buildImageThumbnail(_selectedImages[index], index);
          },
        ),
        if (_selectedImages.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Text(
              '  请至少上传一张图片。',
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12.sp),
            ),
          ),
      ],
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withOpacity(0.6),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.primary.withOpacity(0.3), style: BorderStyle.solid, width: 1.5),
        ),
        child: const Icon(Icons.add_a_photo_outlined, color: AppColors.primary, size: 30),
      ),
    );
  }

  Widget _buildImageThumbnail(XFile imageFile, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _primaryImageIndex = index;
        });
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: _primaryImageIndex == index ? AppColors.primary : Colors.transparent,
                width: 2.5,
              ),
              image: DecorationImage(
                image: FileImage(File(imageFile.path)),
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (_primaryImageIndex == index)
            Positioned(
              top: -5,
              left: -5,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 12),
              ),
            ),
          Positioned(
            top: -8,
            right: -8,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploaderInfoSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('上传者', style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary)),
            Text(
              _currentUser?.realName ?? '加载中...',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('上传时间', style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary)),
            Text(
              DateFormat('yyyy年MM月dd日 HH:mm').format(DateTime.now()),
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ],
        )
      ],
    );
  }

  // ✅ 修改 _buildTextFormField 方法，使其可以接收一个后缀图标（suffixIcon）
  Widget _buildTextFormField(TextEditingController controller, String label, String hint, {int maxLines = 1, TextInputType? keyboardType, bool isRequired = true, bool isEnabled = true, Widget? suffixIcon}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      enabled: isEnabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: !isEnabled,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: isEnabled ? AppColors.primary : Colors.grey, width: 2.0),
        ),
        alignLabelWithHint: maxLines > 1,
        contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
        // ✅ 新增: 在这里使用后缀图标
        suffixIcon: suffixIcon,
      ),
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return '此项为必填项';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownFormField({required List<String> items, required String label, String? value, required ValueChanged<String?> onChanged}) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 12.w),
      ),
      items: items.map((String itemValue) {
        return DropdownMenuItem<String>(
          value: itemValue,
          child: Text(itemValue.isEmpty ? "无" : itemValue),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? '此项为必选项' : null,
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.cloud_upload_outlined, size: 20),
      label: const Text('确认上传'),
      onPressed: _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        textStyle: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
      ),
    );
  }
}