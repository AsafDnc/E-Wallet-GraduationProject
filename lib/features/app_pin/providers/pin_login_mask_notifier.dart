import 'package:flutter_riverpod/flutter_riverpod.dart';

/// When `true`, digits are obscured (•) on the daily PIN login screen.
class PinLoginMaskNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void setObscured(bool value) {
    state = value;
  }

  void toggle() {
    state = !state;
  }
}

final pinLoginMaskProvider = NotifierProvider<PinLoginMaskNotifier, bool>(
  PinLoginMaskNotifier.new,
);
