import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:toku_store/core/providers/favorite_provider.dart';
import 'package:toku_store/core/providers/theme_provider.dart';
import 'package:toku_store/core/routes/app_router.dart';
import 'package:toku_store/core/services/biometric_lock_provider.dart';
import 'package:toku_store/core/services/dompet_pay_service.dart';
import 'package:toku_store/core/services/notification_service.dart';
import 'package:toku_store/core/theme/app_theme.dart';
import 'package:toku_store/core/widgets/biometric_lock_screen.dart';
import 'package:toku_store/features/auth/presentation/providers/auth_provider.dart';
import 'package:toku_store/features/cart/presentation/providers/cart_provider.dart';
import 'package:toku_store/features/dashboard/presentation/providers/product_provider.dart';
import 'package:toku_store/features/order/presentation/providers/order_provider.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initialize();
  await DompetPayService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(
          create: (_) => BiometricLockProvider()..initialize(),
        ),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'Toku Ecommerce',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.themeMode,
      initialRoute: AppRouter.splash,
      routes: AppRouter.routes,
      onGenerateRoute: (settings) {
        final routeName = settings.name ?? '';
        final uri = Uri.tryParse(routeName);
        if (uri != null && uri.queryParameters.containsKey('status')) {
          return MaterialPageRoute(builder: (_) => const SplashPage());
        }
        if (routeName.contains('payment-callback')) {
          return MaterialPageRoute(builder: (_) => const SplashPage());
        }
        return null;
      },
      onUnknownRoute: (settings) =>
          MaterialPageRoute(builder: (_) => const SplashPage()),
      builder: (context, child) =>
          BiometricLockScreen(child: child!),
    );
  }
}
