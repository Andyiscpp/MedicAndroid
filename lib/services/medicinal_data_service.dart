// lib/services/medicinal_data_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:demo_conut/data/models/medicinal_data.dart';

class MedicinalDataService {
  final String _baseUrl = 'http://192.168.68.3:81/api/herb';
  // ✅ **复活**: 用于本地缓存的Key
  static const String _dataKey = 'medicinal_data_cache_v3';

  /// ✅ **核心重构**: "网络优先，缓存备用" 的数据获取策略
  Future<List<MedicinalData>> getAllData() async {
    try {
      // 步骤 1: 优先从网络获取最新数据
      final herbsUrl = Uri.parse('$_baseUrl/herbs?limit=1000');
      final herbsResponse = await http.get(herbsUrl);

      if (herbsResponse.statusCode != 200) {
        // 网络请求失败，安全回退到本地缓存
        print('网络请求失败，将从本地缓存加载数据...');
        return _getAllDataFromPrefs();
      }

      final herbsBody = jsonDecode(utf8.decode(herbsResponse.bodyBytes));
      if (herbsBody['code'] != 20000 || herbsBody['data']?['records'] == null) {
        print('获取药材列表业务逻辑失败，将从本地缓存加载...');
        return _getAllDataFromPrefs();
      }

      final List<dynamic> herbRecords = herbsBody['data']['records'];
      final List<MedicinalData> networkData = [];

      for (var herbJson in herbRecords) {
        final herb = Herb(
            id: herbJson['id'],
            name: herbJson['name'] ?? '未知名称',
            scientificName: herbJson['scientificName'] ?? '未知学名',
            description: herbJson['description'] ?? '暂无描述',
            uploaderName: herbJson['creatorName'] ?? '匿名');

        // ... (此处省略了获取图片和地点的逻辑，与上一版相同)
        final imagesUrl = Uri.parse('$_baseUrl/herbs/${herb.id}/images');
        final imagesResponse = await http.get(imagesUrl);
        final List<ImageData> images = [];
        if (imagesResponse.statusCode == 200) {
          final imagesBody = jsonDecode(utf8.decode(imagesResponse.bodyBytes));
          if (imagesBody['code'] == 20000 && imagesBody['data'] is List) {
            final imageRecords = imagesBody['data'] as List;
            for (var imgRecord in imageRecords) {
              images.add(ImageData.fromMap(imgRecord));
            }
          }
        }

        // 此处依然使用占位数据，等待后端提供相应API
        final List<Location> locations = [
          Location.fromMap(herbJson['location'] ?? {'province': '未知', 'city': '未知'})
        ];
        final List<GrowthData> growthData = [];

        networkData.add(MedicinalData(
            herb: herb,
            images: images,
            locations: locations,
            growthData: growthData
        ));
      }

      // 步骤 2: 获取成功后，用最新数据更新本地缓存
      await _saveAllData(networkData);
      print('成功从网络获取数据并更新了本地缓存。');
      return networkData;

    } catch (e) {
      // 发生任何异常时，都安全地回退到本地缓存
      print('获取网络数据时发生未知异常: $e，将从本地缓存加载。');
      return _getAllDataFromPrefs();
    }
  }

  /// ✅ **复活**: 用于在上传成功后，立即向本地缓存中添加一条记录
  Future<void> addDataToLocalCache(MedicinalData newData) async {
    final allData = await _getAllDataFromPrefs();

    // 为了防止重复添加，可以先移除可能存在的旧版本
    allData.removeWhere((d) => d.herb.id == newData.herb.id);
    allData.insert(0, newData); // 插入到列表最前面，以便在UI中立即看到

    await _saveAllData(allData);
    print('已将新上传的数据添加到本地缓存中。');
  }

  /// ✅ **复活**: 从SharedPreferences获取所有数据的私有方法
  Future<List<MedicinalData>> _getAllDataFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final dataJson = prefs.getStringList(_dataKey) ?? [];
    return dataJson.map((json) => MedicinalData.fromMap(jsonDecode(json))).toList();
  }

  /// ✅ **复活**: 将所有数据保存到SharedPreferences的私有方法
  Future<void> _saveAllData(List<MedicinalData> allData) async {
    final prefs = await SharedPreferences.getInstance();
    final dataJson = allData.map((data) => jsonEncode(data.toMap())).toList();
    await prefs.setStringList(_dataKey, dataJson);
  }
}