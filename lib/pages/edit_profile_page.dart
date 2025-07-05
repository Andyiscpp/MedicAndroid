// lib/pages/edit_profile_page.dart

import 'package:demo_conut/data/models/user.dart';
import 'package:demo_conut/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:demo_conut/pages/home_page.dart';

class EditProfilePage extends StatefulWidget {
  final User user;
  const EditProfilePage({super.key, required this.user});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nicknameController;
  late TextEditingController _bioController;
  String? _selectedGender;
  final UserService _userService = UserService();
  bool _isSaving = false;
  late String _roleText;
  late String _username;
  late String _email;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.user.nickname ?? '');
    _bioController = TextEditingController(text: widget.user.bio ?? '');
    _selectedGender = widget.user.gender ?? 'unknown';
    _username = widget.user.username;
    _email = widget.user.email ?? '未设置';
    _roleText = _getRoleText(widget.user.role);
  }

  String _getRoleText(int? role) {
    switch (role) {
      case 0: return '管理员';
      case 1: return '学生';
      case 2: return '老师';
      default: return '未知';
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;
    setState(() => _isSaving = true);

    final userWithChanges = widget.user.copyWith(
      nickname: _nicknameController.text,
      bio: _bioController.text,
      gender: _selectedGender,
    );

    // 调用 updateUser，它现在返回布尔值
    final success = await _userService.updateUser(userWithChanges);

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        showToast('个人资料已更新');
        // 【关键修复】成功后，返回布尔值 true 作为需要刷新的信号
        Navigator.pop(context, true);
      } else {
        showToast('更新失败，请稍后重试。');
      }
    }
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
        title: const Text('编辑资料', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          _isSaving
              ? const Padding(padding: EdgeInsets.all(16.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
              : IconButton(icon: const Icon(Icons.save_outlined), onPressed: _saveProfile, tooltip: '保存'),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              _buildReadOnlyInfoCard(),
              const SizedBox(height: 24),
              _buildEditableInfoCard(),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                onPressed: _isSaving ? null : _saveProfile,
                label: Text(_isSaving ? '正在保存...' : '确认保存'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyInfoCard() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("账户信息 (不可修改)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const Divider(height: 20),
            _buildReadOnlyField(Icons.person_outline, "用户名", _username),
            //_buildReadOnlyField(Icons.email_outlined, "邮箱", _email),
            _buildReadOnlyField(Icons.school_outlined, "角色", _roleText),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableInfoCard() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("个人资料 (可修改)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const Divider(height: 20),
            TextFormField(
              controller: _nicknameController,
              decoration: const InputDecoration(labelText: '昵称', border: OutlineInputBorder(), prefixIcon: Icon(Icons.badge_outlined)),
              validator: (value) => (value == null || value.isEmpty) ? '请输入您的昵称' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(labelText: '性别', border: OutlineInputBorder(), prefixIcon: Icon(Icons.transgender_outlined)),
              items: const [
                DropdownMenuItem(value: 'male', child: Text('男')),
                DropdownMenuItem(value: 'female', child: Text('女')),
                DropdownMenuItem(value: 'unknown', child: Text('未设置')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(labelText: '个人简介', hintText: '介绍一下自己吧...', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person_pin_outlined)),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 16),
          Text("$label:", style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}