// pages/privacy_security_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/settings_controller.dart';

class PrivacySecurityPage extends StatefulWidget {
  const PrivacySecurityPage({super.key});

  @override
  State<PrivacySecurityPage> createState() => _PrivacySecurityPageState();
}

class _PrivacySecurityPageState extends State<PrivacySecurityPage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _isPasswordSectionExpanded = false;

  final _deletePasswordController = TextEditingController();
  bool _showDeletePassword = false;
  bool _deleteConfirmed = false;

  bool _isCheckingVerification = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _deletePasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SettingsController>();

    final authController = context.watch<AuthController>();
    final isVerified = authController.isEmailVerified;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF5),
      appBar: AppBar(
        title: const Text(
          'Privacy & Security',
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
          _buildEmailVerificationCard(controller, authController, isVerified),
          const SizedBox(height: 16),
          _buildChangePasswordCard(controller),
          const SizedBox(height: 24),
          _buildSectionLabel('Danger Zone'),
          const SizedBox(height: 8),
          _buildDeleteAccountCard(controller),

          if (controller.errorMessage != null) ...[
            const SizedBox(height: 16),
            _buildMessageBanner(controller.errorMessage!, isError: true),
          ],
          if (controller.successMessage != null) ...[
            const SizedBox(height: 16),
            _buildMessageBanner(controller.successMessage!, isError: false),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }


  Widget _buildEmailVerificationCard(
      SettingsController controller,
      AuthController authController,
      bool isVerified,
      ) {
    final email = authController.currentUser?.email ?? '';

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isVerified
                      ? const Color(0xFF4DB6AC).withOpacity(0.12)
                      : const Color(0xFFFFB74D).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isVerified
                      ? Icons.mark_email_read_outlined
                      : Icons.email_outlined,
                  color: isVerified
                      ? const Color(0xFF4DB6AC)
                      : const Color(0xFFFFB74D),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Email Verification',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3B2D),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF2D3B2D).withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isVerified
                      ? const Color(0xFF4DB6AC).withOpacity(0.1)
                      : const Color(0xFFFFB74D).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isVerified ? '✅ Verified' : '⚠️ Unverified',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isVerified
                        ? const Color(0xFF4DB6AC)
                        : const Color(0xFFFFB74D),
                  ),
                ),
              ),
            ],
          ),

          if (!isVerified) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.isLoading
                        ? null
                        : () async {
                      controller.clearMessages();
                      final success =
                      await authController.sendEmailVerification();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Verification email sent! Check your inbox 📧'
                                : 'Failed to send. Please try again.',
                          ),
                          backgroundColor: success
                              ? const Color(0xFF4DB6AC)
                              : const Color(0xFFE57373),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    },
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: const Text('Send Verification'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4DB6AC),
                      side: const BorderSide(
                          color: Color(0xFF4DB6AC), width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: _isCheckingVerification
                      ? null
                      : () async {
                    setState(() => _isCheckingVerification = true);

                    await authController.reloadUser();
                    final verified = authController.isEmailVerified;

                    setState(() => _isCheckingVerification = false);

                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          verified
                              ? 'Email verified! 🎉'
                              : 'Not verified yet. Check your inbox~',
                        ),
                        backgroundColor: verified
                            ? const Color(0xFF4DB6AC)
                            : const Color(0xFFFFB74D),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  icon: _isCheckingVerification
                      ? const SizedBox(
                    width: 14,
                    height: 14,
                    child:
                    CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Check'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF90A4AE),
                    side: const BorderSide(color: Color(0xFFB0BEC5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 12),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }


  Widget _buildChangePasswordCard(SettingsController controller) {
    return Container(
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
          ListTile(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF7986CB).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                color: Color(0xFF7986CB),
                size: 22,
              ),
            ),
            title: const Text(
              'Change Password',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3B2D),
              ),
            ),
            subtitle: Text(
              'Update your account password',
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFF2D3B2D).withOpacity(0.5),
              ),
            ),
            trailing: AnimatedRotation(
              turns: _isPasswordSectionExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.expand_more_rounded,
                color: const Color(0xFF2D3B2D).withOpacity(0.4),
              ),
            ),
            onTap: () => setState(() {
              _isPasswordSectionExpanded = !_isPasswordSectionExpanded;
            }),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(color: Color(0xFFF0F4F0)),
                  const SizedBox(height: 12),
                  _buildPasswordField(
                    controller: _currentPasswordController,
                    label: 'Current Password',
                    showPassword: _showCurrentPassword,
                    onToggle: () => setState(
                            () => _showCurrentPassword = !_showCurrentPassword),
                  ),
                  const SizedBox(height: 12),
                  _buildPasswordField(
                    controller: _newPasswordController,
                    label: 'New Password',
                    showPassword: _showNewPassword,
                    onToggle: () =>
                        setState(() => _showNewPassword = !_showNewPassword),
                  ),
                  const SizedBox(height: 12),
                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    label: 'Confirm New Password',
                    showPassword: _showNewPassword,
                    onToggle: null,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isLoading
                          ? null
                          : () => _changePassword(controller),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7986CB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: controller.isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        'Update Password',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState: _isPasswordSectionExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool showPassword,
    VoidCallback? onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: !showPassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 14,
          color: const Color(0xFF2D3B2D).withOpacity(0.5),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAF5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: Color(0xFF7986CB), width: 1.5),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: onToggle != null
            ? IconButton(
          onPressed: onToggle,
          icon: Icon(
            showPassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: const Color(0xFF90A4AE),
            size: 20,
          ),
        )
            : null,
      ),
      style: const TextStyle(fontSize: 14, color: Color(0xFF2D3B2D)),
    );
  }

  Widget _buildDeleteAccountCard(SettingsController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEF9A9A).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF9A9A).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.delete_forever_outlined,
                  color: Color(0xFFE57373),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delete Account',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE57373),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'This action cannot be undone',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFE57373),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Deleting your account will permanently remove all your data including habits, mood entries, garden progress, and kindness records.',
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFF2D3B2D).withOpacity(0.6),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showDeleteAccountDialog(controller),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE57373),
                side: const BorderSide(color: Color(0xFFEF9A9A)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Delete My Account',
                style:
                TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _changePassword(SettingsController controller) async {
    controller.clearMessages();

    final current = _currentPasswordController.text;
    final newPass = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        _buildSnackBar('Please fill in all fields', isError: true),
      );
      return;
    }

    if (newPass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        _buildSnackBar('New passwords do not match', isError: true),
      );
      return;
    }

    final success = await controller.changePassword(
      currentPassword: current,
      newPassword: newPass,
    );

    if (success && mounted) {
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      setState(() => _isPasswordSectionExpanded = false);

      ScaffoldMessenger.of(context).showSnackBar(
        _buildSnackBar('Password updated~ 🔒', isError: false),
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) controller.clearSuccess();
      });
    }
  }

  void _showDeleteAccountDialog(SettingsController controller) {
    _deletePasswordController.clear();
    _deleteConfirmed = false;
    _showDeletePassword = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Text('⚠️ '),
              Text(
                'Delete Account',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE57373),
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This will permanently delete your account and all data. Your garden, habits, and memories will be gone forever.',
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF2D3B2D).withOpacity(0.7),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _deletePasswordController,
                obscureText: !_showDeletePassword,
                decoration: InputDecoration(
                  labelText: 'Enter your password to confirm',
                  labelStyle: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF2D3B2D).withOpacity(0.5),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAF5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xFFE57373), width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  suffixIcon: IconButton(
                    onPressed: () => setDialogState(() {
                      _showDeletePassword = !_showDeletePassword;
                    }),
                    icon: Icon(
                      _showDeletePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF90A4AE),
                      size: 20,
                    ),
                  ),
                ),
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF2D3B2D)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _deleteConfirmed,
                      onChanged: (v) => setDialogState(() {
                        _deleteConfirmed = v ?? false;
                      }),
                      activeColor: const Color(0xFFE57373),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'I understand this action cannot be undone',
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFF2D3B2D).withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: const Color(0xFF2D3B2D).withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: _deleteConfirmed &&
                  _deletePasswordController.text.isNotEmpty
                  ? () async {
                Navigator.pop(ctx);
                controller.clearMessages();
                await controller
                    .deleteAccount(_deletePasswordController.text);
                // 成功则 auth state 自动跳转登录页
              }
                  : null,
              child: Text(
                'Delete Forever',
                style: TextStyle(
                  color: _deleteConfirmed
                      ? const Color(0xFFE57373)
                      : const Color(0xFFE57373).withOpacity(0.3),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UI 輔助

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFE57373).withOpacity(0.7),
          letterSpacing: 0.8,
        ),
      ),
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
            isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            size: 18,
            color: isError
                ? const Color(0xFFE57373)
                : const Color(0xFF4DB6AC),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: isError
                    ? const Color(0xFFC62828)
                    : const Color(0xFF2E7D32),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  SnackBar _buildSnackBar(String message, {required bool isError}) {
    return SnackBar(
      content: Text(message),
      backgroundColor: isError
          ? const Color(0xFFE57373)
          : const Color(0xFF4DB6AC),
      behavior: SnackBarBehavior.floating,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    );
  }
}