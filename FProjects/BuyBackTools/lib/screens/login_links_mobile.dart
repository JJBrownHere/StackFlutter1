import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void handleIncomingLinks(BuildContext context) async {
  final appLinks = AppLinks();
  
  // Handle incoming links while the app is already running
  appLinks.uriLinkStream.listen((Uri uri) async {
    if (uri.scheme == 'com.itscrazyamazing.stacks') {
      try {
        await Supabase.instance.client.auth.getSessionFromUrl(uri);
        if (context.mounted) {
          Navigator.of(context).pushReplacementNamed('/');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error handling deep link: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  });

  // Handle links that opened the app
  try {
    final uri = await appLinks.getInitialAppLink();
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
              content: Text('Error handling initial deep link: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting initial app link: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 