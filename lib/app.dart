import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/approval_provider.dart';
import 'providers/disposition_provider.dart';
import 'providers/multi_dashboard_provider.dart';
import 'providers/unified_approval_provider.dart';
import 'providers/branch_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';

class MobileApprovalApp extends StatelessWidget {
  const MobileApprovalApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuthStatus()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ApprovalProvider()),
        ChangeNotifierProvider(create: (_) => DispositionProvider()),
        ChangeNotifierProvider(create: (_) => MultiDashboardProvider()),
        ChangeNotifierProvider(create: (_) => UnifiedApprovalProvider()),
        ChangeNotifierProvider(create: (_) => BranchProvider()),
      ],
      child: MaterialApp(
        title: 'Mobile Approval',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            if (authProvider.isLoading && !authProvider.isLoggedIn) {
              return const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Memuat sesi...'),
                    ],
                  ),
                ),
              );
            }
            return authProvider.isLoggedIn ? const DashboardScreen() : const LoginScreen();
          },
        ),
      ),
    );
  }
}
