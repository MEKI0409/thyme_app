// pages/profile_settings_page.dart
// 个人资料设置页面 👤
// ✅ 编辑头像、昵称，查看邮箱
// ✅ FIXED (v2): initState 中的 context.read 移到 didChangeDependencies

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/auth_controller.dart';
import '../controllers/settings_controller.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();
  bool _isEditingName = false;
  String? _originalName;
  String? _selectedAvatar; // ✅ NEW: 本地头像状态，避免依赖异步 Auth 刷新
  bool _isInitialized = false; // ✅ FIXED (v2): 防止 didChangeDependencies 重复初始化

  // 可选头像列表（emoji 方式，无需文件上传）
  static const List<String> _avatarEmojis = [
    '🌱', '🌿', '🌸', '🌻', '🌺', '🌳',
    '🦋', '🐰', '🐱', '🐶', '🌙', '⭐',
    '🍀', '🌈', '💚', '🌊', '🎨', '🎵',
  ];

  // ✅ FIXED (v2): 移到 didChangeDependencies，安全使用 context
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      final userModel = context.read<AuthController>().userModel;
      final user = FirebaseAuth.instance.currentUser;
      _originalName = userModel?.displayName ?? user?.displayName ?? '';
      _nameController.text = _originalName!;

      // ✅ 初始化头像：从 Firebase Auth 读取
      final photoUrl = user?.photoURL;
      if (photoUrl != null && photoUrl.startsWith('emoji:')) {
        _selectedAvatar = photoUrl.replaceFirst('emoji:', '');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final settingsController = context.watch<SettingsController>();
    final user = FirebaseAuth.instance.currentUser;
    final userModel = authController.userModel;

    final displayName = userModel?.displayName ?? user?.displayName ?? 'Thyme User';
    final email = user?.email ?? '';
    final isVerified = user?.emailVerified ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF5),
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF2D3B2D),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // ═══════════════════════════════════════════
          // 头像区域
          // ═══════════════════════════════════════════
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _showAvatarPicker(context),
                  child: Stack(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF4DB6AC).withOpacity(0.12),
                          border: Border.all(
                            color: const Color(0xFF4DB6AC).withOpacity(0.3),
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _getAvatarDisplay(user, displayName),
                            style: const TextStyle(fontSize: 38),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4DB6AC),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap to change avatar',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF2D3B2D).withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ═══════════════════════════════════════════
          // 昵称编辑
          // ═══════════════════════════════════════════
          _buildSectionLabel('Display Name'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _nameController,
              focusNode: _nameFocusNode,
              maxLength: 30,
              onChanged: (_) {
                setState(() {
                  _isEditingName = _nameController.text.trim() != _originalName;
                });
              },
              decoration: InputDecoration(
                hintText: 'Your display name',
                hintStyle: TextStyle(
                  color: const Color(0xFF2D3B2D).withOpacity(0.3),
                ),
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                border: InputBorder.none,
              ),
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF2D3B2D),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // ✅ 保存按钮（名字有变更时显示）
          if (_isEditingName) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: settingsController.isLoading
                    ? null
                    : () => _saveName(settingsController),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4DB6AC),
                  disabledBackgroundColor: const Color(0xFF4DB6AC).withOpacity(0.5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: settingsController.isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // ═══════════════════════════════════════════
          // 邮箱（只读）
          // ═══════════════════════════════════════════
          _buildSectionLabel('Email'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildInfoRow('Email', email, '📧'),
                const SizedBox(height: 8),
                const Divider(height: 1, color: Color(0xFFF0F4F0)),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Status',
                  isVerified ? 'Verified ✅' : 'Not verified ⚠️',
                  '🔐',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ═══════════════════════════════════════════
          // 账户信息
          // ═══════════════════════════════════════════
          _buildSectionLabel('Account Info'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  'Joined',
                  _formatDate(userModel?.createdAt ?? user?.metadata.creationTime),
                  '📅',
                ),
                const SizedBox(height: 8),
                const Divider(height: 1, color: Color(0xFFF0F4F0)),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Last active',
                  _formatDate(user?.metadata.lastSignInTime),
                  '🕐',
                ),
              ],
            ),
          ),

          // 错误/成功信息
          if (settingsController.errorMessage != null) ...[
            const SizedBox(height: 16),
            _buildMessageBanner(
              settingsController.errorMessage!,
              isError: true,
            ),
          ],
          if (settingsController.successMessage != null) ...[
            const SizedBox(height: 16),
            _buildMessageBanner(
              settingsController.successMessage!,
              isError: false,
            ),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 操作
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _saveName(SettingsController controller) async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    controller.clearMessages();
    final success = await controller.updateDisplayName(newName);
    if (success) {
      setState(() {
        _originalName = newName;
        _isEditingName = false;
      });
      _nameFocusNode.unfocus();

      // ✅ 通知 AuthController 刷新，确保其他页面也能看到新名字
      if (mounted) {
        await context.read<AuthController>().reloadUser();
      }

      // 自动清除成功消息
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) controller.clearSuccess();
      });
    }
  }

  void _showAvatarPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: const Color(0xFFF8FAF5),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF2D3B2D).withOpacity(0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Choose Your Avatar 🌿',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3B2D),
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _avatarEmojis.length,
              itemBuilder: (_, index) {
                final emoji = _avatarEmojis[index];
                final isSelected = _selectedAvatar == emoji; // ✅ 高亮当前选中
                return GestureDetector(
                  onTap: () async {
                    Navigator.pop(ctx);
                    // ✅ 先更新本地状态，UI 立即响应
                    setState(() {
                      _selectedAvatar = emoji;
                    });
                    // ✅ FIXED (v4): 在 async 操作前捕获 controller 引用
                    // 即使 widget 被 unmount，保存和刷新仍能完成
                    final settingsCtrl = context.read<SettingsController>();
                    final authCtrl = context.read<AuthController>();
                    await settingsCtrl.updatePhotoUrl('emoji:$emoji');
                    await authCtrl.reloadUser();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF4DB6AC).withOpacity(0.15)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: isSelected
                          ? Border.all(color: const Color(0xFF4DB6AC), width: 2)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 26)),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UI 组件
  // ═══════════════════════════════════════════════════════════════════════════

  String _getAvatarDisplay(User? user, String displayName) {
    // ✅ 优先使用本地状态（即时响应）
    if (_selectedAvatar != null) {
      return _selectedAvatar!;
    }
    // 再尝试从 Auth 读取
    final photoUrl = user?.photoURL;
    if (photoUrl != null && photoUrl.startsWith('emoji:')) {
      return photoUrl.replaceFirst('emoji:', '');
    }
    // 默认显示名字首字母或种子 emoji
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '🌱';
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2D3B2D).withOpacity(0.45),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, String emoji) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFF2D3B2D).withOpacity(0.6),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3B2D),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBanner(String message, {required bool isError}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isError
            ? const Color(0xFFFFEBEE)
            : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
            size: 18,
            color: isError ? const Color(0xFFE57373) : const Color(0xFF4DB6AC),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: isError ? const Color(0xFFC62828) : const Color(0xFF2E7D32),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month]} ${date.day}, ${date.year}';
  }
}