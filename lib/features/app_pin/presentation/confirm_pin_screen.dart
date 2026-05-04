import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../domain/app_pin_rules.dart';
import '../domain/pin_flow_source.dart';
import '../providers/app_pin_repository_provider.dart';
import '../providers/pin_setup_draft_notifier.dart';
import 'app_pin_screen_layout.dart';
import 'widgets/pin_numpad.dart';
import 'widgets/pin_shake_wrapper.dart';
import 'widgets/pin_six_digit_entry.dart';

/// Step 2: re-enter PIN; on match persists via [AppPinRepository].
class ConfirmPinScreen extends ConsumerStatefulWidget {
  const ConfirmPinScreen({super.key, this.flowSource = PinFlowSource.signup});

  final PinFlowSource flowSource;

  @override
  ConsumerState<ConfirmPinScreen> createState() => _ConfirmPinScreenState();
}

class _ConfirmPinScreenState extends ConsumerState<ConfirmPinScreen> {
  final GlobalKey<PinSixDigitEntryState> _pinKey =
      GlobalKey<PinSixDigitEntryState>();
  final GlobalKey<PinShakeWrapperState> _shakeKey =
      GlobalKey<PinShakeWrapperState>();

  bool _errorHighlight = false;
  bool _showMismatchText = false;
  bool _handling = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final draft = ref.read(pinSetupDraftProvider);
      if (draft == null || !AppPinRules.isComplete(draft)) {
        if (mounted) Navigator.of(context).maybePop();
      }
    });
  }

  Future<void> _onCompleted(String pin) async {
    if (_handling || !AppPinRules.isComplete(pin)) {
      return;
    }
    final draft = ref.read(pinSetupDraftProvider);
    if (draft == null || !AppPinRules.isComplete(draft)) {
      return;
    }
    _handling = true;
    if (pin == draft) {
      await ref.read(appPinRepositoryProvider).writePin(pin);
      ref.read(pinSetupDraftProvider.notifier).clear();
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.appPinSavedMessage),
          duration: const Duration(seconds: 2),
        ),
      );
      if (widget.flowSource == PinFlowSource.signup) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        context.go('/home');
      } else {
        Navigator.of(context).pop();
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
      return;
    }

    setState(() {
      _errorHighlight = true;
      _showMismatchText = true;
    });
    await _shakeKey.currentState?.shake();
    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _errorHighlight = false;
      _showMismatchText = false;
    });
    _pinKey.currentState?.clearAll();
    _handling = false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
              child: SizedBox(
                height: 48,
                child: Center(
                  child: Text(
                    l10n.appPinConfirmTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppPinScreenLayout.darkBackground,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppPinScreenLayout.darkPanelTopRadius),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    height: AppPinScreenLayout.pinTopSpacingInDarkPanel,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppPinScreenLayout.pinHorizontalPadding,
                    ),
                    child: PinShakeWrapper(
                      key: _shakeKey,
                      child: PinSixDigitEntry(
                        key: _pinKey,
                        showObscured: false,
                        errorHighlight: _errorHighlight,
                        onCompleted: _onCompleted,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppPinScreenLayout.belowPinSpacing),
                  SizedBox(
                    height: 22,
                    child: AnimatedOpacity(
                      opacity: _showMismatchText ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        l10n.appPinMismatch,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.55),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.appPinEncryptedFooter,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.35,
                              color: Colors.white.withValues(alpha: 0.55),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
