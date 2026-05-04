import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../domain/app_pin_rules.dart';
import '../domain/pin_flow_source.dart';
import '../providers/pin_setup_draft_notifier.dart';
import 'app_pin_screen_layout.dart';
import 'confirm_pin_screen.dart';
import 'widgets/pin_numpad.dart';
import 'widgets/pin_six_digit_entry.dart';

/// Step 1: choose a 6-digit PIN (digits visible). Pushes [ConfirmPinScreen] on completion.
class CreatePinScreen extends ConsumerStatefulWidget {
  const CreatePinScreen({super.key, this.flowSource = PinFlowSource.signup});

  final PinFlowSource flowSource;

  @override
  ConsumerState<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends ConsumerState<CreatePinScreen> {
  final GlobalKey<PinSixDigitEntryState> _pinKey =
      GlobalKey<PinSixDigitEntryState>();
  bool _navigating = false;

  Future<void> _onPinCompleted(String pin) async {
    if (_navigating || !AppPinRules.isComplete(pin)) {
      return;
    }
    _navigating = true;
    ref.read(pinSetupDraftProvider.notifier).setDraft(pin);
    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => ConfirmPinScreen(flowSource: widget.flowSource),
      ),
    );
    if (mounted) {
      _navigating = false;
      _pinKey.currentState?.clearAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            FocusManager.instance.primaryFocus?.unfocus();
            context.pop();
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
        ),
        title: Text(
          l10n.appPinCreateTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
      ),
      body: Column(
        children: [
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
                    height: AppPinScreenLayout.darkPanelInnerTopPadding,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppPinScreenLayout.pinHorizontalPadding,
                    ),
                    child: SizedBox(
                      height: AppPinScreenLayout.instructionSlotHeight,
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          l10n.appPinCreateSubtitle,
                          textAlign: TextAlign.center,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.45,
                            color: Colors.white.withValues(alpha: 0.82),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: AppPinScreenLayout.instructionToPinGap,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppPinScreenLayout.pinHorizontalPadding,
                    ),
                    child: PinSixDigitEntry(
                      key: _pinKey,
                      showObscured: false,
                      errorHighlight: false,
                      onCompleted: _onPinCompleted,
                    ),
                  ),
                  const SizedBox(height: AppPinScreenLayout.belowPinSpacing),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppPinScreenLayout.pinHorizontalPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PinHintBullet(
                          text: l10n.appPinWarningSequential,
                          bulletColor: Colors.white.withValues(alpha: 0.55),
                          textColor: Colors.white.withValues(alpha: 0.72),
                        ),
                        const SizedBox(height: 8),
                        _PinHintBullet(
                          text: l10n.appPinWarningRepeated,
                          bulletColor: Colors.white.withValues(alpha: 0.55),
                          textColor: Colors.white.withValues(alpha: 0.72),
                        ),
                      ],
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

class _PinHintBullet extends StatelessWidget {
  const _PinHintBullet({
    required this.text,
    required this.bulletColor,
    required this.textColor,
  });

  final String text;
  final Color bulletColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• ',
          style: TextStyle(fontSize: 15, height: 1.35, color: bulletColor),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, height: 1.35, color: textColor),
          ),
        ),
      ],
    );
  }
}
