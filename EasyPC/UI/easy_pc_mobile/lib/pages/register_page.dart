import 'package:easy_pc/constants/app_colors.dart';
import 'package:easy_pc/pages/home_page.dart';
import 'package:easy_pc/pages/login_page.dart';
import 'package:easy_pc/services/user_service.dart';
import 'package:easy_pc/widgets/auth/auth_text_field.dart';
import 'package:easy_pc/widgets/auth/auth_button.dart';
import 'package:easy_pc/widgets/common/gradient_background.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _userService = const UserService();
  bool _loading = false;

  @override
  void dispose() {
    _userCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: GradientBackground(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: _buildRegisterCard(),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.appBarBg,
      leading: IconButton(
        onPressed: _goHome,
        icon: const Icon(Icons.arrow_back, color: AppColors.yellow),
        tooltip: 'Back',
      ),
      actions: [
        TextButton.icon(
          onPressed: _loading ? null : _navigateToLogin,
          icon: const Icon(Icons.login, color: AppColors.yellow),
          label: const Text('Login', style: TextStyle(color: AppColors.yellow)),
        ),
      ],
    );
  }

  Widget _buildRegisterCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _userCtrl,
              label: 'Username',
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Enter username' : null,
            ),
            const SizedBox(height: 14),
            AuthTextField(
              controller: _emailCtrl,
              label: 'Email',
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter email';
                final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v);
                return ok ? null : 'Enter valid email';
              },
            ),
            const SizedBox(height: 14),
            AuthTextField(
              controller: _passCtrl,
              label: 'Password',
              obscureText: true,
              validator: (v) =>
                  (v == null || v.length < 6) ? 'Min 6 characters' : null,
            ),
            const SizedBox(height: 14),
            AuthTextField(
              controller: _confirmCtrl,
              label: 'Confirm Password',
              obscureText: true,
              validator: (v) =>
                  (v != _passCtrl.text) ? 'Passwords do not match' : null,
            ),
            const SizedBox(height: 18),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Create an Account',
            style: TextStyle(
              color: AppColors.yellow,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        IconButton(
          onPressed: _goHome,
          icon: const Icon(Icons.close, color: AppColors.yellow, size: 18),
          tooltip: 'Close',
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: AuthButton(
            onPressed: _loading ? null : _register,
            loading: _loading,
            text: 'Register',
            isPrimary: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AuthButton(
            onPressed: _loading ? null : () => Navigator.of(context).maybePop(),
            text: 'Cancel',
            isPrimary: false,
          ),
        ),
      ],
    );
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void _goHome() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  Future<void> _register() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _loading = true);

  try {
    final message = await _userService.register(
      username: _userCtrl.text,
      password: _passCtrl.text,
      email: _emailCtrl.text,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  } catch (e) {
    debugPrint('Register error: $e');
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  } finally {
    if (mounted) setState(() => _loading = false);
  }
}
}