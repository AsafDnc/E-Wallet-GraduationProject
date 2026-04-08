import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _revealPassword = false;
  bool _revealConfirmPassword = false;

  Timer? _errorTimer;
  static const _kErrorDuration = Duration(seconds: 3);

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _errorTimer?.cancel();
    super.dispose();
  }

  Future<void> _onSignUpPressed() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      _startErrorTimer();
      return;
    }

    await ref
        .read(authProvider.notifier)
        .signUp(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SignUpHeader(),
            Expanded(
              child: _SignUpFormSection(
                formKey: _formKey,
                firstNameController: _firstNameController,
                lastNameController: _lastNameController,
                emailController: _emailController,
                passwordController: _passwordController,
                confirmPasswordController: _confirmPasswordController,
                revealPassword: _revealPassword,
                revealConfirmPassword: _revealConfirmPassword,
                onPasswordEyeDown: () => setState(() => _revealPassword = true),
                onPasswordEyeUp: () => setState(() => _revealPassword = false),
                onConfirmPasswordEyeDown: () =>
                    setState(() => _revealConfirmPassword = true),
                onConfirmPasswordEyeUp: () =>
                    setState(() => _revealConfirmPassword = false),
                isLoading: authState.isLoading,
                onSignUpPressed: _onSignUpPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _SignUpHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 24, left: 8),
        child: Row(
          children: [
            IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
              splashRadius: 24,
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 48),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
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

class _SignUpFormSection extends StatelessWidget {
  const _SignUpFormSection({
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.revealPassword,
    required this.revealConfirmPassword,
    required this.onPasswordEyeDown,
    required this.onPasswordEyeUp,
    required this.onConfirmPasswordEyeDown,
    required this.onConfirmPasswordEyeUp,
    required this.isLoading,
    required this.onSignUpPressed,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool revealPassword;
  final bool revealConfirmPassword;
  final VoidCallback onPasswordEyeDown;
  final VoidCallback onPasswordEyeUp;
  final VoidCallback onConfirmPasswordEyeDown;
  final VoidCallback onConfirmPasswordEyeUp;
  final bool isLoading;
  final VoidCallback onSignUpPressed;

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
        padding: const EdgeInsets.fromLTRB(28, 36, 28, 40),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              CustomTextField(
                label: 'First Name',
                hintText: 'Jimmy',
                controller: firstNameController,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),
              CustomTextField(
                label: 'Last Name',
                hintText: 'Cook',
                controller: lastNameController,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),
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
              const SizedBox(height: 22),
              CustomTextField(
                label: 'Password',
                hintText: '* * * * * * * * *',
                controller: passwordController,
                obscureText: !revealPassword,
                textInputAction: TextInputAction.next,
                suffixIcon: GestureDetector(
                  onTapDown: (_) => onPasswordEyeDown(),
                  onTapUp: (_) => onPasswordEyeUp(),
                  onTapCancel: onPasswordEyeUp,
                  child: Icon(
                    revealPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.white38,
                    size: 22,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),
              CustomTextField(
                label: 'Confirm Password',
                hintText: '* * * * * * * * *',
                controller: confirmPasswordController,
                obscureText: !revealConfirmPassword,
                textInputAction: TextInputAction.done,
                suffixIcon: GestureDetector(
                  onTapDown: (_) => onConfirmPasswordEyeDown(),
                  onTapUp: (_) => onConfirmPasswordEyeUp(),
                  onTapCancel: onConfirmPasswordEyeUp,
                  child: Icon(
                    revealConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.white38,
                    size: 22,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              CustomButton(
                label: 'Sign Up',
                onPressed: onSignUpPressed,
                isLoading: isLoading,
              ),
              const SizedBox(height: 24),
              _SignInPrompt(),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sign-in prompt
// ---------------------------------------------------------------------------

class _SignInPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pop(),
      child: Text.rich(
        TextSpan(
          text: 'Already have an account? ',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 13,
          ),
          children: const [
            TextSpan(
              text: 'Sign In',
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
