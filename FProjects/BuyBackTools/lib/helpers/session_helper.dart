import 'package:flutter/material.dart';
import '../app_state.dart';

void globalRefreshSession(BuildContext context) {
  final MyAppState? state = context.findAncestorStateOfType<MyAppState>();
  state?.refreshSession();
} 