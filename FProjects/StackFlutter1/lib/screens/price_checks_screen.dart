import 'package:flutter/material.dart';
import 'dart:html' as html;
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
    // Register view factory
    ui.platformViewRegistry.registerViewFactory(
      viewId,
      (int viewId) => html.IFrameElement()
        ..src = iframeUrl
        ..style.border = 'none'
        ..style.height = '100%'
        ..style.width = '100%'
        ..allowFullscreen = true,
    );
  }

  @override
  Widget build(BuildContext context) {
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
  }
} 