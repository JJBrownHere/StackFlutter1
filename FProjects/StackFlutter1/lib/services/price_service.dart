import 'package:http/http.dart' as http;
import 'dart:convert';

class PriceService {
  static const String _apiKey = 'NT5-IKU-RBE-B7T-FX8-ILZ';
  static const String _baseUrl = 'https://data-api.buyback.tools';
  static const String _defaultCategory = 'Smartphone';
  static const String _defaultBrand = 'Apple';

  Map<String, String> _createHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<dynamic> _fetchApi(String endpoint, Map<String, dynamic> data) async {
    final queryParams = {
      'api_key': _apiKey,
    };
    final uri = Uri.parse('$_baseUrl/${endpoint.replaceAll(RegExp(r'^\/+|\/+$'), '')}')
        .replace(queryParameters: queryParams);
    
    final requestBody = {
      'category': _defaultCategory,
      ...data,
    };
    
    print('Making API request:');
    print('URL: $uri');
    print('Headers: ${_createHeaders()}');
    print('Body: $requestBody');

    try {
      final response = await http.post(
        uri,
        headers: _createHeaders(),
        body: json.encode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('API request failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Network error: $e');
      throw Exception('Failed to fetch data: $e');
    }
  }

  Future<List<String>> getIPhoneModels() async {
    try {
      final response = await _fetchApi('getModels', {
        'brand': _defaultBrand,
      });
      return List<String>.from(response['models'] ?? []);
    } catch (e) {
      print('Error getting iPhone models: $e');
      throw Exception('Failed to fetch iPhone models: $e');
    }
  }

  Future<List<String>> getStorageSizes(String modelId) async {
    try {
      final response = await _fetchApi('getStorageSizes', {
        'deviceName': modelId,
        'brand': _defaultBrand,
      });
      return List<String>.from(response['storageSizes'] ?? []);
    } catch (e) {
      print('Error getting storage sizes: $e');
      throw Exception('Failed to fetch storage sizes: $e');
    }
  }

  Future<List<String>> getLockStatuses(String modelId, String storageSize) async {
    try {
      final response = await _fetchApi('getLockStatuses', {
        'deviceName': modelId,
        'storageSize': storageSize,
        'brand': _defaultBrand,
      });
      return List<String>.from(response['lockStatuses'] ?? []);
    } catch (e) {
      print('Error getting lock statuses: $e');
      throw Exception('Failed to fetch lock statuses: $e');
    }
  }

  Future<Map<String, dynamic>> getPrice({
    required String model,
    required String storage,
    required String condition,
  }) async {
    try {
      final response = await _fetchApi('getPrices', {
        'brand': _defaultBrand,
        'deviceName': model,
        'storageSize': storage,
        'lockStatus': condition,
      });

      // Return the full pricing data structure
      return {
        'pricing': response['pricing'] ?? {},
        'summary': {
          'deviceName': model,
          'storageSize': storage,
          'condition': condition,
          'highestPrice': response['highestPrice'] ?? 0.0,
          'averagePrice': response['averagePrice'] ?? 0.0,
        },
      };
    } catch (e) {
      print('Error getting price: $e');
      throw Exception('Failed to fetch price data: $e');
    }
  }
} 