import 'package:easy_pc/constants/app_colors.dart';
import 'package:easy_pc/models/user.dart';
import 'package:easy_pc/pages/home_page.dart';
import 'package:easy_pc/pages/register_page.dart';
import 'package:easy_pc/providers/user_provider.dart';
import 'package:easy_pc/services/user_service.dart';
import 'package:easy_pc/widgets/auth/auth_text_field.dart';
import 'package:easy_pc/widgets/auth/auth_button.dart';
import 'package:easy_pc/widgets/common/gradient_background.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _userService = const UserService();
  bool _loading = false;
  User? _user;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: GradientBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: _buildLoginCard(),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.appBarBg,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.yellow),
        onPressed: _goHome,
      ),
      actions: [
        TextButton.icon(
          onPressed: _loading ? null : _navigateToRegister,
          icon: const Icon(Icons.group_add, color: AppColors.yellow),
          label: const Text('Register', style: TextStyle(color: AppColors.yellow)),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
              validator: (v) => (v == null || v.isEmpty) ? 'Enter username' : null,
            ),
            const SizedBox(height: 14),
            AuthTextField(
              controller: _passCtrl,
              label: 'Password',
              obscureText: true,
              validator: (v) => (v == null || v.isEmpty) ? 'Enter password' : null,
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
            'Welcome to EasyPC',
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
            onPressed: _loading ? null : _login,
            loading: _loading,
            text: 'Login',
            isPrimary: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AuthButton(
            onPressed: _loading ? null : _goHome,
            text: 'Cancel',
            isPrimary: false,
          ),
        ),
      ],
    );
  }

  void _navigateToRegister() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPage()),
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

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      _user = await _userService.login(
        username: _userCtrl.text,
        password: _passCtrl.text,
      );

      if (!mounted) return;

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.setUserWithPassword(_user!, _passCtrl.text);

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    } catch (e) {
      debugPrint('Login error: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}