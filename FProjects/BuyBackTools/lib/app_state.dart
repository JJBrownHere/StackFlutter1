import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/auth_callback_screen.dart';
import 'screens/price_checks_screen.dart';
import 'screens/about_screen.dart';
import 'screens/account_screen.dart';
import 'screens/gatekeeper_screen.dart';
import 'screens/inventory_summary_screen.dart';
import 'screens/purchase_device_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  bool _loading = true;
  bool _authenticated = false;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    refreshSession();
  }

  void refreshSession() {
    final session = Supabase.instance.client.auth.currentSession;
    setState(() {
      _authenticated = session != null;
      _loading = false;
    });
  }

  void setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;
        final authenticated = session != null;
        if (_loading) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        return MaterialApp(
          title: 'STACKS',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFE0E5EC),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF181A1B),
          ),
          themeMode: _themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => authenticated ? const GatekeeperScreen() : const LoginScreen(),
            '/auth-callback': (context) => const AuthCallbackScreen(),
            '/price-checks': (context) => const PriceChecksScreen(),
            '/about': (context) => const AboutScreen(),
            '/account': (context) => const AccountScreen(),
            '/inventory-summary': (context) => const InventorySummaryScreen(),
            '/purchase': (context) => const PurchaseDeviceScreen(),
          },
        );
      },
    );
  }
} 