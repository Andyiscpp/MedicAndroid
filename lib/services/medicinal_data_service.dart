// lib/services/medicinal_data_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:demo_conut/data/models/medicinal_data.dart';

class MedicinalDataService {
  final String _baseUrl = 'http://192.168.68.3:81/api/herb';
  static const String _dataKey = 'medicinal_data_cache_v3';

  /// ✅ 全新重写: 使用为新后端格式优化的方法
  Future<List<MedicinalData>> getAllUploadsData() async {
    final url = Uri.parse('$_baseUrl/uploads/all');
    print('【网络请求】开始: 获取所有上传记录 (新接口) -> $url');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));

        if (body['code'] == 20000 && body['data'] is List) {
          final List<dynamic> records = body['data'];
          print('【网络请求】成功: 从新接口获取了 ${records.length} 条记录。');

          List<MedicinalData> allData = [];

          // 直接遍历，不再需要发送子请求
          for (var record in records) {
            if (record is! Map<String, dynamic>) continue; // 安全检查

            // 1. 从记录中构建 Herb 对象
            final herb = Herb(
              id: record['herbId'],
              name: record['herbName'] ?? '未知名称',
              uploaderName: record['uploaderName'], // 可以为 null
              // 以下字段在新接口中没有，提供默认值
              scientificName: '',
              description: '',
            );

            // 2. 从记录中构建 Location 对象
            final location = Location(
              id: record['locationId'],
              herbId: record['herbId'],
              longitude: (record['longitude'] as num?)?.toDouble() ?? 0.0,
              latitude: (record['latitude'] as num?)?.toDouble() ?? 0.0,
              province: record['province'] ?? '',
              city: record['city'] ?? '',
              address: record['address'] ?? '',
              observationYear: record['observationYear'] ?? DateTime.now().year,
            );

            // 3. 从记录中的 imageUrls 构建 ImageData 列表
            List<ImageData> images = [];
            if (record['imageUrls'] is List) {
              final List<dynamic> urlList = record['imageUrls'];
              for (int i = 0; i < urlList.length; i++) {
                if (urlList[i] is String) {
                  images.add(ImageData(
                    url: urlList[i],
                    isPrimary: i == 0 ? 1 : 0, // 将第一张图设为主图
                    description: '', // 新接口无此字段
                  ));
                }
              }
            }

            // 4. 从记录中的 growthData 构建 GrowthData 列表
            List<GrowthData> growthDataList = [];
            if (record['growthData'] is List) {
              final List<dynamic> rawGrowthList = record['growthData'];
              for(final rawGrowth in rawGrowthList) {
                if (rawGrowth is Map<String, dynamic>) {
                  // 假设后端没有 recordedAt，客户端生成
                  rawGrowth['recorded_at'] = DateTime.now().toIso8601String();
                  growthDataList.add(GrowthData.fromMap(rawGrowth));
                }
              }
            }

            // 5. 组装成一个完整的 MedicinalData 对象
            allData.add(MedicinalData(
              herb: herb,
              locations: [location], // 假设一条记录对应一个地点
              growthData: growthDataList,
              images: images,
            ));
          }

          print('【数据处理】成功解析了 ${allData.length} 条记录。');
          return allData;
        }
      }
      print('【网络请求】失败: 获取上传记录失败，状态码: ${response.statusCode}');
      return []; // 如果请求失败，返回空列表
    } catch (e, s) {
      print('【网络请求】异常: 调用/uploads/all接口时发生未知异常: $e');
      print('堆栈跟踪: $s');
      return []; // 发生异常时返回空列表
    }
  }


  // --- 以下是旧方法，为了保持应用其他部分能工作，我们暂时保留它们 ---
  // --- 但在理想情况下，所有的数据获取都应迁移到新的高效接口 ---

  Future<List<MedicinalData>> getAllData() async {
    // 暂时让此方法也调用新的高效接口，以统一数据源
    print("【兼容模式】getAllData() 被调用，重定向到新的 getAllUploadsData() 方法。");
    return await getAllUploadsData();
  }

  Future<void> addDataToLocalCache(MedicinalData newData) async {
    final allData = await _getAllDataFromPrefs();
    allData.removeWhere((d) => d.herb.id == newData.herb.id);
    allData.insert(0, newData);
    await _saveAllData(allData);
  }

  Future<List<MedicinalData>> _getAllDataFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final dataJson = prefs.getStringList(_dataKey) ?? [];
    return dataJson.map((json) => MedicinalData.fromMap(jsonDecode(json))).toList();
  }

  Future<void> _saveAllData(List<MedicinalData> allData) async {
    final prefs = await SharedPreferences.getInstance();
    final dataJson = allData.map((data) => jsonEncode(data.toMap())).toList();
    await prefs.setStringList(_dataKey, dataJson);
  }
}