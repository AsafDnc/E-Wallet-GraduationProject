import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/auth_message_localizer.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../data/auth_repository.dart';
import '../otp/otp_verification_screen.dart';

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
  bool _allFieldsFilled = false;
  bool _isSigningUp = false;

  Timer? _errorTimer;
  static const _kErrorDuration = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    for (final c in [
      _firstNameController,
      _lastNameController,
      _emailController,
      _passwordController,
      _confirmPasswordController,
    ]) {
      c.addListener(_checkFields);
    }
  }

  void _checkFields() {
    final filled =
        _firstNameController.text.trim().isNotEmpty &&
        _lastNameController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty;
    if (filled != _allFieldsFilled) {
      setState(() => _allFieldsFilled = filled);
    }
  }

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

  static const _kOtpSlideDuration = Duration(milliseconds: 380);

  void _navigateToOtpWithSlide(String email) {
    Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        transitionDuration: _kOtpSlideDuration,
        reverseTransitionDuration: _kOtpSlideDuration,
        pageBuilder: (context, animation, secondaryAnimation) {
          return OtpVerificationScreen(email: email);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          );
          final slide = Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curved);
          return SlideTransition(position: slide, child: child);
        },
      ),
    );
  }

  Future<void> _onSignUpPressed() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      _startErrorTimer();
      return;
    }

    setState(() => _isSigningUp = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .signUp(
            _emailController.text.trim(),
            _passwordController.text,
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
          );
      if (!mounted) return;
      _navigateToOtpWithSlide(_emailController.text.trim());
    } on AuthRepositoryException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            l10n.localizeAuthUserMessage(e.message),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSigningUp = false);
      }
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
                isLoading: _isSigningUp,
                // Button is only active when all fields have text.
                onSignUpPressed: _allFieldsFilled ? _onSignUpPressed : null,
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
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 24, left: 8),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
              splashRadius: 24,
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 48),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      l10n.signUpTitle,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                        letterSpacing: 0.3,
                      ),
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

  /// Null when not all fields are filled — disables the button.
  final VoidCallback? onSignUpPressed;

  static const _darkBg = Color(0xFF121417);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                label: l10n.fieldFirstName,
                hintText: l10n.hintFirstNameExample,
                controller: firstNameController,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.validationFirstNameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),
              CustomTextField(
                label: l10n.fieldLastName,
                hintText: l10n.hintLastNameExample,
                controller: lastNameController,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.validationLastNameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),
              CustomTextField(
                label: l10n.fieldEmail,
                hintText: l10n.hintEmailExample,
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.validationEmailRequired;
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
                    return l10n.validationEmailInvalid;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),
              CustomTextField(
                label: l10n.fieldPassword,
                hintText: l10n.hintPasswordDots,
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
                    return l10n.validationSignupPasswordEmpty;
                  }
                  if (value.length < 6) {
                    return l10n.validationPasswordMin;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),
              CustomTextField(
                label: l10n.fieldConfirmPassword,
                hintText: l10n.hintPasswordDots,
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
                    return l10n.validationConfirmPasswordRequired;
                  }
                  if (value != passwordController.text) {
                    return l10n.validationPasswordsMismatch;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              CustomButton(
                label: l10n.signUpButton,
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
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: Text.rich(
        TextSpan(
          text: l10n.signUpAlreadyHaveAccount,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 13,
          ),
          children: [
            TextSpan(
              text: l10n.signUpSignInAction,
              style: const TextStyle(
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
