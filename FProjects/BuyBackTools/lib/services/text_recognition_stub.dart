class TextRecognizer {
  void close() {}
  Future<TextRecognizedText> processImage(dynamic inputImage) async {
    return TextRecognizedText('');
  }
}

class TextRecognizedText {
  final String text;
  TextRecognizedText(this.text);
} 