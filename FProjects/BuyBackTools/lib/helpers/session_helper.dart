import 'package:flutter/material.dart';
import '../main.dart';

void globalRefreshSession(BuildContext context) {
  final MyAppState? state = context.findAncestorStateOfType<MyAppState>();
  state?.refreshSession();
} 