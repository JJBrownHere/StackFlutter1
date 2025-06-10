import 'package:flutter/material.dart';

/// Dismisses the keyboard if it is currently visible.
void dismissKeyboard(BuildContext context) {
  FocusScope.of(context).unfocus();
}

String formatCurrency(double amount) {
  return '\$${amount.toStringAsFixed(2)}';
}

String formatDate(DateTime date) {
  return '${date.month}/${date.day}/${date.year}';
}

void showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ),
  );
}

void showSuccessSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    ),
  );
} 