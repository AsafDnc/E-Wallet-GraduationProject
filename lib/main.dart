import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/network/router.dart';

void main() async {
  // Flutter motorunun tam olarak başlatıldığından emin oluyoruz.
  // Bu, Supabase veya Isar gibi asenkron (bekleme gerektiren) paketleri
  // başlatabilmemiz için zorunludur.
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Supabase ve Isar veritabanı başlatma kodları buraya gelecek.

  // Tüm uygulamayı ProviderScope ile sarıyoruz ki Riverpod her yerden erişilebilir olsun.
  runApp(const ProviderScope(child: MyApp()));
}

// Artık StatelessWidget yerine Riverpod'un ConsumerWidget'ını kullanıyoruz.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Router provider'ımızı okuyoruz
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'E-Wallet',
      debugShowCheckedModeBanner:
          false, // Sağ üstteki "DEBUG" yazısını kaldırır
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3:
            true, // Modern Material 3 tasarım dilini aktifleştiriyoruz
      ),
      // GoRouter'ı uygulamamıza bağlıyoruz
      routerConfig: router,
    );
  }
}
