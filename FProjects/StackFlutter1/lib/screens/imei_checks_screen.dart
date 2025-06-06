import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImeiChecksScreen extends StatefulWidget {
  const ImeiChecksScreen({super.key});

  @override
  State<ImeiChecksScreen> createState() => _ImeiChecksScreenState();
}

class _ImeiChecksScreenState extends State<ImeiChecksScreen> {
  final TextEditingController _imeiController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _startScanning() async {
    final status = await Permission.camera.request();
    if (status.isDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera permission is required to scan IMEI numbers'),
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image != null && mounted) {
        // For now, we'll just show a message that scanning is not implemented
        // In a real app, you would implement text recognition here
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera capture successful. Text recognition will be implemented in the next phase.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error capturing image: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _imeiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IMEI Checks'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _imeiController,
              decoration: InputDecoration(
                labelText: 'IMEI/Serial Number',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.camera_alt),
                  onPressed: _isLoading ? null : _startScanning,
                ),
              ),
              keyboardType: TextInputType.number,
              maxLength: 15,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement IMEI check logic
              },
              child: const Text('Check IMEI'),
            ),
          ],
        ),
      ),
    );
  }
} 