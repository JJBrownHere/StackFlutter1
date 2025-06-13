import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_state.dart';

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
  
  runApp(const MyApp());
}
