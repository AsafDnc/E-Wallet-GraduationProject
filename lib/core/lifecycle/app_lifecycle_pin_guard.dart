import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../network/router.dart';
import '../network/supabase_init.dart';
import '../providers/app_background_timestamp_provider.dart';
import '../../features/app_pin/providers/app_pin_repository_provider.dart';
import '../../features/profile/providers/profile_providers.dart';

/// Wraps the app shell to require the daily PIN after returning from background
/// when the user is signed in, has a stored PIN, and [requirePinProvider] is on.
class AppLifecyclePinGuard extends ConsumerStatefulWidget {
  const AppLifecyclePinGuard({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLifecyclePinGuard> createState() =>
      _AppLifecyclePinGuardState();
}

class _AppLifecyclePinGuardState extends ConsumerState<AppLifecyclePinGuard>
    with WidgetsBindingObserver {
  AppLifecycleState? _previousLifecycleState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final notifier = ref.read(appBackgroundTimestampProvider.notifier);
    final cameFromBackground =
        _previousLifecycleState == AppLifecycleState.paused ||
        _previousLifecycleState == AppLifecycleState.inactive;

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        notifier.markBackgrounded(DateTime.now());
        break;
      case AppLifecycleState.resumed:
        if (cameFromBackground) {
          _scheduleResumePinCheck();
        }
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
    _previousLifecycleState = state;
  }

  void _scheduleResumePinCheck() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      unawaited(_evaluateResumeLock());
    });
  }

  Future<void> _evaluateResumeLock() async {
    try {
      if (!supabasePluginReady) {
        return;
      }

      if (!_hasSupabaseSession()) {
        return;
      }

      if (!ref.read(requirePinProvider)) {
        return;
      }

      final storedPin = await ref.read(appPinRepositoryProvider).readPin();
      if (!mounted || storedPin == null) {
        return;
      }

      final router = ref.read(routerProvider);
      final location = router.state.matchedLocation;
      if (_shouldSkipPinResumeLock(location)) {
        return;
      }

      if (!mounted) {
        return;
      }

      router.push('/app-pin/daily-login');
    } catch (e, st) {
      debugPrint('AppLifecyclePinGuard._evaluateResumeLock failed: $e\n$st');
    }
  }

  bool _shouldSkipPinResumeLock(String location) {
    const excluded = <String>{
      '/login',
      '/signup',
      '/otp',
      '/app-pin/create',
      '/app-pin/confirm',
      '/app-pin/daily-login',
    };
    return excluded.contains(location);
  }

  bool _hasSupabaseSession() {
    try {
      return Supabase.instance.client.auth.currentSession != null;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
