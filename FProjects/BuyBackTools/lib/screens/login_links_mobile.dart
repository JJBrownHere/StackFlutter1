import 'package:uni_links/uni_links.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void handleIncomingLinks(BuildContext context) {
  uriLinkStream.listen((Uri? uri) async {
    if (uri != null && uri.scheme == 'com.itscrazyamazing.stacks') {
      try {
        await Supabase.instance.client.auth.getSessionFromUrl(uri);
        if (context.mounted) {
          Navigator.of(context).pushReplacementNamed('/');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error handling deep link: \\${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  });
} 