import 'package:http/http.dart' as http;
import 'dart:convert';

class InventorySheetService {
  static const String _baseUrl = 'https://us-central1-stackflutter1.cloudfunctions.net';

  Future<String> createInventorySheet(String userEmail) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/createInventorySheet'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'userEmail': userEmail}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create inventory sheet: ${response.body}');
    }

    final data = json.decode(response.body);
    return data['sheetId'] as String;
  }
} 