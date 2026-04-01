// pages/settings_page.dart
// 设置主页面 ⚙️
// ✅ ADDED: 未验证邮箱时显示温柔提示 banner

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/auth_controller.dart';
import '../controllers/settings_controller.dart';
import 'profile_settings_page.dart';
import 'notification_settings_page.dart';
import 'privacy_security_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // ✅ NEW: 控制 banner 发送中状态
  bool _isSendingVerification = false;
  bool _isInitialized = false; // ✅ FIXED (v3): 防止重复初始化

  // ✅ FIXED (v3): 从 initState 移到 didChangeDependencies，安全使用 context
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      _loadSettings();
    }
  }

  void _loadSettings() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<SettingsController>().loadSettings(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final user = authController.currentUser;
    final userModel = authController.userModel;

    // ✅ 从 AuthController 读取，reloadUser() 后自动更新
    final isEmailVerified = authController.isEmailVerified;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF5),
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF2D3B2D),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          // ═════════════════════════════════════════════
          // 用户头像卡片
          // ═════════════════════════════════════════════
          _buildProfileCard(user, userModel),

          // ✅ NEW: 未验证邮箱提示 banner（已验证则不显示）
          if (!isEmailVerified) ...[
            const SizedBox(height: 12),
            _buildVerificationBanner(authController),
          ],

          const SizedBox(height: 24),

          // ═════════════════════════════════════════════
          // 设置分组
          // ═════════════════════════════════════════════
          _buildSectionLabel('General'),
          const SizedBox(height: 8),

          _buildSettingsTile(
            icon: Icons.person_outline_rounded,
            iconColor: const Color(0xFF4DB6AC),
            title: 'Profile',
            subtitle: 'Avatar, display name, email',
            onTap: () => _navigateTo(const ProfileSettingsPage()),
          ),

          _buildSettingsTile(
            icon: Icons.notifications_none_rounded,
            iconColor: const Color(0xFFFFB74D),
            title: 'Notifications',
            subtitle: 'Reminders & alerts',
            onTap: () => _navigateTo(const NotificationSettingsPage()),
          ),

          const SizedBox(height: 24),
          _buildSectionLabel('Account'),
          const SizedBox(height: 8),

          _buildSettingsTile(
            icon: Icons.shield_outlined,
            iconColor: const Color(0xFF7986CB),
            title: 'Privacy & Security',
            subtitle: 'Password, email verification, account',
            onTap: () => _navigateTo(const PrivacySecurityPage()),
          ),

          const SizedBox(height: 24),
          _buildSectionLabel('More'),
          const SizedBox(height: 8),

          _buildSettingsTile(
            icon: Icons.info_outline_rounded,
            iconColor: const Color(0xFF90A4AE),
            title: 'About',
            subtitle: 'App version & info',
            onTap: () => _showAboutDialog(),
          ),

          const SizedBox(height: 32),

          // ═════════════════════════════════════════════
          // 登出按钮
          // ═════════════════════════════════════════════
          _buildSignOutButton(authController),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ✅ NEW: 邮箱验证提示 Banner
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildVerificationBanner(AuthController authController) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFFB74D).withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          const Text('📧', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Verify your email',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3B2D),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Secure your account with a quick verification~',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF2D3B2D).withOpacity(0.55),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // ✅ 发送中显示 loading，避免重复点击
          _isSendingVerification
              ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFFFFB74D),
            ),
          )
              : TextButton(
            onPressed: () => _sendVerificationEmail(authController),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFFB74D),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: const Color(0xFFFFB74D).withOpacity(0.5),
                ),
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Send',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ NEW: 发送验证邮件（含 mounted 检查）
  Future<void> _sendVerificationEmail(AuthController authController) async {
    setState(() => _isSendingVerification = true);

    try {
      final success = await authController.sendEmailVerification();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Verification email sent! Check your inbox~ 📧'
                : 'Already verified or failed to send.',
          ),
          backgroundColor: success
              ? const Color(0xFF4DB6AC)
              : const Color(0xFFFFB74D),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSendingVerification = false);
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UI 组件（与原版相同）
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildProfileCard(User? user, dynamic userModel) {
    final displayName =
        userModel?.displayName ?? user?.displayName ?? 'Thyme User';
    final email = user?.email ?? '';
    final photoUrl = user?.photoURL;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F5E9), Color(0xFFE0F2F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4DB6AC).withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4DB6AC).withOpacity(0.15),
              border: Border.all(
                color: const Color(0xFF4DB6AC).withOpacity(0.3),
                width: 2,
              ),
            ),
            // ✅ FIXED (v3): emoji: 开头的 photoUrl 不走 Image.network
            child: photoUrl != null && photoUrl.startsWith('emoji:')
                ? Center(
              child: Text(
                photoUrl.replaceFirst('emoji:', ''),
                style: const TextStyle(fontSize: 28),
              ),
            )
                : photoUrl != null
                ? ClipOval(
              child: Image.network(
                photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _buildAvatarFallback(displayName),
              ),
            )
                : _buildAvatarFallback(displayName),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3B2D),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF2D3B2D).withOpacity(0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _navigateTo(const ProfileSettingsPage()),
            icon: Icon(
              Icons.edit_outlined,
              color: const Color(0xFF4DB6AC).withOpacity(0.7),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '🌱';
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4DB6AC),
        ),
      ),
    );
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

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3B2D),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: const Color(0xFF2D3B2D).withOpacity(0.5),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: const Color(0xFF2D3B2D).withOpacity(0.25),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSignOutButton(AuthController authController) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextButton(
        onPressed: () => _showSignOutConfirmation(authController),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: const Color(0xFFEF9A9A).withOpacity(0.4),
            ),
          ),
        ),
        child: const Text(
          'Sign Out',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFFE57373),
          ),
        ),
      ),
    );
  }

  void _showSignOutConfirmation(AuthController authController) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Sign Out',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3B2D),
          ),
        ),
        content: const Text(
          'Are you sure you want to sign out? Your garden will be waiting for you~ 🌱',
          style: TextStyle(color: Color(0xFF546E54), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Stay',
              style: TextStyle(
                color: const Color(0xFF2D3B2D).withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              authController.signOut();
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(
                color: Color(0xFFE57373),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('🌿 '),
            Text(
              'About',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3B2D),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thyme',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4DB6AC),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: 13, color: Color(0xFF90A4AE)),
            ),
            SizedBox(height: 16),
            Text(
              'A gentle companion for building habits, tracking moods, and growing your inner garden~ 🌸',
              style: TextStyle(color: Color(0xFF546E54), height: 1.6),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Close',
              style: TextStyle(
                color: Color(0xFF4DB6AC),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateTo(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}