import 'package:flutter/material.dart';

class NeoStepper extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const NeoStepper({
    super.key,
    required this.currentStep,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? theme.scaffoldBackgroundColor : const Color(0xFFE0E5EC);
    final textColor = isDark ? Colors.white : const Color(0xFF2D3436);
    final secondaryTextColor = isDark ? Colors.grey[400] : const Color(0xFF7A8C98);
    final shadowColor = isDark ? Colors.black.withOpacity(0.3) : const Color(0xFFA3B1C6);
    final lightShadowColor = isDark ? Colors.white.withOpacity(0.1) : Colors.white;

    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            // Divider
            return Container(
              width: 30,
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    index ~/ 2 < currentStep 
                        ? theme.primaryColor.withOpacity(0.3)
                        : shadowColor.withOpacity(0.2),
                    index ~/ 2 + 1 <= currentStep
                        ? theme.primaryColor.withOpacity(0.3)
                        : shadowColor.withOpacity(0.2),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: lightShadowColor,
                    offset: const Offset(0, -1),
                    blurRadius: 2,
                  ),
                  BoxShadow(
                    color: shadowColor,
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                    spreadRadius: index ~/ 2 < currentStep ? 0 : -1,
                  ),
                ],
              ),
            );
          }
          
          final stepIndex = index ~/ 2;
          final isCompleted = stepIndex < currentStep;
          final isCurrent = stepIndex == currentStep;

          return Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompleted || isCurrent
                    ? theme.primaryColor.withOpacity(0.3)
                    : Colors.transparent,
                width: 2,
              ),
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: shadowColor,
                        offset: const Offset(-2, -2),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: lightShadowColor,
                        offset: const Offset(2, 2),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: lightShadowColor,
                        offset: const Offset(-4, -4),
                        blurRadius: 10,
                      ),
                      BoxShadow(
                        color: shadowColor,
                        offset: const Offset(4, 4),
                        blurRadius: 10,
                      ),
                    ],
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${stepIndex + 1}',
                    style: TextStyle(
                      fontSize: 18,
                      color: isCompleted || isCurrent
                          ? theme.primaryColor
                          : secondaryTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    steps[stepIndex],
                    style: TextStyle(
                      fontSize: 12,
                      color: isCompleted || isCurrent
                          ? theme.primaryColor
                          : secondaryTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
} 