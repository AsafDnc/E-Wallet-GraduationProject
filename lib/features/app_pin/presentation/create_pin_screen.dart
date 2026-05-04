import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../domain/app_pin_rules.dart';
import '../providers/pin_setup_draft_notifier.dart';
import 'widgets/pin_numpad.dart';
import 'widgets/pin_six_digit_entry.dart';
import 'confirm_pin_screen.dart';

/// Step 1: choose a 6-digit PIN (digits visible). Pushes [ConfirmPinScreen] on completion.
class CreatePinScreen extends ConsumerStatefulWidget {
  const CreatePinScreen({super.key});

  @override
  ConsumerState<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends ConsumerState<CreatePinScreen> {
  final GlobalKey<PinSixDigitEntryState> _pinKey =
      GlobalKey<PinSixDigitEntryState>();
  bool _navigating = false;

  static const _darkBg = Color(0xFF121417);

  Future<void> _onPinCompleted(String pin) async {
    if (_navigating || !AppPinRules.isComplete(pin)) {
      return;
    }
    _navigating = true;
    ref.read(pinSetupDraftProvider.notifier).setDraft(pin);
    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (context) => const ConfirmPinScreen()),
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
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      context.pop();
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.appPinCreateTitle,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.appPinCreateSubtitle,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.4,
                            color: Colors.black.withValues(alpha: 0.65),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _Bullet(l10n.appPinWarningSequential),
                        const SizedBox(height: 8),
                        _Bullet(l10n.appPinWarningRepeated),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: _darkBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 36),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: PinSixDigitEntry(
                      key: _pinKey,
                      showObscured: false,
                      errorHighlight: false,
                      onCompleted: _onPinCompleted,
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

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• ',
          style: TextStyle(
            fontSize: 15,
            height: 1.35,
            color: Colors.black.withValues(alpha: 0.55),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              height: 1.35,
              color: Colors.black.withValues(alpha: 0.55),
            ),
          ),
        ),
      ],
    );
  }
}
