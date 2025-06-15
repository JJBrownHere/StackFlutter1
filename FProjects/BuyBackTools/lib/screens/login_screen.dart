import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_screen.dart';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import '../helpers/session_helper.dart';
import '../helpers/keyboard_dismiss_wrapper.dart';
import 'dart:convert';
// Conditional import for mobile deep link handling
import 'login_links_mobile.dart'
  if (dart.library.html) 'login_links_stub.dart';
// Conditional import for Apple Sign-In
import 'sign_in_with_apple_stub.dart'
  if (dart.library.io) 'package:sign_in_with_apple/sign_in_with_apple.dart'
  if (dart.library.html) 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  // Use the Web Client ID for serverClientId on Android only
  final _googleSignIn = GoogleSignIn(
    serverClientId: (!kIsWeb && Platform.isAndroid)
      ? '670058417215-1sih5511cflim0ks2nkqdhpevv9teg3h.apps.googleusercontent.com'
      : null,
  );

  @override
  void initState() {
    super.initState();
    handleIncomingLinks(context);
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (kIsWeb) {
        await Supabase.instance.client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: 'https://itscrazyamazing.com/auth-callback',
          scopes: 'email profile',
        );
        setState(() {
          _isLoading = false;
        });
        return;
      } else {
        print('DEBUG: Starting native Google sign-in');
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        print('DEBUG: googleUser: $googleUser');
        if (googleUser == null) {
          print('DEBUG: googleUser is null, user cancelled or error');
          setState(() { _isLoading = false; });
          return;
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        print('DEBUG: googleAuth: $googleAuth');
        print('DEBUG: idToken: \\${googleAuth.idToken}');
        print('DEBUG: accessToken: \\${googleAuth.accessToken}');
        // Print the decoded payload of the idToken for debugging
        if (googleAuth.idToken != null) {
          final parts = googleAuth.idToken!.split('.');
          if (parts.length == 3) {
            final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
            print('DEBUG: idToken payload: $payload');
          }
        }
        if (googleAuth.idToken == null || googleAuth.accessToken == null) {
          print('DEBUG: idToken or accessToken is null');
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Google authentication failed: idToken or accessToken is null.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        try {
          await Supabase.instance.client.auth.signInWithIdToken(
            provider: OAuthProvider.google,
            idToken: googleAuth.idToken!,
            accessToken: googleAuth.accessToken,
          );
          print('DEBUG: Supabase signInWithIdToken succeeded');
        } catch (e, st) {
          print('DEBUG: Supabase signInWithIdToken error: $e\n$st');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Supabase signInWithIdToken error: $e'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() { _isLoading = false; });
          return;
        }
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/');
        }
      }
    } catch (error, stack) {
      print('DEBUG: Exception in _handleGoogleSignIn: $error\n$stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing in with Google: $error'),
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
    if (!kIsWeb && !Platform.isIOS) {
      return; // Do nothing on non-iOS, non-web platforms
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (kIsWeb) {
        await Supabase.instance.client.auth.signInWithOAuth(
          OAuthProvider.apple,
          redirectTo: 'https://itscrazyamazing.com/auth-callback',
        );
      } else if (!kIsWeb && Platform.isIOS) {
        final credential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );
        await Supabase.instance.client.auth.signInWithIdToken(
          provider: OAuthProvider.apple,
          idToken: credential.identityToken!,
        );
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/');
        }
      }
    } catch (e) {
      print('Apple Sign In Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing in with Apple: $e'),
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
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyboardDismissOnTap(
        child: SafeArea(
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
                  Builder(
                    builder: (context) {
                      if (kIsWeb || (!kIsWeb && Platform.isIOS)) {
                        return SignInWithAppleButton(
                          onPressed: _handleAppleSignIn,
                          style: SignInWithAppleButtonStyle.black,
                        );
                      }
                      return const SizedBox.shrink(); // Hide on Android
                    },
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
      ),
    );
  }
} 