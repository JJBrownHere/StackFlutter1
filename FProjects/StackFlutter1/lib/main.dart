import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/auth_callback_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://qpssvbgcqzzhpxrpldny.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFwc3N2YmdjcXp6aHB4cnBsZG55Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg3MjAzNzIsImV4cCI6MjA2NDI5NjM3Mn0.p8gJZwPpu2pWKNAVMtLTc4obMSDW4PxRJxWnUzM-jcc',
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'STACKS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => StreamBuilder<AuthState>(
          stream: Supabase.instance.client.auth.onAuthStateChange,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final session = snapshot.data!.session;
              if (session != null) {
                return const HomeScreen();
              }
            }
            return const LoginScreen();
          },
        ),
        '/auth-callback': (context) => const AuthCallbackScreen(),
      },
    );
  }
}
