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
// Conditional import for mobile deep link handling
import 'login_links_mobile.dart'
  if (dart.library.html) 'login_links_stub.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  late final GoogleSignIn _googleSignIn;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile', 'openid'],
      );
      print('GoogleSignIn (WEB): no explicit clientId');
    } else {
      _googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile', 'openid'],
      );
      print('GoogleSignIn (MOBILE): default clientId');
    }
    if (!kIsWeb) {
      handleIncomingLinks(context);
    }
  }

  String get _redirectUrl {
    if (kIsWeb) {
      return 'https://qpssvbgcqzzhpxrpldny.supabase.co/auth/v1/callback';
    }
    return 'https://qpssvbgcqzzhpxrpldny.supabase.co/auth/v1/callback';
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (kIsWeb) {
        // Use Supabase's web OAuth flow for Google
        await Supabase.instance.client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: 'https://itscrazyamazing.com/',
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      print('googleUser: $googleUser');
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        print('Google user is null (sign-in cancelled or failed)');
        return;
      }
      final GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      print('googleAuth: $googleAuth');
      print('idToken: ${googleAuth?.idToken}');
      print('accessToken: ${googleAuth?.accessToken}');
      if (googleAuth == null) {
        print('googleAuth is null');
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google authentication failed: googleAuth is null.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (googleAuth.idToken == null) {
        print('googleAuth.idToken is null');
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google authentication failed: idToken is null.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (googleAuth.accessToken == null) {
        print('googleAuth.accessToken is null');
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google authentication failed: accessToken is null.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );
      globalRefreshSession(context);
    } catch (error) {
      if (error is PlatformException) {
        print('PlatformException code: ${error.code}');
        print('PlatformException message: ${error.message}');
        print('PlatformException details: ${error.details}');
      }
      print('Exception during Google sign-in: $error');
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
        webAuthenticationOptions: Platform.isAndroid
            ? WebAuthenticationOptions(
                clientId: 'com.itscrazyamazing.stacks.signin',
                redirectUri: Uri.parse('https://qpssvbgcqzzhpxrpldny.supabase.co/auth/v1/callback'),
              )
            : null,
      );

      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: credential.identityToken!,
      );
      globalRefreshSession(context);
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