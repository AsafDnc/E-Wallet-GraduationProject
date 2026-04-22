import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/login/login_screen.dart';
import '../../features/auth/presentation/signup/signup_screen.dart';
import '../../features/budget/presentation/budget_screen.dart';
import '../../features/categories/presentation/categories_screen.dart';
import '../../features/navigation/presentation/app_shell_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/subscriptions/presentation/subscriptions_screen.dart';
import '../../features/wallets/presentation/screens/my_wallets_screen.dart';
import 'supabase_init.dart';

Session? _currentSupabaseSession() {
  if (!supabasePluginReady) return null;
  try {
    return Supabase.instance.client.auth.currentSession;
  } catch (_) {
    return null;
  }
}

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

const _kTransitionDuration = Duration(milliseconds: 380);
const _kCurve = Curves.easeInOutCubic;

/// Builds a [CustomTransitionPage] with a horizontal iOS-style push/pop:
///
///  • Incoming page: slides in from [Offset(1, 0)] → [Offset.zero]   (right → center)
///  • Outgoing page: slides out to [Offset(-0.3, 0)]                 (center → left, subtle parallax)
///
/// The outgoing exit is driven by [secondaryAnimation], which GoRouter
/// automatically runs forward when a new route is pushed on top and
/// reverses when that route is popped — no manual status checks needed.
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
      // Incoming: slides in from right edge.
      final enterSlide = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: _kCurve));

      // Outgoing: subtle parallax slide to the left (driven by secondaryAnimation).
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

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthStateRefreshNotifier();
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: _currentSupabaseSession() != null ? '/home' : '/login',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final isLoggedIn = _currentSupabaseSession() != null;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [
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
        pageBuilder: (context, state) => _horizontalPushPage(
          pageKey: state.pageKey,
          child: const ProfileScreen(),
        ),
      ),
      GoRoute(
        path: '/wallets',
        pageBuilder: (context, state) => _horizontalPushPage(
          pageKey: state.pageKey,
          child: const MyWalletsScreen(),
        ),
      ),
      GoRoute(
        path: '/subscriptions',
        pageBuilder: (context, state) => _horizontalPushPage(
          pageKey: state.pageKey,
          child: Builder(
            builder: (ctx) => SubscriptionsScreen(onBackTap: () => ctx.pop()),
          ),
        ),
      ),
      GoRoute(
        path: '/budget',
        pageBuilder: (context, state) => _horizontalPushPage(
          pageKey: state.pageKey,
          child: const BudgetScreen(),
        ),
      ),
      GoRoute(
        path: '/categories',
        pageBuilder: (context, state) => _horizontalPushPage(
          pageKey: state.pageKey,
          child: const CategoriesScreen(),
        ),
      ),
    ],
  );
});
