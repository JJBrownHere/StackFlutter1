import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:html' as html;
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  String get _redirectUrl {
    if (kIsWeb) {
      final origin = html.window.location.origin;
      return '$origin/auth-callback';
    }
    return 'https://qpssvbgcqzzhpxrpldny.supabase.co/auth/v1/callback';
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        Provider.google,
        redirectTo: _redirectUrl,
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      
      await Supabase.instance.client.auth.signInWithIdToken(
        provider: Provider.apple,
        idToken: credential.identityToken!,
        accessToken: credential.authorizationCode,
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleDevBypass() async {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Welcome to STACKS',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else ...[
                ElevatedButton(
                  onPressed: _handleGoogleSignIn,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/images/google_logo.svg',
                        height: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text('Sign in with Google'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SignInWithAppleButton(
                  onPressed: _handleAppleSignIn,
                  style: SignInWithAppleButtonStyle.black,
                ),
                if (kDebugMode) ...[
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _handleDevBypass,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.developer_mode),
                        SizedBox(width: 12),
                        Text('Developer Bypass'),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
} 