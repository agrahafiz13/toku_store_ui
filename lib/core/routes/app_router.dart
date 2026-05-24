import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toku_store/features/auth/presentation/providers/auth_provider.dart';
import 'package:toku_store/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:toku_store/main.dart';
import 'package:toku_store/features/auth/presentation/pages/login_page.dart';
import 'package:toku_store/features/auth/presentation/pages/register_page.dart';
import 'package:toku_store/features/auth/presentation/pages/verify_email_page.dart';
import 'package:toku_store/features/order/data/models/order_model.dart';
import 'package:toku_store/features/order/presentation/pages/my_orders_page.dart';
import 'package:toku_store/features/order/presentation/pages/order_success.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String dashboard = '/dashboard';
  static const String myOrders = '/my-orders';

  static const String orderSuccess = '/order-success';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      case verifyEmail:
        return MaterialPageRoute(builder: (_) => const VerifyEmailPage());

      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const AuthGuard(child: DashboardPage()),
        );

      // TAMBAHKAN INI
      case myOrders:
        return MaterialPageRoute(builder: (_) => const MyOrdersPage());

      case orderSuccess:
        final order = settings.arguments as OrderModel;

        return MaterialPageRoute(
          builder: (_) => OrderSuccessPage(order: order),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route tidak ditemukan')),
          ),
        );
    }
  }
}

class AuthGuard extends StatelessWidget {
  final Widget child;
  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthProvider>().status;

    return switch (status) {
      AuthStatus.authenticated => child,
      AuthStatus.emailNotVerified => const VerifyEmailPage(),
      _ => const LoginPage(),
    };
  }
}
