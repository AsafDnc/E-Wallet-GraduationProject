import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_init.dart';

import '../../features/auth/presentation/login/login_screen.dart';
import '../../features/auth/presentation/otp/otp_verification_screen.dart';
import '../../features/auth/presentation/signup/signup_screen.dart';
import '../../features/budget/presentation/budget_screen.dart';
import '../../features/categories/presentation/categories_screen.dart';
import '../../features/navigation/presentation/app_shell_screen.dart';
import '../../features/navigation/providers/shell_home_navigation_intent_provider.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/screens/daily_limits_screen.dart';
import '../../features/profile/presentation/screens/password_pin_screen.dart';
import '../../features/profile/presentation/screens/personal_info_screen.dart';
import '../../features/profile/presentation/screens/two_factor_auth_screen.dart';
import '../../features/wallet/presentation/wallet_screen.dart';
import '../../features/wallets/presentation/screens/my_wallets_screen.dart';

/// A [ChangeNotifier] that fires whenever the Supabase auth state changes,
/// which causes GoRouter to re-evaluate its [redirect] callback.
class _AuthStateRefreshNotifier extends ChangeNotifier {
  _AuthStateRefreshNotifier() {
    if (!supabasePluginReady) return;
    try {
      _subscription = Supabase.instance.client.auth.onAuthStateChange.listen((
        _,
      ) {
        notifyListeners();
      });
    } catch (_) {
      _subscription = null;
    }
  }

  StreamSubscription<AuthState>? _subscription;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

bool _hasSupabaseSession() {
  if (!supabasePluginReady) return false;
  try {
    return Supabase.instance.client.auth.currentSession != null;
  } catch (_) {
    return false;
  }
}

const _kTransitionDuration = Duration(milliseconds: 380);
const _kCurve = Curves.easeInOutCubic;

CustomTransitionPage<void> _horizontalPushPage({
  required LocalKey pageKey,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: pageKey,
    child: child,
    transitionDuration: _kTransitionDuration,
    reverseTransitionDuration: _kTransitionDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final enterSlide = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: _kCurve));

      final exitSlide = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-0.3, 0.0),
      ).animate(CurvedAnimation(parent: secondaryAnimation, curve: _kCurve));

      return SlideTransition(
        position: exitSlide,
        child: SlideTransition(position: enterSlide, child: child),
      );
    },
  );
}

/// iOS-style push with interactive edge-swipe-to-pop. Used only for nested app
/// routes (not [AppShellScreen] on `/home` or auth flows).
CupertinoPage<void> _cupertinoNestedPage({
  required LocalKey pageKey,
  required Widget child,
}) {
  return CupertinoPage<void>(key: pageKey, child: child);
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthStateRefreshNotifier();
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: _hasSupabaseSession() ? '/home' : '/login',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final isLoggedIn = _hasSupabaseSession();
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/otp';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/otp',
        pageBuilder: (context, state) {
          final email = (state.extra as String?) ?? '';
          return _horizontalPushPage(
            pageKey: state.pageKey,
            child: OtpVerificationScreen(email: email),
          );
        },
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _horizontalPushPage(
          pageKey: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) => _horizontalPushPage(
          pageKey: state.pageKey,
          child: const SignupScreen(),
        ),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => _horizontalPushPage(
          pageKey: state.pageKey,
          child: const AppShellScreen(),
        ),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => _cupertinoNestedPage(
          pageKey: state.pageKey,
          child: const ProfileScreen(),
        ),
      ),
      GoRoute(
        path: '/wallets',
        pageBuilder: (context, state) => _cupertinoNestedPage(
          pageKey: state.pageKey,
          child: const MyWalletsScreen(),
        ),
      ),
      GoRoute(
        path: '/subscriptions',
        redirect: (context, state) {
          ref
              .read(shellHomeNavigationIntentProvider.notifier)
              .openUnifiedSubscriptionsFromHome();
          return '/home';
        },
      ),
      GoRoute(
        path: '/budget',
        pageBuilder: (context, state) => _cupertinoNestedPage(
          pageKey: state.pageKey,
          child: const BudgetScreen(),
        ),
      ),
      GoRoute(
        path: '/categories',
        pageBuilder: (context, state) => _cupertinoNestedPage(
          pageKey: state.pageKey,
          child: const CategoriesScreen(),
        ),
      ),
      GoRoute(
        path: '/wallet',
        pageBuilder: (context, state) => _cupertinoNestedPage(
          pageKey: state.pageKey,
          child: const WalletScreen(),
        ),
      ),
      GoRoute(
        path: '/security/personal-info',
        pageBuilder: (context, state) => _cupertinoNestedPage(
          pageKey: state.pageKey,
          child: const PersonalInfoScreen(),
        ),
      ),
      GoRoute(
        path: '/security/password-pin',
        pageBuilder: (context, state) => _cupertinoNestedPage(
          pageKey: state.pageKey,
          child: const PasswordPinScreen(),
        ),
      ),
      GoRoute(
        path: '/security/2fa',
        pageBuilder: (context, state) => _cupertinoNestedPage(
          pageKey: state.pageKey,
          child: const TwoFactorAuthScreen(),
        ),
      ),
      GoRoute(
        path: '/security/daily-limits',
        pageBuilder: (context, state) => _cupertinoNestedPage(
          pageKey: state.pageKey,
          child: const DailyLimitsScreen(),
        ),
      ),
    ],
  );
});
