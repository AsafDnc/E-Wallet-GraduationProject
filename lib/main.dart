import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/supabase_constants.dart';
import 'core/lifecycle/app_lifecycle_pin_guard.dart';
import 'core/network/router.dart';
import 'core/network/supabase_init.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

/// Install after [WidgetsFlutterBinding.ensureInitialized] so framework hooks work.
void _installGlobalErrorHandlers() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError.onError: ${details.exceptionAsString()}');
    if (details.stack != null) {
      debugPrint('${details.stack}');
    }
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('PlatformDispatcher.onError: $error\n$stack');
    return true;
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            kDebugMode
                ? details.exceptionAsString()
                : 'Something went wrong while starting the app.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  };
}

void _onZoneError(Object error, StackTrace stackTrace) {
  debugPrint('runZonedGuarded zone error: $error\n$stackTrace');
}

String _safeAppTitle(Locale locale) {
  try {
    final code = locale.languageCode;
    if (code == 'tr') {
      return lookupAppLocalizations(const Locale('tr')).appTitle;
    }
    return lookupAppLocalizations(const Locale('en')).appTitle;
  } catch (e, st) {
    debugPrint('lookupAppLocalizations failed: $e\n$st');
    return 'E Wallet';
  }
}

Future<void> _bootstrapBeforeRunApp() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(kAppLocalePreferenceKey) == 'tr') {
      appLocaleBootstrap = const Locale('tr');
    }
  } catch (e, st) {
    debugPrint('SharedPreferences bootstrap failed: $e\n$st');
  }

  try {
    await Supabase.initialize(
      url: SupabaseConstants.supabaseUrl,
      anonKey: SupabaseConstants.supabaseAnonKey,
    ).timeout(
      const Duration(seconds: 20),
      onTimeout: () =>
          throw TimeoutException('Supabase.initialize exceeded 20s'),
    );
    supabasePluginReady = true;
  } catch (e, st) {
    supabasePluginReady = false;
    debugPrint('Supabase.initialize failed: $e\n$st');
  }
}

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      _installGlobalErrorHandlers();
      await _bootstrapBeforeRunApp();
      runApp(const ProviderScope(child: MyApp()));
    } catch (e, stackTrace) {
      debugPrint('INIT ERROR: $e\n$stackTrace');
      runApp(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: SelectableText(
                  'INIT ERROR:\n$e\n\n$stackTrace',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }, _onZoneError);
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: _safeAppTitle(ref.watch(appLocaleProvider)),
      debugShowCheckedModeBanner: false,
      locale: ref.watch(appLocaleProvider),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      themeMode: themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
      builder: (context, child) {
        return AppLifecyclePinGuard(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
