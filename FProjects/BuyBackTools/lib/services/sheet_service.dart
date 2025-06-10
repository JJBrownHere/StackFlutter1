import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../secrets.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
    try {
      String? accessToken;
      if (kIsWeb) {
        print('Attempting Google sign-in (web)...');
        final googleUser = await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();
        print('Google user: $googleUser');
        if (googleUser != null) {
          final auth = await googleUser.authentication;
          print('Google auth: $auth');
          accessToken = auth.accessToken;
        }
        if (accessToken == null) {
          throw Exception('You must sign in with Google to access Sheets on web.');
        }
      } else {
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
      }

      String url = 'https://sheets.googleapis.com/v4/spreadsheets/$spreadsheetId/values/$sheetName';
      final headers = <String, String>{};
      if (accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      } else {
        url += '?key=$_apiKey';
      }
      if (kIsWeb) {
        print('Google Sheets API call (web OAuth): url=$url, accessToken=${accessToken != null}');
      }
      final response = await http.get(Uri.parse(url), headers: headers);
      print('Sheets API raw response: ${response.body}');
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch sheet: ${response.body}');
      }
      final data = json.decode(response.body);
      print('Decoded API response: $data');
      final values = data['values'] as List<dynamic>?;
      if (values == null) return [];
      return values.map((row) => List<String>.from(row.map((cell) => cell.toString()))).toList();
    } catch (e, stack) {
      print('Error in _fetchSheetRows: $e\n$stack');
      rethrow;
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
    if (hideIndex == -1 || soldIndex == -1) {
      throw Exception("Missing required header(s): 'hide' or 'SoldStatus'. Headers found: "+headers.join(", "));
    }
    final availablePhones = <Map<String, String>>[];
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length <= soldIndex || row.length <= hideIndex) continue;
      final isHidden = row[hideIndex].toLowerCase() == 'true';
      final isSold = row[soldIndex].isNotEmpty;
      if (!isHidden && !isSold) {
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