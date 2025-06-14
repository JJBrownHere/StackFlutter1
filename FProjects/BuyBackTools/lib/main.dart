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
    url: 'https://qpssvbgcqzzhpxrpldny.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFwc3N2YmdjcXp6aHB4cnBsZG55Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg3MjAzNzIsImV4cCI6MjA2NDI5NjM3Mn0.p8gJZwPpu2pWKNAVMtLTc4obMSDW4PxRJxWnUzM-jcc',
  );
  
  final prefs = await SharedPreferences.getInstance();
  final analyticsService = AnalyticsService(prefs, Supabase.instance.client);
  
  runApp(const MyApp());
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
        '/': (context) => const AccountScreen(),
        '/analytics': (context) => AnalyticsScreen(analyticsService: analyticsService),
      },
    );
  }
}
