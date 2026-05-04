import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/l10n/auth_message_localizer.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../app_pin/domain/pin_flow_source.dart';
import '../../data/auth_repository.dart';
import '../../providers/auth_provider.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  static const _kPinLength = 6;
  static const _kTimerSeconds = 60;

  final _pinController = TextEditingController();
  final _focusNode = FocusNode();

  bool _isPinComplete = false;
  bool _isVerifying = false;
  int _secondsRemaining = _kTimerSeconds;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _pinController.addListener(_onPinChanged);
    _secondsRemaining = _kTimerSeconds;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), _onTick);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  void _onTick(Timer t) {
    if (!mounted) {
      t.cancel();
      return;
    }
    if (_secondsRemaining <= 1) {
      t.cancel();
      setState(() => _secondsRemaining = 0);
    } else {
      setState(() => _secondsRemaining--);
    }
  }

  void _onPinChanged() {
    final complete = _pinController.text.length == _kPinLength;
    if (complete != _isPinComplete) {
      setState(() => _isPinComplete = complete);
    }
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    setState(() => _secondsRemaining = _kTimerSeconds);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  Future<void> _onVerifyPressed() async {
    if (_isVerifying || !_isPinComplete) {
      return;
    }

    setState(() => _isVerifying = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .verifyOTP(widget.email, _pinController.text);
      if (!mounted) return;
      ref.invalidate(authProvider);
      context.go('/app-pin/create', extra: PinFlowSource.signup);
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
        setState(() => _isVerifying = false);
      }
    }
  }

  void _onResendPressed() {
    _pinController.clear();
    _startTimer();
    // TODO: Execute Supabase resend code here
  }

  String get _timerLabel {
    final m = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _pinController.removeListener(_onPinChanged);
    _pinController.dispose();
    _focusNode.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  // ── Design constants ────────────────────────────────────────────────────────

  static const _darkBg = Color(0xFF121417);
  static const _accentWhite = Colors.white;
  static const _dimWhite = Color(0x80FFFFFF);
  static const _inputBorder = Color(0xFF2C2F35);
  static const _activeBorder = Colors.white;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool resendEnabled = _secondsRemaining == 0;

    final defaultPinTheme = PinTheme(
      width: 52,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: _accentWhite,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2128),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _inputBorder, width: 1.5),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: _activeBorder, width: 2),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(
          color: _accentWhite.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
    );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── White top area ─────────────────────────────────────
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 24, left: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 24,
                      ),
                      splashRadius: 24,
                    ),
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 48),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              l10n.otpTitleEnterCode,
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
            ),

            // ── Dark form area ─────────────────────────────────────
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: _darkBg,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36),
                  ),
                ),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(28, 44, 28, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ── Subtitle ────────────────────────────────
                      Text(
                        l10n.otpSubtitleSentTo,
                        style: TextStyle(
                          color: _dimWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.email,
                        style: const TextStyle(
                          color: _accentWhite,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 48),

                      // ── Pinput ──────────────────────────────────
                      Pinput(
                        length: _kPinLength,
                        controller: _pinController,
                        focusNode: _focusNode,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: focusedPinTheme,
                        submittedPinTheme: submittedPinTheme,
                        onCompleted: (_) => _onVerifyPressed(),
                      ),

                      const SizedBox(height: 44),

                      // ── Verify button ───────────────────────────
                      CustomButton(
                        label: l10n.otpVerifyButton,
                        onPressed: _isPinComplete ? _onVerifyPressed : null,
                        isLoading: _isVerifying,
                      ),

                      const SizedBox(height: 32),

                      // ── Timer + Resend row ──────────────────────
                      Column(
                        children: [
                          Text(
                            resendEnabled
                                ? l10n.otpResendAvailable
                                : l10n.otpResendCountdown(_timerLabel),
                            style: TextStyle(color: _dimWhite, fontSize: 13),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: resendEnabled ? _onResendPressed : null,
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: resendEnabled
                                    ? _accentWhite
                                    : _dimWhite.withValues(alpha: 0.35),
                                decoration: resendEnabled
                                    ? TextDecoration.underline
                                    : TextDecoration.none,
                                decorationColor: _accentWhite,
                              ),
                              child: Text(l10n.otpResendCode),
                            ),
                          ),
                        ],
                      ),
                    ],
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
