import 'package:flutter/material.dart';

class NeoContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final bool isPressed;

  const NeoContainer({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 15,
    this.isPressed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E5EC),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isPressed
            ? [
                const BoxShadow(
                  color: Color(0xFFA3B1C6),
                  offset: Offset(-2, -2),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
                const BoxShadow(
                  color: Colors.white,
                  offset: Offset(2, 2),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ]
            : [
                const BoxShadow(
                  color: Colors.white,
                  offset: Offset(-4, -4),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
                const BoxShadow(
                  color: Color(0xFFA3B1C6),
                  offset: Offset(4, 4),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
      ),
      child: child,
    );
  }
}

class NeoButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color? color;
  final double width;
  final double height;
  final bool isSelected;

  const NeoButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.color,
    this.width = double.infinity,
    this.height = 50,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFE0E5EC),
          borderRadius: BorderRadius.circular(15),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Colors.white,
                    offset: Offset(3, 3),
                    blurRadius: 3,
                    spreadRadius: -3,
                  ),
                  BoxShadow(
                    color: Color(0xFFA3B1C6),
                    offset: Offset(-3, -3),
                    blurRadius: 3,
                    spreadRadius: -3,
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Colors.white,
                    offset: Offset(-4, -4),
                    blurRadius: 10,
                  ),
                  BoxShadow(
                    color: Color(0xFFA3B1C6),
                    offset: Offset(4, 4),
                    blurRadius: 10,
                  ),
                ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: color ?? const Color(0xFFE0E5EC),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
} 