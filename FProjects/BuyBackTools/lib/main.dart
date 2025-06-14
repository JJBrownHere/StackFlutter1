import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_state.dart';
import 'services/analytics_service.dart';
import 'screens/account_screen.dart';
import 'screens/analytics_screen.dart';

globalRefreshSession(BuildContext context) {
  // Helper to refresh the app after login/logout
  final MyAppState? state = context.findAncestorStateOfType<MyAppState>();
  state?.refreshSession();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
  
  final prefs = await SharedPreferences.getInstance();
  final analyticsService = AnalyticsService(prefs, Supabase.instance.client);
  
  runApp(MyApp(analyticsService: analyticsService));
}

class MyApp extends StatelessWidget {
  final AnalyticsService analyticsService;

  const MyApp({Key? key, required this.analyticsService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BuyBackTools',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => AccountScreen(analyticsService: analyticsService),
        '/analytics': (context) => AnalyticsScreen(analyticsService: analyticsService),
      },
    );
  }
}
