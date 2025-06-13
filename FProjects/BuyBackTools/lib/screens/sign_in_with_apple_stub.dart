import 'package:flutter/material.dart';

// Stub implementation for non-iOS platforms
class SignInWithApple {
  static Future<dynamic> getAppleIDCredential({List<dynamic>? scopes}) async {
    throw UnimplementedError('Apple Sign-In is not available on this platform.');
  }
}

class AppleIDAuthorizationScopes {
  static const email = 'email';
  static const fullName = 'fullName';
}

class SignInWithAppleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final dynamic style;
  
  const SignInWithAppleButton({
    Key? key,
    this.onPressed,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // Return empty widget for non-iOS platforms
  }
}

class SignInWithAppleButtonStyle {
  static const black = 'black';
} 