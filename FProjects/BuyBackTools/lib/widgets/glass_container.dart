import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final double opacity;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 20.0,
    this.blur = 20.0,
    this.opacity = 0.2,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final glassColor = color ?? (theme.brightness == Brightness.dark
        ? Colors.white.withOpacity(opacity)
        : Colors.white.withOpacity(opacity));
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: glassColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: padding ?? const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }
} 