// lib/services/user_service.dart

import 'dart:convert';
import 'dart:io'; // 用于捕获 SocketException
import 'dart:async'; // 用于超时
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:demo_conut/data/models/user.dart';

class UserService {
  final String _baseUrl = 'http://192.168.68.3:81/api/users';

  static const String _tokenKey = 'auth_token';
  static const String _loggedInUserKey = 'loggedInUser';

  /// [调试版] 从后端获取用户信息
  Future<User?> fetchAndSaveUserProfile() async {
    print("--- [1] 开始执行 fetchAndSaveUserProfile ---");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final localUser = await getLoggedInUser();

    if (token == null) {
      print("--- [!错误!] 在 fetchAndSaveUserProfile 中未找到Token，请求终止。 ---");
      return localUser; // 返回本地缓存，即使它不完整
    }

    print("--- [2] Token已找到，准备发起网络请求... ---");
    print("--- 使用的Token: Bearer $token");

    final url = Uri.parse('$_baseUrl/userInfo');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10)); // 增加10秒超时以防万一

      print("--- [3] 网络请求已完成 ---");
      print("--- 响应状态码: ${response.statusCode} ---");
      print("--- 响应体: ${utf8.decode(response.bodyBytes)} ---");

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        if (responseBody['code'] == 20041) {
          final serverData = responseBody['data'] as Map<String, dynamic>;

          final finalUser = User.fromMap(serverData).copyWith(
            email: localUser?.email,
            passwordHash: localUser?.passwordHash,
          );

          await _saveLoginInfo(token, finalUser);
          print("--- [4] 成功！已从服务器获取并更新用户信息。 ---");
          return finalUser;
        } else {
          print("--- [!业务失败!] 后端返回错误码: ${responseBody['code']}，消息: ${responseBody['message'] ?? responseBody['msg']} ---");
        }
      } else {
        print("--- [!网络失败!] HTTP状态码不是200。 ---");
      }
      return localUser;
    } on SocketException catch (e) {
      print("--- [!致命网络错误!] SocketException: 无法连接到服务器。请检查IP地址和网络连接。 ---");
      print("--- 错误详情: $e ---");
      return localUser;
    } on TimeoutException catch (_) {
      print("--- [!致命网络错误!] TimeoutException: 连接服务器超时。 ---");
      return localUser;
    } catch (e, stackTrace) {
      print('--- [!致命解析错误!] 解析或处理用户信息时发生未知异常: $e ---');
      print(stackTrace);
      return localUser;
    }
  }

  // 其他方法保持不变
  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$_baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'username': username, 'passwordHash': password}),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        if (responseBody['code'] == 20051) {
          final token = responseBody['data']?['token'];
          if (token != null) {
            final basicUser = User(
              id: 0, // 初始ID，后续会被覆盖
              username: username,
              passwordHash: password, // 临时存储，以便在安全页面校验
            );
            await _saveLoginInfo(token, basicUser);
            return {'success': true, 'message': '登录成功'};
          }
        }
        return {'success': false, 'message': responseBody['msg'] ?? '登录失败'};
      }
      return {'success': false, 'message': '服务器连接失败: ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'message': '网络请求异常: $e'};
    }
  }

  Future<void> _saveLoginInfo(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_loggedInUserKey, jsonEncode(user.toMap()));
    print("--- 用户信息已保存到本地 ---");
  }

  Future<User?> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_loggedInUserKey);
    if (userJson == null) {
      print("--- 本地无缓存用户 ---");
      return null;
    }
    print("--- 从本地加载缓存用户 ---");
    return User.fromMap(jsonDecode(userJson));
  }

  /// 更新用户信息
  /// 【关键修复】更新用户信息，成功后返回布尔值 true
  Future<bool> updateUser(User updatedUser) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null) return false;

    final url = Uri.parse('$_baseUrl/update');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
          'X-Requested-With': 'com.example.demo_conut',
        },
        body: jsonEncode({
          'nickname': updatedUser.nickname,
          'bio': updatedUser.bio,
          'avatarUrl': updatedUser.avatarUrl,
          'gender': updatedUser.gender,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        // 假设更新接口的成功码是20000
        if (body['code'] == 20031) {
          // 更新成功后，我们不再需要在这里保存信息或返回User对象
          // 我们只返回一个成功信号
          return true;
        }
      }
      // 如果任何步骤失败，返回 false
      return false;
    } catch (e) {
      print("更新用户信息时发生异常: $e");
      return false;
    }
  }

  /// 注册
  Future<Map<String, dynamic>> register(String username, String password, String nickname, String email) async {
    final url = Uri.parse('$_baseUrl/register');
    try {
      // 在注册时，我们只发送后端需要的最少信息
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
          // 注册成功后，可以考虑自动登录或提示用户登录
          return {'success': true, 'message': responseBody['msg'] ?? '注册成功'};
        } else {
          return {'success': false, 'message': responseBody['msg'] ?? '注册失败'};
        }
      }
      return {'success': false, 'message': '服务器错误: ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'message': '网络请求失败: $e'};
    }
  }

  /// 【关键修复】退出登录，清除所有本地凭证
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    // 彻底清除Token和缓存的用户信息
    await prefs.remove(_tokenKey);
    await prefs.remove(_loggedInUserKey);
  }

  /// 检查是否登录
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey) != null;
  }

  /// 修改密码
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String rePassword,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null) {
      return {'success': false, 'message': '用户未登录'};
    }

    final url = Uri.parse('$_baseUrl/updatePwd');
    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
          'X-Requested-With': 'com.example.demo_conut',
        },
        body: jsonEncode({
          'old_pwd': oldPassword,
          'new_pwd': newPassword,
          're_pwd': rePassword,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        // 根据后端 UserContorller 的逻辑，成功码是 UPDATE_OK (20021)
        if (body['code'] == 20021) {
          return {'success': true, 'message': body['msg'] ?? '密码修改成功'};
        } else {
          return {'success': false, 'message': body['msg'] ?? '密码修改失败'};
        }
      }
      return {'success': false, 'message': '服务器错误: ${response.statusCode}'};
    } catch (e) {
      print("修改密码时发生异常: $e");
      return {'success': false, 'message': '网络请求异常'};
    }
  }

}