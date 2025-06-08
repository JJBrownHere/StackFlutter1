import 'package:flutter/material.dart';
import '../widgets/imei_input_field.dart';

class ImeiCheckScreen extends StatefulWidget {
  const ImeiCheckScreen({super.key});

  @override
  State<ImeiCheckScreen> createState() => _ImeiCheckScreenState();
}

class _ImeiCheckScreenState extends State<ImeiCheckScreen> {
  final TextEditingController _imeiController = TextEditingController();

  @override
  void dispose() {
    _imeiController.dispose();
    super.dispose();
  }

  void _handleCameraTap() {
    // TODO: Implement camera functionality
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E5EC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFE0E5EC),
        title: const Text(
          'IMEI Check',
          style: TextStyle(
            color: Color(0xFF2D3436),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF2D3436),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Check Device Status',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter the IMEI number to check device status',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7A8C98),
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 32),
              ImeiInputField(
                controller: _imeiController,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 