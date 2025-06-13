import 'package:flutter/material.dart';
import '../helpers/keyboard_dismiss_wrapper.dart';

class KeyboardDismissOnTap extends StatelessWidget {
  final Widget child;

  const KeyboardDismissOnTap({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: child,
    );
  }
} 