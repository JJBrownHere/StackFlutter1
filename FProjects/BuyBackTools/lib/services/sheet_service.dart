import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../secrets.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
import 'package:csv/csv.dart';

class SheetService {
  static const String _spreadsheetId = '120gf3lHO7LOZDoD_F5GqLMSUKwBzjE5XhFDWwIVdoJs';
  static const String _sheetName = 'Smartphone'; // Changed from 'Phones' to match the actual tab name
  static const String _apiKey = googleSheetsApiKey;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'https://www.googleapis.com/auth/spreadsheets.readonly',
      'https://www.googleapis.com/auth/drive.readonly',
    ],
  );

  Future<List<List<String>>> _fetchSheetRows(String spreadsheetId, String sheetName) async {
    if (kIsWeb) {
      // For web, use the direct sheet URL format with proper sheet ID
      final sheetUrl = 'https://docs.google.com/spreadsheets/d/$spreadsheetId/export?format=csv&gid=$sheetName';
      print('DEBUG: Using direct sheet URL: $sheetUrl');
      
      try {
        final response = await http.get(Uri.parse(sheetUrl));
        print('DEBUG: Response status code: ${response.statusCode}');
        print('DEBUG: Response headers: ${response.headers}');
        if (response.statusCode != 200) {
          print('DEBUG: Error response body: ${response.body}');
          throw Exception('Failed to fetch sheet data: ${response.statusCode}');
        }
        
        // Parse CSV response
        final rows = const CsvToListConverter().convert(response.body);
        print('DEBUG: Successfully parsed ${rows.length} rows');
        return rows.map((row) => row.map((cell) => cell.toString()).toList()).toList();
      } catch (e, stack) {
        print('DEBUG: Error in web sheet fetch: $e');
        print('DEBUG: Stack trace: $stack');
        rethrow;
      }
    } else {
      // Mobile path - keep existing code unchanged
      try {
        String? accessToken;
        try {
          print('Attempting Google sign-in (mobile)...');
          final googleUser = await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();
          print('Google user: $googleUser');
          if (googleUser != null) {
            final auth = await googleUser.authentication;
            print('Google auth: $auth');
            accessToken = auth.accessToken;
          }
        } catch (e) {
          print('Google sign-in error: $e');
        }

        String url = 'https://sheets.googleapis.com/v4/spreadsheets/$spreadsheetId/values/$sheetName';
        final headers = <String, String>{};
        if (accessToken != null) {
          headers['Authorization'] = 'Bearer $accessToken';
        } else {
          url += '?key=$_apiKey';
        }
        print('Google Sheets API call: url=$url, accessToken=${accessToken != null}');
        final response = await http.get(Uri.parse(url), headers: headers);
        print('Sheets API raw response: ${response.body}');
        dynamic data;
        try {
          data = json.decode(response.body);
          print('Decoded API response: $data');
        } catch (e) {
          print('JSON decode error: $e');
          throw Exception('Failed to decode Sheets API response as JSON. Raw response: ${response.body}');
        }
        if (data is Map && data.containsKey('error')) {
          print('Google API error: ${data['error']}');
          throw Exception('Google API error: ${data['error']}');
        }
        final valuesRaw = data is Map && data.containsKey('values') ? data['values'] : null;
        print('Raw values array: $valuesRaw');
        if (valuesRaw == null || valuesRaw is! List) throw Exception('No usable rows found in sheet/tab. Raw response: $data');
        final parsedRows = valuesRaw
            .where((row) => row is List && row.isNotEmpty)
            .map((row) => (row as List)
                .map((cell) => cell == null ? '' : cell.toString())
                .toList())
            .toList();
        print('Parsed rows count: ${parsedRows.length}');
        if (parsedRows.isNotEmpty) print('First parsed row: ${parsedRows[0]}');
        if (parsedRows.isEmpty) throw Exception('No usable rows found in sheet/tab. Check if the tab is empty or the data is malformed.');
        return parsedRows;
      } catch (e, stack) {
        print('Error in _fetchSheetRows: $e\n$stack');
        rethrow;
      }
    }
  }

  Future<List<Map<String, String>>> getAvailablePhones(String spreadsheetId, String sheetName) async {
    final rows = await _fetchSheetRows(spreadsheetId, sheetName);
    print('Fetched rows: \\${rows}');
    if (rows.isEmpty) throw Exception('Sheet is empty or tab "$sheetName" does not exist.');
    final headers = rows[0];
    print('DEBUG: Sheet headers: ' + headers.join(', '));
    final hideIndex = headers.indexOf('hide');
    final soldIndex = headers.indexOf('SoldStatus');
    // Required fields for a valid product
    final requiredFields = [
      'ref', 'Brand', 'Model', 'Carrier', 'Storage', 'Condition', 'Price'
    ];
    final requiredIndexes = requiredFields.map((f) => headers.indexOf(f)).toList();
    if (hideIndex == -1 || soldIndex == -1 || requiredIndexes.contains(-1)) {
      throw Exception("Missing required header(s): 'hide', 'SoldStatus', or one of ${requiredFields.join(', ')}. Headers found: "+headers.join(", "));
    }
    final availablePhones = <Map<String, String>>[];
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length <= soldIndex || row.length <= hideIndex) continue;
      final isHidden = row[hideIndex].toLowerCase() == 'true';
      final isSold = row[soldIndex].isNotEmpty;
      // Check all required fields are present and non-empty
      final hasAllRequired = requiredIndexes.every((idx) => idx < row.length && row[idx].trim().isNotEmpty);
      if (!isHidden && !isSold && hasAllRequired) {
        final phoneData = <String, String>{};
        for (var j = 0; j < headers.length; j++) {
          if (j < row.length) {
            phoneData[headers[j]] = row[j];
          }
        }
        availablePhones.add(phoneData);
      }
    }
    return availablePhones;
  }

  Future<Map<String, dynamic>> getPhoneSummary(String spreadsheetId, String sheetName) async {
    final phones = await getAvailablePhones(spreadsheetId, sheetName);
    final summary = {
      'totalAvailable': phones.length,
      'byModel': <String, int>{},
      'byStorage': <String, int>{},
      'byColor': <String, int>{},
      'byCondition': <String, int>{},
    };
    for (final phone in phones) {
      final model = phone['Model'] ?? 'Unknown';
      (summary['byModel'] as Map<String, int>)[model] = ((summary['byModel'] as Map<String, int>)[model] ?? 0) + 1;
      final storage = phone['Storage'] ?? 'Unknown';
      (summary['byStorage'] as Map<String, int>)[storage] = ((summary['byStorage'] as Map<String, int>)[storage] ?? 0) + 1;
      final color = phone['Color'] ?? 'Unknown';
      (summary['byColor'] as Map<String, int>)[color] = ((summary['byColor'] as Map<String, int>)[color] ?? 0) + 1;
      final condition = phone['Condition'] ?? 'Unknown';
      (summary['byCondition'] as Map<String, int>)[condition] = ((summary['byCondition'] as Map<String, int>)[condition] ?? 0) + 1;
    }
    return summary;
  }
} 