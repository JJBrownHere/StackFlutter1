class SheetService {
  static Future<void> loadApiKeys() async {
    throw UnsupportedError('SheetService.loadApiKeys is only available on web.');
  }
  Future<List<List<String>>> _fetchSheetRows(String spreadsheetId, String sheetName) async {
    throw UnsupportedError('SheetService._fetchSheetRows is only available on web.');
  }
  Future<List<Map<String, String>>> getAvailablePhones(String spreadsheetId, String sheetName) async {
    throw UnsupportedError('SheetService.getAvailablePhones is only available on web.');
  }
  Future<Map<String, dynamic>> getPhoneSummary(String spreadsheetId, String sheetName) async {
    throw UnsupportedError('SheetService.getPhoneSummary is only available on web.');
  }
} 