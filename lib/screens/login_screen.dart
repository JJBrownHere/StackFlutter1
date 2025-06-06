import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  // ... (existing code)
}

class _LoginScreenState extends State<LoginScreen> {
  final _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'https://www.googleapis.com/auth/spreadsheets',
    ],
  );

  // ... (rest of the existing code)
} 