import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../profile/providers/profile_providers.dart';
import '../domain/app_pin_rules.dart';
import '../providers/app_pin_repository_provider.dart';
import '../providers/pin_login_mask_notifier.dart';
import 'widgets/pin_numpad.dart';
import 'widgets/pin_shake_wrapper.dart';
import 'widgets/pin_six_digit_entry.dart';

/// Daily app unlock: masked PIN by default, visibility toggle via Riverpod.
class AppPinDailyLoginScreen extends ConsumerStatefulWidget {
  const AppPinDailyLoginScreen({super.key});

  @override
  ConsumerState<AppPinDailyLoginScreen> createState() =>
      _AppPinDailyLoginScreenState();
}

class _AppPinDailyLoginScreenState
    extends ConsumerState<AppPinDailyLoginScreen> {
  final GlobalKey<PinSixDigitEntryState> _pinKey =
      GlobalKey<PinSixDigitEntryState>();
  final GlobalKey<PinShakeWrapperState> _shakeKey =
      GlobalKey<PinShakeWrapperState>();

  bool _errorHighlight = false;
  bool _showWrongText = false;
  bool _handling = false;

  static const _darkBg = Color(0xFF121417);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(pinLoginMaskProvider.notifier).setObscured(true);
    });
  }

  Future<void> _onCompleted(String pin) async {
    if (_handling || !AppPinRules.isComplete(pin)) {
      return;
    }
    _handling = true;
    final stored = await ref.read(appPinRepositoryProvider).readPin();
    if (!mounted) return;
    if (stored == null || stored != pin) {
      setState(() {
        _errorHighlight = true;
        _showWrongText = true;
      });
      await _shakeKey.currentState?.shake();
      if (!mounted) return;
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      setState(() {
        _errorHighlight = false;
        _showWrongText = false;
      });
      _pinKey.currentState?.clearAll();
      _handling = false;
      return;
    }

    if (mounted) {
      context.go('/home');
    }
    _handling = false;
  }

  void _onResetTap() {
    final email = ref.read(profileProvider).email;
    if (kDebugMode) {
      debugPrint('Demo: password reset requested for $email');
    }
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.appPinResetEmailSent(email)),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final obscured = ref.watch(pinLoginMaskProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 28),
              child: Center(
                child: Text(
                  l10n.appPinDailyBrand,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: _darkBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      l10n.appPinDailyInstruction,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.45,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: PinShakeWrapper(
                            key: _shakeKey,
                            child: PinSixDigitEntry(
                              key: _pinKey,
                              showObscured: obscured,
                              errorHighlight: _errorHighlight,
                              onCompleted: _onCompleted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          onPressed: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            ref.read(pinLoginMaskProvider.notifier).toggle();
                          },
                          splashRadius: 22,
                          icon: Icon(
                            obscured
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.white70,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AnimatedOpacity(
                    opacity: _showWrongText ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      l10n.appPinIncorrectPassword,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        children: [
                          TextSpan(text: l10n.appPinForgotPrefix),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: GestureDetector(
                              onTap: _onResetTap,
                              child: Text(
                                l10n.appPinForgotAction,
                                style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppTheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Spacer(),
                  PinNumpad(
                    onDigit: (d) => _pinKey.currentState?.addDigit(d),
                    onBackspace: () => _pinKey.currentState?.backspace(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
