// This file is only for web platform. Do not import on iOS/Android.
import 'dart:html' as html;

export 'web_helpers_web.dart' if (dart.library.html) 'web_helpers_web.dart' if (dart.library.io) 'web_helpers_stub.dart';

String getCurrentUrl() => html.window.location.href; 