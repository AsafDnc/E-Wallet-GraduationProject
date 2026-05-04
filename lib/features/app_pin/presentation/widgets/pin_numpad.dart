import 'package:flutter/material.dart';

import '../app_pin_screen_layout.dart';

/// Flat, borderless custom numpad (0–9 + backspace). Does not open the system keyboard.
class PinNumpad extends StatelessWidget {
  const PinNumpad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  static const _bg = Color(0xFF121417);

  static TextStyle get _digitStyle => TextStyle(
    color: Colors.white,
    fontSize: AppPinScreenLayout.numpadDigitFontSize,
    fontWeight: AppPinScreenLayout.numpadDigitFontWeight,
    height: 1.05,
  );

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Material(
      color: _bg,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppPinScreenLayout.numpadPaddingHorizontal,
            AppPinScreenLayout.numpadPaddingTop,
            AppPinScreenLayout.numpadPaddingHorizontal,
            AppPinScreenLayout.numpadPaddingBottom + bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _row(['1', '2', '3']),
              SizedBox(height: AppPinScreenLayout.numpadRowGap),
              _row(['4', '5', '6']),
              SizedBox(height: AppPinScreenLayout.numpadRowGap),
              _row(['7', '8', '9']),
              SizedBox(height: AppPinScreenLayout.numpadRowGap),
              _bottomRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(List<String> digits) {
    return Row(
      children: digits
          .map(
            (d) => Expanded(
              child: _KeyCell(
                height: AppPinScreenLayout.numpadKeyHeight,
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  onDigit(d);
                },
                child: Text(d, style: _digitStyle),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _bottomRow() {
    return Row(
      children: [
        const Expanded(child: SizedBox.shrink()),
        Expanded(
          child: _KeyCell(
            height: AppPinScreenLayout.numpadKeyHeight,
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              onDigit('0');
            },
            child: Text('0', style: _digitStyle),
          ),
        ),
        Expanded(
          child: _KeyCell(
            height: AppPinScreenLayout.numpadKeyHeight,
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              onBackspace();
            },
            child: Icon(
              Icons.backspace_outlined,
              color: Colors.white70,
              size: AppPinScreenLayout.numpadBackspaceIconSize,
            ),
          ),
        ),
      ],
    );
  }
}

class _KeyCell extends StatelessWidget {
  const _KeyCell({
    required this.height,
    required this.onTap,
    required this.child,
  });

  final double height;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white12,
        highlightColor: Colors.white10,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: height,
          child: Center(child: child),
        ),
      ),
    );
  }
}
