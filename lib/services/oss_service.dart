// lib/services/oss_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import '../data/models/medicinal_data.dart';

class OssService {
  final String _baseUrl = 'http://192.168.68.3:81/api'; // 统一的基础URL
  final Dio _dio = Dio();


  /// ✅ 新增方法: 根据名称搜索药材，并返回第一个匹配项
  Future<Herb?> searchHerbByName(String name) async {
    // 如果名称为空，则不执行搜索
    if (name.trim().isEmpty) {
      return null;
    }
    // 构建请求URL，与您后端接口一致
    final searchUrl = Uri.parse('$_baseUrl/herb/herbs/searchByName').replace(queryParameters: {
      'name': name,
      'page': '1',
      'limit': '1' // 我们只需要最匹配的一条记录
    });

    print('【药材搜索】正在搜索: $name');

    try {
      final response = await http.get(searchUrl);
      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        // 后端返回成功且有数据记录
        if (body['code'] == 20000 && body['data']?['records'] is List) {
          final records = body['data']['records'] as List;
          if (records.isNotEmpty) {
            // 将第一条记录转换为Herb对象并返回
            print('【药材搜索】成功找到匹配项: ${records.first['scientificName']}');
            return Herb.fromMap(records.first);
          }
        }
      }
      print('【药材搜索】未找到或请求失败');
      return null;
    } catch (e) {
      print('【药材搜索】搜索时发生异常: $e');
      return null;
    }
  }


  /// 流程1: "查找或创建" 药材ID (逻辑不变)
  Future<int?> getOrCreateHerbId({
    required String name,
    required String scientificName,
  }) async {
    final searchUrl = Uri.parse('$_baseUrl/herb/herbs/searchByName').replace(queryParameters: {'name': name});
    try {
      final searchResponse = await http.get(searchUrl);
      if (searchResponse.statusCode == 200) {
        final body = jsonDecode(utf8.decode(searchResponse.bodyBytes));
        if (body['code'] == 20000 && body['data']?['records'] is List) {
          final records = body['data']['records'] as List;
          if (records.isNotEmpty) {
            return records.first['id'];
          }
        }
      }
      return await _createHerb(name: name, scientificName: scientificName);
    } catch (e) {
      print('查找或创建药材ID时出错: $e');
      return null;
    }
  }

  Future<int?> _createHerb({required String name, required String scientificName}) async {
    final url = Uri.parse('$_baseUrl/herb/herbs');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'name': name, 'scientificName': scientificName}),
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        if (body['code'] == 20000 && body['data'] != null) {
          return body['data']['id'];
        }
      }
      return null;
    } catch (e) {
      print('创建药材失败: $e');
      return null;
    }
  }

  /// 流程2a: 获取OSS上传策略 (逻辑不变)
  Future<Map<String, dynamic>?> getOssPolicy() async {
    final policyUrl = '$_baseUrl/oss/policy';
    try {
      final response = await http.get(Uri.parse(policyUrl));
      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        if (body['code'] == 20000) {
          return body['data'];
        }
      }
      return null;
    } catch (e) {
      print('获取OSS策略失败: $e');
      return null;
    }
  }

  /// 流程2b: 使用dio上传单个文件到OSS (逻辑不变)
  Future<String?> uploadFileToOss({
    required File file,
    required Map<String, dynamic> policy,
  }) async {
    final host = policy['host'];
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final uniqueFileName = '${timestamp}_${p.basename(file.path)}';
    final key = policy['dir'] + uniqueFileName;
    try {
      final formData = FormData.fromMap({
        'key': key,
        'policy': policy['policy'],
        'OSSAccessKeyId': policy['accessid'],
        'success_action_status': '200',
        'signature': policy['signature'],
        'file': await MultipartFile.fromFile(file.path, filename: uniqueFileName),
      });
      final response = await _dio.post(host, data: formData);
      if (response.statusCode == 200) {
        return '$host/$key';
      }
      return null;
    } on DioException catch (e) {
      print("上传文件到OSS时发生 DioException: ${e.message}");
      if (e.response != null) {
        print("OSS返回的错误数据: ${e.response?.data}");
      }
      return null;
    }
  }

  /// ✅ **新增方法**: 流程3 - 创建观测点记录
  Future<int?> createLocation(Map<String, dynamic> locationData) async {
    final url = Uri.parse('$_baseUrl/herb/locations');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(locationData),
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        if (body['code'] == 20000 && body['data'] != null) {
          return body['data']['id'];
        }
      }
      return null;
    } catch (e) {
      print('创建观测点失败: $e');
      return null;
    }
  }

  /// ✅ **新增方法**: 流程4 - 为观测点关联图片
  Future<bool> saveImagesForLocation({
    required int locationId,
    required List<Map<String, dynamic>> images,
  }) async {
    final url = Uri.parse('$_baseUrl/herb/locations/$locationId/images');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'images': images}),
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        return body['code'] == 20000;
      }
      return false;
    } catch (e) {
      print('为观测点保存图片失败: $e');
      return false;
    }
  }
}