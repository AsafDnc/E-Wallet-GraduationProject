import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Swapping the key forces a fresh Form widget (clears error text) while
  // leaving the controllers — and therefore the user's input — untouched.
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _revealPassword = false;

  Timer? _errorTimer;
  static const _kErrorDuration = Duration(seconds: 3);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _errorTimer?.cancel();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      _startErrorTimer();
      return;
    }

    await ref
        .read(authProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;
    final authState = ref.read(authProvider);
    if (authState.status == AuthStatus.success) {
      context.go('/home');
    } else if (authState.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.errorMessage!),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _startErrorTimer() {
    _errorTimer?.cancel();
    _errorTimer = Timer(_kErrorDuration, () {
      if (!mounted) return;
      // Replace the Form key → Flutter discards the old Form and builds a
      // fresh one. Error text vanishes; controllers keep their values.
      setState(() => _formKey = GlobalKey<FormState>());
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _WelcomeSection(),
            Expanded(
              child: _LoginFormSection(
                formKey: _formKey,
                emailController: _emailController,
                passwordController: _passwordController,
                obscurePassword: !_revealPassword,
                onPasswordEyeDown: () => setState(() => _revealPassword = true),
                onPasswordEyeUp: () => setState(() => _revealPassword = false),
                isLoading: authState.isLoading,
                onLoginPressed: _onLoginPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Welcome header (white area)
// ---------------------------------------------------------------------------

class _WelcomeSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 40, bottom: 32),
        child: Column(
          children: const [
            Text(
              'Welcome',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w300,
                color: Colors.black,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'E - Wallet',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dark form container
// ---------------------------------------------------------------------------

class _LoginFormSection extends StatelessWidget {
  const _LoginFormSection({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onPasswordEyeDown,
    required this.onPasswordEyeUp,
    required this.isLoading,
    required this.onLoginPressed,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onPasswordEyeDown;
  final VoidCallback onPasswordEyeUp;
  final bool isLoading;
  final VoidCallback onLoginPressed;

  static const _darkBg = Color(0xFF121417);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: _darkBg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
      ),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(28, 36, 28, 32),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 72),
              CustomTextField(
                label: 'Email',
                hintText: 'example@gmail.com',
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Password: hold eye icon to reveal, release to hide again.
              CustomTextField(
                label: 'Password',
                hintText: '* * * * * * * * *',
                controller: passwordController,
                obscureText: obscurePassword,
                textInputAction: TextInputAction.done,
                suffixIcon: GestureDetector(
                  onTapDown: (_) => onPasswordEyeDown(),
                  onTapUp: (_) => onPasswordEyeUp(),
                  onTapCancel: onPasswordEyeUp,
                  child: Icon(
                    obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.white38,
                    size: 22,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),
              CustomButton(
                label: 'Login',
                onPressed: onLoginPressed,
                isLoading: isLoading,
              ),
              const SizedBox(height: 28),
              _OrDivider(),
              const SizedBox(height: 24),
              _SocialLoginRow(),
              const SizedBox(height: 28),
              _SignUpPrompt(),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Supporting widgets
// ---------------------------------------------------------------------------

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.white.withValues(alpha: 0.2),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.white.withValues(alpha: 0.2),
            thickness: 1,
          ),
        ),
      ],
    );
  }
}

class _SocialLoginRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialIconButton(icon: Icons.g_mobiledata_rounded, onTap: () {}),
        const SizedBox(width: 16),
        _SocialIconButton(icon: Icons.apple, onTap: () {}),
        const SizedBox(width: 16),
        _SocialIconButton(icon: Icons.close_rounded, onTap: () {}),
        const SizedBox(width: 16),
        _SocialIconButton(icon: Icons.code_rounded, onTap: () {}),
      ],
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  const _SocialIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: Colors.black, size: 28),
      ),
    );
  }
}

class _SignUpPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/signup'),
      child: Text.rich(
        TextSpan(
          text: "Don't have any account ? ",
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 13,
          ),
          children: const [
            TextSpan(
              text: 'Sign Up',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
