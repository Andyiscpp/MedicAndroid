import 'package:demo_conut/data/models/user.dart';
import 'package:demo_conut/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:demo_conut/pages/home_page.dart'; // 导入以使用AppColors

class EditProfilePage extends StatefulWidget {
  final User user;

  const EditProfilePage({super.key, required this.user});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _realNameController;
  late TextEditingController _emailController;
  late TextEditingController _locationController;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _realNameController = TextEditingController(text: widget.user.realName);
    _emailController = TextEditingController(text: widget.user.email);
    _locationController = TextEditingController(text: widget.user.location ?? '');
  }

  @override
  void dispose() {
    _realNameController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      // 创建一个新的User对象，包含更新后的信息
      final updatedUser = User(
        id: widget.user.id,
        userName: widget.user.userName,
        passwordHash: widget.user.passwordHash,
        realName: _realNameController.text,
        email: _emailController.text,
        location: _locationController.text,
      );

      final success = await _userService.updateUser(updatedUser);

      if (mounted) {
        if (success) {
          showToast('个人资料已保存');
          // 返回true，通知前一个页面需要刷新
          Navigator.pop(context, true);
        } else {
          showToast('更新失败，邮箱可能已被其他用户使用。');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑资料'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _realNameController,
                decoration: const InputDecoration(
                  labelText: '真实姓名',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge_outlined, color: AppColors.primary),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入您的真实姓名';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: '电子邮件',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary),
                ),
                validator: (value) {
                  if (value == null || !value.contains('@')) {
                    return '请输入有效的电子邮件地址';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: '所在地',
                  hintText: '例如：北京',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                onPressed: _saveProfile,
                label: const Text('保存更改'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}