import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui' as ui;

class PriceChecksScreen extends StatefulWidget {
  const PriceChecksScreen({super.key});

  @override
  State<PriceChecksScreen> createState() => _PriceChecksScreenState();
}

class _PriceChecksScreenState extends State<PriceChecksScreen> {
  final String iframeUrl = 'https://pricing-dropdown-widget.pages.dev/';
  final String viewId = 'price-checks-iframe';

  @override
  void initState() {
    super.initState();
    // Register view factory only for web
    // (No-op for iOS/Android)
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Price Checks'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SizedBox.expand(
          child: HtmlElementView(
            viewType: viewId,
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Price Checks'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: Text('Price check widget is only available on web.'),
        ),
      );
    }
  }
} 