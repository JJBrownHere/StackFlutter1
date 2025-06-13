import 'package:flutter/material.dart';
import 'glass_container.dart';

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
    final textColor = isDark ? Colors.white : const Color(0xFF2D3436);
    final secondaryTextColor = isDark ? Colors.grey[400] : const Color(0xFF7A8C98);

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
              color: theme.primaryColor.withOpacity(0.15),
            );
          }

          final stepIndex = index ~/ 2;
          final isCompleted = stepIndex < currentStep;
          final isCurrent = stepIndex == currentStep;

          return GlassContainer(
            borderRadius: 28,
            blur: 16,
            opacity: isCurrent ? 0.25 : 0.12,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${stepIndex + 1}',
                  style: TextStyle(
                    fontSize: 16,
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
                    fontSize: 11,
                    color: isCompleted || isCurrent
                        ? theme.primaryColor
                        : secondaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
} 