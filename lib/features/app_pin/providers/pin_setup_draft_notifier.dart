import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the PIN entered on [CreatePinScreen] until [ConfirmPinScreen] succeeds.
class PinSetupDraftNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setDraft(String pin) {
    state = pin;
  }

  void clear() {
    state = null;
  }
}

final pinSetupDraftProvider = NotifierProvider<PinSetupDraftNotifier, String?>(
  PinSetupDraftNotifier.new,
);
