import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/supabase_constants.dart';
import 'core/network/supabase_init.dart';
import 'core/network/router.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(kAppLocalePreferenceKey) == 'tr') {
      appLocaleBootstrap = const Locale('tr');
    }
  } catch (_) {
    // Ignore: fall back to English bootstrap locale.
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
    // Never touch Supabase.instance until [supabasePluginReady] is true (see router & auth).
    debugPrint('Supabase.initialize failed: $e\n$st');
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: lookupAppLocalizations(ref.watch(appLocaleProvider)).appTitle,
      debugShowCheckedModeBanner: false,
      locale: ref.watch(appLocaleProvider),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      themeMode: themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
