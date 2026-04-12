import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../pages/login_page.dart';
import '../pages/verify_email_page.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthProvider>().status;

    return switch (status) {
      AuthStatus.authenticated => child, // Lanjut
      AuthStatus.emailNotVerified => const VerifyEmailPage(), // Redirect
      _ => const LoginPage(), // Redirect login
    };
  }
}

// Penggunaan di routes:
dashboard: (_) => const AuthGuard(child: DashboardPage()),
//                        ↑
//              Hanya masuk jika status = authenticated

