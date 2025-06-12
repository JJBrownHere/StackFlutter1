import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../secrets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SheetService {
  static String? _apiKey;
  static String? _googleSheetsApiKey;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'https://www.googleapis.com/auth/spreadsheets.readonly',
      'https://www.googleapis.com/auth/drive.readonly',
    ],
  );

  static Future<void> loadApiKeys() async {
    _googleSheetsApiKey = googleSheetsApiKey;
    _apiKey = API_KEY;
  }

  Future<List<List<String>>> _fetchSheetRows(String spreadsheetId, String sheetName) async {
    final apiKey = _apiKey ?? API_KEY;
    final googleKey = _googleSheetsApiKey ?? googleSheetsApiKey;
    try {
      String? accessToken;
      try {
        final googleUser = await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();
        if (googleUser != null) {
          final auth = await googleUser.authentication;
          accessToken = auth.accessToken;
        }
      } catch (e) {
        // Google sign-in error
      }
      String url = 'https://sheets.googleapis.com/v4/spreadsheets/$spreadsheetId/values/$sheetName';
      final headers = <String, String>{};
      if (accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      } else {
        url += '?key=$googleKey';
      }
      final response = await http.get(Uri.parse(url), headers: headers);
      dynamic data;
      try {
        data = json.decode(response.body);
      } catch (e) {
        throw Exception('Failed to decode Sheets API response as JSON. Raw response: ${response.body}');
      }
      if (data is Map && data.containsKey('error')) {
        throw Exception('Google API error: ${data['error']}');
      }
      final valuesRaw = data is Map && data.containsKey('values') ? data['values'] : null;
      if (valuesRaw == null || valuesRaw is! List) throw Exception('No usable rows found in sheet/tab. Raw response: $data');
      final parsedRows = valuesRaw
          .where((row) => row is List && row.isNotEmpty)
          .map((row) => (row as List)
              .map((cell) => cell == null ? '' : cell.toString())
              .toList())
          .toList();
      if (parsedRows.isEmpty) throw Exception('No usable rows found in sheet/tab. Check if the tab is empty or the data is malformed.');
      return parsedRows;
    } catch (e, stack) {
      rethrow;
    }
  }

  Future<List<Map<String, String>>> getAvailablePhones(String spreadsheetId, String sheetName) async {
    final rows = await _fetchSheetRows(spreadsheetId, sheetName);
    if (rows.isEmpty) throw Exception('Sheet is empty or tab "$sheetName" does not exist.');
    final headers = rows[0];
    final hideIndex = headers.indexOf('hide');
    final soldIndex = headers.indexOf('SoldStatus');
    final requiredFields = [
      'ref', 'Brand', 'Model', 'Carrier', 'Storage', 'Condition', 'Price'
    ];
    final requiredIndexes = requiredFields.map((f) => headers.indexOf(f)).toList();
    if (hideIndex == -1 || soldIndex == -1 || requiredIndexes.contains(-1)) {
      throw Exception("Missing required header(s): 'hide', 'SoldStatus', or one of "+requiredFields.join(', ')+". Headers found: "+headers.join(", "));
    }
    final availablePhones = <Map<String, String>>[];
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length <= soldIndex || row.length <= hideIndex) continue;
      final isHidden = row[hideIndex].toLowerCase() == 'true';
      final isSold = row[soldIndex].isNotEmpty;
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