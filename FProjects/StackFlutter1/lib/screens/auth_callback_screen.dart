import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'home_screen.dart';

class AuthCallbackScreen extends StatefulWidget {
  const AuthCallbackScreen({super.key});

  @override
  State<AuthCallbackScreen> createState() => _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends State<AuthCallbackScreen> {
  @override
  void initState() {
    super.initState();
    _handleAuthCallback();
  }

  Future<void> _handleAuthCallback() async {
    try {
      if (kIsWeb) {
        // Get the current URL
        final uri = Uri.parse(html.window.location.href);
        if (uri.hasFragment) {
          // Convert the fragment to query parameters
          final params = Uri.parse('?${uri.fragment}').queryParameters;
          
          if (params.containsKey('access_token')) {
            // Set the session in Supabase
            await Supabase.instance.client.auth.setSession(params['access_token']!);
            
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/');
            }
          }
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
} 