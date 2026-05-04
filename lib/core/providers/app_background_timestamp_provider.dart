import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Last time the app entered [AppLifecycleState.paused] or [AppLifecycleState.inactive].
/// Used for lifecycle diagnostics and optional future policies (e.g. minimum background duration).
class AppBackgroundTimestampNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() => null;

  void markBackgrounded(DateTime time) {
    state = time;
  }

  void clear() {
    state = null;
  }
}

final appBackgroundTimestampProvider =
    NotifierProvider<AppBackgroundTimestampNotifier, DateTime?>(
      AppBackgroundTimestampNotifier.new,
    );
