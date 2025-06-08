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
                        ? Theme.of(context).primaryColor.withOpacity(0.5)
                        : const Color(0xFFA3B1C6).withOpacity(0.3),
                    index ~/ 2 + 1 <= currentStep
                        ? Theme.of(context).primaryColor.withOpacity(0.5)
                        : const Color(0xFFA3B1C6).withOpacity(0.3),
                  ],
                ),
                boxShadow: [
                  const BoxShadow(
                    color: Colors.white,
                    offset: Offset(0, -1),
                    blurRadius: 2,
                  ),
                  BoxShadow(
                    color: const Color(0xFFA3B1C6),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E5EC),
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompleted || isCurrent
                    ? Theme.of(context).primaryColor.withOpacity(0.3)
                    : Colors.transparent,
                width: 2,
              ),
              boxShadow: isCurrent
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
                      ),
                      const BoxShadow(
                        color: Color(0xFFA3B1C6),
                        offset: Offset(4, 4),
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
                      fontSize: 16,
                      color: isCompleted || isCurrent
                          ? Theme.of(context).primaryColor
                          : const Color(0xFF7A8C98),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    steps[stepIndex],
                    style: TextStyle(
                      fontSize: 11,
                      color: isCompleted || isCurrent
                          ? Theme.of(context).primaryColor
                          : const Color(0xFF7A8C98),
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