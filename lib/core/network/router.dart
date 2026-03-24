import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Riverpod üzerinden GoRouter'ı sağlıyoruz ki ileride giriş yapmış
// kullanıcıyı otomatik yönlendirme (redirect) işlemlerini kolayca yapabilelim.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/', // Uygulama açıldığında ilk buraya gidecek
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text(
              'E-Wallet Mimari Kurulumu Başarılı! 🎉',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      // İleride diğer sayfalarımızı (login, home vs.) buraya ekleyeceğiz.
    ],
  );
});
