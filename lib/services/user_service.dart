// lib/services/user_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:demo_conut/data/models/user.dart';

class UserService {
  final String _baseUrl = 'http://192.168.68.3:81/api/users';

  // --- 本地存储键 ---
  static const String _tokenKey = 'auth_token';
  static const String _loggedInUserKey = 'loggedInUser';
  // ✅ **新增**: 用于暂存注册时额外信息的键
  static const String _tempUserInfoKey = 'temp_user_info';


  /// 注册新用户
  Future<Map<String, dynamic>> register(String username, String password, String realName, String email) async {
    final url = Uri.parse('$_baseUrl/register');
    try {
      // ✅ **步骤 1**: 在发起网络请求前，先将真实姓名和邮箱暂存本地
      // 这样即使用户关闭App，这些信息也能保留，直到下次登录
      final prefs = await SharedPreferences.getInstance();
      final tempInfo = jsonEncode({'realName': realName, 'email': email});
      await prefs.setString(_tempUserInfoKey, tempInfo);

      // 发起后端注册请求（只包含用户名和密码）
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'username': username,
          'passwordHash': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        if (responseBody['code'] == 20011) {
          return {'success': true, 'message': responseBody['msg'] ?? '注册成功'};
        } else {
          // 如果后端注册失败，清除刚才的暂存信息
          await prefs.remove(_tempUserInfoKey);
          return {'success': false, 'message': responseBody['msg'] ?? '注册失败'};
        }
      } else {
        // 如果网络请求失败，也清除暂存信息
        await prefs.remove(_tempUserInfoKey);
        return {'success': false, 'message': '服务器错误: ${response.statusCode}'};
      }
    } catch (e) {
      print('Register request error: $e');
      // 发生异常时也清除暂存信息
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tempUserInfoKey);
      return {'success': false, 'message': '网络请求失败: $e'};
    }
  }

  /// 用户登录
  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$_baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'username': username,
          'passwordHash': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(utf8.decode(response.bodyBytes));

        if (responseBody['code'] == 20051) {
          final token = responseBody['data']?['token'];

          if(token != null) {
            // ✅ **步骤 2**: 登录成功后，检查是否存在暂存的个人信息
            final prefs = await SharedPreferences.getInstance();
            final tempInfoJson = prefs.getString(_tempUserInfoKey);

            String realName = '加载中...';
            String email = '加载中...';

            if (tempInfoJson != null) {
              final tempInfo = jsonDecode(tempInfoJson);
              realName = tempInfo['realName'];
              email = tempInfo['email'];
              // ✅ **步骤 3**: 使用后立即清除暂存信息，避免污染其他账号
              await prefs.remove(_tempUserInfoKey);
            }

            // 创建包含完整信息的User对象
            final finalUser = User(
                userName: username,
                passwordHash: '',
                realName: realName,
                email: email
            );

            await _saveLoginInfo(token, finalUser);
            return {'success': true, 'message': '登录成功'};
          }
          return {'success': false, 'message': '登录成功，但未获取到Token'};
        } else {
          return {'success': false, 'message': responseBody['msg'] ?? '登录失败'};
        }
      } else {
        return {'success': false, 'message': '服务器连接失败: ${response.statusCode}'};
      }
    } catch (e) {
      print('Login request error: $e');
      return {'success': false, 'message': '网络请求异常: $e'};
    }
  }

  // ... 其余方法保持不变 ...

  /// 保存登录信息 (Token 和 用户数据)
  Future<void> _saveLoginInfo(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_loggedInUserKey, jsonEncode(user.toMap()));
  }

  /// 退出登录
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_loggedInUserKey);
    // 退出时也可以选择性清除暂存信息，以防万一
    await prefs.remove(_tempUserInfoKey);
  }

  /// 检查用户是否已登录
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey) != null;
  }

  /// 获取当前登录的用户信息
  Future<User?> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_loggedInUserKey);
    if (userJson == null) return null;
    return User.fromMap(jsonDecode(userJson));
  }

  // 更新用户信息的方法现在无需修改，因为它操作的是已经登录后的完整User对象
  Future<bool> updateUser(User updatedUser) async {
    final prefs = await SharedPreferences.getInstance();
    // 此处可以添加调用后端 /update 接口的逻辑
    // ...
    // 更新成功后，保存到本地
    await prefs.setString(_loggedInUserKey, jsonEncode(updatedUser.toMap()));
    return true; // 假设更新成功
  }
}