import 'package:flutter/material.dart';

/// Horizontal shake used for PIN mismatch / wrong password feedback.
class PinShakeWrapper extends StatefulWidget {
  const PinShakeWrapper({super.key, required this.child});

  final Widget child;

  @override
  State<PinShakeWrapper> createState() => PinShakeWrapperState();
}

class PinShakeWrapperState extends State<PinShakeWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _dx;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _dx = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8, end: -6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6, end: 4), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 4, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> shake() async {
    if (!mounted) return;
    await _controller.forward(from: 0);
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dx,
      builder: (context, child) {
        return Transform.translate(offset: Offset(_dx.value, 0), child: child);
      },
      child: widget.child,
    );
  }
}
