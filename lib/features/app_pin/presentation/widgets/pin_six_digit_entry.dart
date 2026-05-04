import 'package:flutter/material.dart';

import '../../domain/app_pin_rules.dart';

/// Six read-only [TextField]s with underline style — system keyboard stays closed.
class PinSixDigitEntry extends StatefulWidget {
  const PinSixDigitEntry({
    super.key,
    required this.showObscured,
    required this.errorHighlight,
    this.onDigitsChanged,
    this.onCompleted,
  });

  /// When true, digits render as bullets (daily login).
  final bool showObscured;

  /// Red underline / text when validation failed.
  final bool errorHighlight;

  final ValueChanged<String>? onDigitsChanged;

  /// Called once when the 6th digit is entered.
  final ValueChanged<String>? onCompleted;

  @override
  State<PinSixDigitEntry> createState() => PinSixDigitEntryState();
}

class PinSixDigitEntryState extends State<PinSixDigitEntry> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      AppPinRules.pinLength,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(
      AppPinRules.pinLength,
      (_) => FocusNode(canRequestFocus: false),
    );
  }

  @override
  void didUpdateWidget(PinSixDigitEntry oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showObscured != widget.showObscured) {
      setState(() {});
    }
    if (oldWidget.errorHighlight != widget.errorHighlight) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  int get _filledCount => _controllers.where((c) => c.text.isNotEmpty).length;

  void addDigit(String digit) {
    if (digit.length != 1 || int.tryParse(digit) == null) {
      return;
    }
    if (_filledCount >= AppPinRules.pinLength) {
      return;
    }
    final idx = _controllers.indexWhere((c) => c.text.isEmpty);
    if (idx < 0) {
      return;
    }
    _controllers[idx].text = digit;
    _notifyLength();
    if (_filledCount == AppPinRules.pinLength) {
      widget.onCompleted?.call(joinedPin);
    }
  }

  void backspace() {
    for (var i = AppPinRules.pinLength - 1; i >= 0; i--) {
      if (_controllers[i].text.isNotEmpty) {
        _controllers[i].clear();
        _notifyLength();
        return;
      }
    }
  }

  void clearAll() {
    for (final c in _controllers) {
      c.clear();
    }
    _notifyLength();
  }

  String get joinedPin => _controllers.map((c) => c.text).join();

  void _notifyLength() {
    widget.onDigitsChanged?.call(joinedPin);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final underlineColor = widget.errorHighlight
        ? Colors.redAccent
        : Colors.white.withValues(alpha: 0.45);
    final textColor = widget.errorHighlight ? Colors.redAccent : Colors.white;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(AppPinRules.pinLength, (i) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: TextField(
              controller: _controllers[i],
              focusNode: _focusNodes[i],
              readOnly: true,
              showCursor: false,
              enableInteractiveSelection: false,
              obscureText: widget.showObscured,
              obscuringCharacter: '•',
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: TextStyle(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.only(bottom: 6, top: 4),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: underlineColor, width: 2),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: underlineColor, width: 2),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: underlineColor, width: 2),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
