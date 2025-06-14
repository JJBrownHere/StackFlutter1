class AnalyticsService {
  AnalyticsService([dynamic a, dynamic b]);
  Future<bool> isConnected() async => false;
  Future<void> initiateOAuth() async => throw UnimplementedError();
  Future<List<Map<String, dynamic>>> fetchGA4Properties(String accessToken) async => [];
  Future<void> saveSelectedProperty(String accessToken, String propertyId) async => throw UnimplementedError();
  Future<void> disconnect() async => throw UnimplementedError();
  Future<String?> getStoredToken() async => null;
  Future<Map<String, dynamic>> getAnalyticsData() async => throw UnimplementedError();
} 