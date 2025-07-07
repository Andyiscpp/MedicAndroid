// lib/pages/upload_data_page.dart

import 'dart:async';
import 'dart:io';

import 'package:demo_conut/data/models/medicinal_data.dart';
import 'package:demo_conut/data/models/user.dart';
import 'package:demo_conut/services/oss_service.dart';
import 'package:demo_conut/services/user_service.dart';
import 'package:demo_conut/pages/home_page.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:oktoast/oktoast.dart';

class UploadDataPage extends StatefulWidget {
  final VoidCallback onUploadSuccess;

  const UploadDataPage({
    super.key,
    required this.onUploadSuccess,
  });

  @override
  _UploadDataPageState createState() => _UploadDataPageState();
}

class _UploadDataPageState extends State<UploadDataPage> {
  // Stepper and Form Keys
  int _currentStep = 0;
  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();
  final _formKeyStep3 = GlobalKey<FormState>();

  // Services
  final UserService _userService = UserService();
  final OssService _ossService = OssService();

  // Controllers
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

  // State Variables
  Timer? _debounce;
  bool _isSearchingHerb = false;
  bool _isSubmitting = false;
  User? _currentUser;
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];
  int _primaryImageIndex = 0;

  // Growth Data related
  final Map<String, String> _metricUnitMap = {
    '预估产量': '公斤',
    '土壤PH值': '', // No unit
    '含糖量': '%',
    '平均株高': '厘米',
  };
  late final List<String> _metricNames;
  String? _selectedMetricName;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onHerbNameChanged);
    _metricNames = _metricUnitMap.keys.toList();
    _observationYearController.text = DateTime.now().year.toString();
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _nameController.removeListener(_onHerbNameChanged);
    _debounce?.cancel();
    // Dispose all controllers
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

  // --- Core Logic Methods ---

  Future<void> _loadCurrentUser() async {
    final user = await _userService.fetchAndSaveUserProfile();
    if (mounted) {
      setState(() => _currentUser = user);
    }
  }

  void _onHerbNameChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (_nameController.text.trim().isEmpty) {
      if (mounted) setState(() => _isSearchingHerb = false);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (mounted) setState(() => _isSearchingHerb = true);
      final Herb? foundHerb = await _ossService.searchHerbByName(_nameController.text);
      if (mounted) setState(() => _isSearchingHerb = false);
      if (foundHerb != null && mounted) {
        setState(() {
          _scientificNameController.text = foundHerb.scientificName;
          _herbDescController.text = foundHerb.description;
        });
      }
    });
  }

  void _getCurrentLocation() async {
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
      await Geolocator.openAppSettings();
      return;
    }

    try {
      showToast('正在获取高精度位置...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        forceAndroidLocationManager: true,
      );
      if (mounted) {
        setState(() {
          _longitudeController.text = position.longitude.toStringAsFixed(6);
          _latitudeController.text = position.latitude.toStringAsFixed(6);
        });
        showToast('位置获取成功！正在解析地址...');
        await _getAddressFromCoordinates(position);
      }
    } catch (e) {
      showToast('获取位置失败: $e');
    }
  }

  Future<void> _getAddressFromCoordinates(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        if (mounted) {
          setState(() {
            _provinceController.text = place.administrativeArea ?? '';
            _cityController.text = place.locality ?? '';
            _addressController.text = '${place.street ?? ''} ${place.name ?? ''}'.trim();
          });
          showToast('地址解析成功！');
        }
      }
    } catch (e) {
      showToast('地址解析失败: $e');
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
          _selectedImages.addAll(pickedFiles.length > maxImages ? pickedFiles.sublist(0, maxImages) : pickedFiles);
          if (_selectedImages.isNotEmpty && _primaryImageIndex >= _selectedImages.length) {
            _primaryImageIndex = 0;
          }
        });
      }
    } catch (e) {
      if (mounted) showToast('选择图片时发生错误: $e');
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

  // ✅ *** 核心修改点 2: 创建一个重置表单的方法 ***
  void _resetForm() {
    // Clear all text controllers
    _nameController.clear();
    _scientificNameController.clear();
    _herbDescController.clear();
    _longitudeController.clear();
    _latitudeController.clear();
    _provinceController.clear();
    _cityController.clear();
    _addressController.clear();
    _metricValueController.clear();
    _imageDescController.clear();

    // Reset state variables in setState
    setState(() {
      _selectedImages.clear();
      _primaryImageIndex = 0;
      _selectedMetricName = null;
      _currentStep = 0;
      _isSubmitting = false;
    });
  }

  void _submitForm() async {
    // Validate all steps
    if (!_formKeyStep1.currentState!.validate() ||
        !_formKeyStep2.currentState!.validate() ||
        !_formKeyStep3.currentState!.validate()) {
      showToast('请检查所有必填项');
      return;
    }
    if (_selectedImages.isEmpty) {
      showToast('请至少上传一张图片');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final herbId = await _ossService.getOrCreateHerbId(
        name: _nameController.text,
        scientificName: _scientificNameController.text,
      );
      if (herbId == null) throw Exception('获取或创建药材ID失败');

      final policy = await _ossService.getOssPolicy();
      if (policy == null) throw Exception('获取上传许可失败');

      final List<Future<String?>> uploadTasks =
      _selectedImages.map((xfile) => _ossService.uploadFileToOss(file: File(xfile.path), policy: policy)).toList();
      final List<String?> uploadedImageUrls = await Future.wait(uploadTasks);
      if (uploadedImageUrls.any((url) => url == null)) throw Exception('部分图片上传失败，请重试');

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
        "uploaderName": _currentUser?.displayName ?? '匿名用户',
        "uploadedAt": DateTime.now().toIso8601String(),
        if (_selectedMetricName != null && _metricValueController.text.isNotEmpty)
          "growthData": {
            "metricName": _selectedMetricName,
            "metricValue": _metricValueController.text,
            "metricUnit": _metricUnitMap[_selectedMetricName] ?? '',
            "recordedAt": DateTime.now().toIso8601String(),
          },
      };

      final locationId = await _ossService.createLocation(locationData);
      if (locationId == null) throw Exception('创建观测点失败');

      final List<Map<String, dynamic>> imagesMetadata = [];
      for (int i = 0; i < finalImageUrls.length; i++) {
        imagesMetadata.add({
          "url": finalImageUrls[i],
          "isPrimary": i == _primaryImageIndex,
          "description": _imageDescController.text,
        });
      }
      final success = await _ossService.saveImagesForLocation(locationId: locationId, images: imagesMetadata);
      if (!success) throw Exception('最终数据保存失败');

      showToast('数据已成功提交！', duration: const Duration(seconds: 3));
      if (mounted) {
        widget.onUploadSuccess();
        _resetForm(); // ✅ 在成功回调后调用重置方法
      }
    } catch (e) {
      showToast('上传失败: ${e.toString().replaceAll("Exception: ", "")}');
      // Only set isSubmitting to false on failure, success will reset it.
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
    // No finally block needed, as success path now handles the reset.
  }

  // --- UI Build Methods ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stepper(
          type: StepperType.horizontal,
          currentStep: _currentStep,
          onStepTapped: (step) => setState(() => _currentStep = step),
          onStepContinue: () {
            // Validate current step before proceeding
            bool isStepValid = false;
            if (_currentStep == 0) {
              isStepValid = _formKeyStep1.currentState!.validate();
            } else if (_currentStep == 1) {
              isStepValid = _formKeyStep2.currentState!.validate();
            } else {
              isStepValid = true; // Last step
            }

            if (isStepValid) {
              if (_currentStep < 2) {
                setState(() => _currentStep += 1);
              } else {
                _submitForm();
              }
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep -= 1);
            }
          },
          controlsBuilder: (context, details) {
            return _buildControls(context, details);
          },
          steps: [
            _buildStep(
              title: '药材信息',
              content: _buildStep1HerbInfo(),
              isActive: _currentStep >= 0,
              formKey: _formKeyStep1,
            ),
            _buildStep(
              title: '观测点详情',
              content: _buildStep2LocationInfo(),
              isActive: _currentStep >= 1,
              formKey: _formKeyStep2,
            ),
            _buildStep(
              title: '生长与图片',
              content: _buildStep3MediaInfo(),
              isActive: _currentStep >= 2,
              formKey: _formKeyStep3,
            ),
          ],
        ),
      ),
    );
  }

  Step _buildStep({
    required String title,
    required Widget content,
    required bool isActive,
    required GlobalKey<FormState> formKey,
  }) {
    return Step(
      title: Text(title),
      content: Form(key: formKey, child: content),
      isActive: isActive,
      state: isActive ? StepState.editing : StepState.indexed,
    );
  }

  Widget _buildControls(BuildContext context, ControlsDetails details) {
    return Padding(
      padding: EdgeInsets.only(top: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          if (_currentStep > 0)
            TextButton(
              onPressed: details.onStepCancel,
              child: const Text('上一步'),
            ),
          SizedBox(width: 12.w),
          ElevatedButton(
            onPressed: _isSubmitting ? null : details.onStepContinue, // Disable button while submitting
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            child: _isSubmitting
                ? SizedBox(
              width: 20.w,
              height: 20.h,
              child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
                : Text(_currentStep == 2 ? '确认上传' : '下一步'),
          ),
        ],
      ),
    );
  }

  // --- Step Content Builders ---

  Widget _buildStep1HerbInfo() {
    return Column(
      children: [
        _buildTextFormField(
          controller: _nameController,
          label: '药材名称',
          hint: '例如：黄芪',
          icon: Icons.grass_outlined,
          suffixIcon: _isSearchingHerb
              ? const Padding(
            padding: EdgeInsets.all(12.0),
            child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
          )
              : null,
        ),
        SizedBox(height: 16.h),
        _buildTextFormField(
          controller: _scientificNameController,
          label: '学名 (可自动填充)',
          hint: '例如：Astragalus membranaceus',
          icon: Icons.science_outlined,
          isRequired: false,
        ),
        SizedBox(height: 16.h),
        _buildTextFormField(
          controller: _herbDescController,
          label: '描述 (可自动填充)',
          hint: '功效、性状等',
          icon: Icons.description_outlined,
          maxLines: 3,
          isRequired: false,
        ),
      ],
    );
  }

  Widget _buildStep2LocationInfo() {
    return Column(
      children: [
        _buildTextFormField(
          controller: _provinceController,
          label: '省份',
          hint: '例如：内蒙古自治区',
          icon: Icons.map_outlined,
        ),
        SizedBox(height: 16.h),
        _buildTextFormField(
          controller: _cityController,
          label: '城市',
          hint: '例如：呼和浩特市',
          icon: Icons.location_city_outlined,
        ),
        SizedBox(height: 16.h),
        _buildTextFormField(
          controller: _addressController,
          label: '详细地址',
          hint: '例如：武川县黄芪种植基地',
          icon: Icons.home_work_outlined,
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
                child: _buildTextFormField(
                    controller: _longitudeController,
                    label: '经度',
                    icon: Icons.explore_outlined,
                    keyboardType: TextInputType.number)),
            SizedBox(width: 16.w),
            Expanded(
                child: _buildTextFormField(
                    controller: _latitudeController,
                    label: '纬度',
                    icon: Icons.explore_outlined,
                    keyboardType: TextInputType.number)),
          ],
        ),
        SizedBox(height: 10.h),
        ElevatedButton.icon(
          icon: const Icon(Icons.my_location, size: 18),
          label: const Text('自动获取位置与地址'),
          onPressed: _getCurrentLocation,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryLight,
            foregroundColor: AppColors.primary,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          ),
        ),
      ],
    );
  }

  Widget _buildStep3MediaInfo() {
    // ✅ *** 核心修改点 1: 获取当前选择的单位 ***
    final String currentUnit = _selectedMetricName != null ? (_metricUnitMap[_selectedMetricName] ?? '') : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('上传图片 (至少一张)', style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp)),
        SizedBox(height: 8.h),
        _buildImagePickerSection(),
        SizedBox(height: 24.h),
        Text('生长数据 (选填)', style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp)),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          value: _selectedMetricName,
          decoration: _inputDecoration('指标名称', icon: Icons.eco_outlined),
          items: _metricNames.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (value) => setState(() => _selectedMetricName = value),
        ),
        SizedBox(height: 16.h),
        _buildTextFormField(
          controller: _metricValueController,
          label: '指标值',
          hint: '例如: 500',
          icon: Icons.format_list_numbered_rtl_outlined,
          keyboardType: TextInputType.number,
          isRequired: false,
          // ✅ 将获取到的单位作为后缀文本显示
          suffixText: currentUnit.isNotEmpty ? currentUnit : null,
        ),
      ],
    );
  }

  // --- Helper UI Widgets ---

  Widget _buildTextFormField(
      {required TextEditingController controller,
        required String label,
        String? hint,
        IconData? icon,
        int maxLines = 1,
        TextInputType? keyboardType,
        bool isRequired = true,
        Widget? suffixIcon,
        String? suffixText}) { // ✅ 添加 suffixText 参数
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: _inputDecoration(label, hint: hint, icon: icon, suffixIcon: suffixIcon, suffixText: suffixText), // ✅ 传递参数
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return '$label 不能为空';
        }
        return null;
      },
    );
  }

  InputDecoration _inputDecoration(String label,
      {String? hint, IconData? icon, Widget? suffixIcon, String? suffixText}) { // ✅ 添加 suffixText 参数
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: AppColors.primary) : null,
      suffixIcon: suffixIcon,
      suffixText: suffixText, // ✅ 使用参数
      suffixStyle: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold), // 给单位添加样式
      contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
      ),
    );
  }

  Widget _buildImagePickerSection() {
    return GridView.builder(
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
    );
  }

  Widget _buildAddImageButton() {
    return InkWell(
      onTap: _pickImages,
      borderRadius: BorderRadius.circular(8.r),
      child: DottedBorder(
        color: AppColors.primary.withOpacity(0.6),
        strokeWidth: 1.5,
        dashPattern: const [6, 4],
        radius: Radius.circular(8.r),
        borderType: BorderType.RRect,
        child: const Center(
          child: Icon(Icons.add_a_photo_outlined, color: AppColors.primary, size: 30),
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(XFile imageFile, int index) {
    bool isPrimary = index == _primaryImageIndex;
    return GestureDetector(
      onTap: () => setState(() => _primaryImageIndex = index),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isPrimary ? AppColors.primary : Colors.transparent,
                width: 2.5,
              ),
              image: DecorationImage(image: FileImage(File(imageFile.path)), fit: BoxFit.cover),
            ),
          ),
          if (isPrimary)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.8),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(5.r),
                    bottomRight: Radius.circular(5.r),
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: Text('主图',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold)),
              ),
            ),
          Positioned(
            top: -8,
            right: -8,
            child: InkWell(
              onTap: () => _removeImage(index),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
