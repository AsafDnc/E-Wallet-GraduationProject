import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Material(
      color: _bg,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(12, 8, 12, 12 + bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _row(['1', '2', '3']),
              const SizedBox(height: 6),
              _row(['4', '5', '6']),
              const SizedBox(height: 6),
              _row(['7', '8', '9']),
              const SizedBox(height: 6),
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
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  onDigit(d);
                },
                child: Text(
                  d,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              onDigit('0');
            },
            child: const Text(
              '0',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        Expanded(
          child: _KeyCell(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              onBackspace();
            },
            child: const Icon(
              Icons.backspace_outlined,
              color: Colors.white70,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}

class _KeyCell extends StatelessWidget {
  const _KeyCell({required this.onTap, required this.child});

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
        child: SizedBox(height: 52, child: Center(child: child)),
      ),
    );
  }
}
