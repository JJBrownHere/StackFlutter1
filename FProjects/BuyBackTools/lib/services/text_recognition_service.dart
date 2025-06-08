import 'dart:io';
import 'package:flutter/services.dart';

/// A service that handles text recognition using Vision framework on iOS
class TextRecognitionService {
  static const MethodChannel _channel = MethodChannel('text_recognition_service');

  /// Recognizes text in the given image file
  /// Returns null if the platform is not iOS or if an error occurs
  Future<String?> recognizeText(File imageFile) async {
    if (!Platform.isIOS) {
      throw UnsupportedError('Text recognition is only supported on iOS');
    }

    try {
      final String? result = await _channel.invokeMethod('recognizeText', {
        'imagePath': imageFile.path,
      });
      return result;
    } catch (e) {
      print('Error in text recognition: $e');
      return null;
    }
  }
} 