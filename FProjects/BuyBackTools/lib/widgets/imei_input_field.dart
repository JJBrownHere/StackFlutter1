import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/text_recognition_service.dart';
import 'glass_container.dart';

class ImeiInputField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;

  const ImeiInputField({
    super.key,
    required this.controller,
    this.hintText,
  });

  @override
  State<ImeiInputField> createState() => _ImeiInputFieldState();
}

class _ImeiInputFieldState extends State<ImeiInputField> {
  final TextRecognitionService _textRecognitionService = TextRecognitionService();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isProcessing = false;

  Future<void> _handleCameraTap() async {
    try {
      setState(() {
        _isProcessing = true;
      });

      // Capture image from camera
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 100,
      );

      if (image == null) {
        return;
      }

      // Process the image using Vision framework
      final String? recognizedText = await _textRecognitionService.recognizeText(File(image.path));

      if (recognizedText != null) {
        widget.controller.text = recognizedText;
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No IMEI or serial number found in the image'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final inputTextColor = isDark ? Colors.white : const Color(0xFF2D3436);
    final hintTextColor = isDark ? Colors.grey[400] : const Color(0xFF7A8C98);
    final iconBgColor = isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.5);
    final iconColor = isDark ? Colors.white : const Color(0xFF2D3436);

    return GlassContainer(
      borderRadius: 15,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              decoration: InputDecoration(
                hintText: widget.hintText ?? 'Enter IMEI or Serial Number',
                hintStyle: TextStyle(
                  color: hintTextColor,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
              style: TextStyle(
                fontSize: 16,
                color: inputTextColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: _isProcessing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      Icons.camera_alt,
                      color: iconColor,
                    ),
              onPressed: _isProcessing ? null : _handleCameraTap,
            ),
          ),
        ],
      ),
    );
  }
} 