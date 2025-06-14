import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Only import dart:html for web
// Only import flutter_web_auth for mobile
import 'package:flutter_web_auth/flutter_web_auth.dart';

class AnalyticsService {
  static const String _clientId = '670058417215-npdc8in6n4kalmkj073sqrj1aaf8g4h8.apps.googleusercontent.com';
  static const String _redirectUri = 'https://itscrazyamazing.com/oauth2callback';
  static const String _scope = 'https://www.googleapis.com/auth/analytics.readonly https://www.googleapis.com/auth/analytics.edit https://www.googleapis.com/auth/analytics.manage.users.readonly https://www.googleapis.com/auth/analytics.manage.users';
  static const String _tokenEndpoint = 'https://oauth2.googleapis.com/token';

  final SharedPreferences _prefs;
  final SupabaseClient _supabase;

  AnalyticsService(this._prefs, this._supabase);

  Future<bool> isConnected() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;
    final profile = await _supabase.from('profiles').select().eq('id', user.id).maybeSingle();
    return profile != null && profile['ga4_id'] != null && profile['ga4_id'].toString().isNotEmpty;
  }

  Future<void> initiateOAuth() async {
    final authUrl = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
      'client_id': _clientId,
      'redirect_uri': _redirectUri,
      'response_type': 'token',
      'scope': _scope,
      'include_granted_scopes': 'true',
      'prompt': 'consent',
    });
    if (kIsWeb) {
      // Only import dart:html here
      // ignore: avoid_web_libraries_in_flutter
      import 'dart:html' as html;
      html.window.location.href = authUrl.toString();
    } else {
      final result = await FlutterWebAuth.authenticate(
        url: authUrl.toString(),
        callbackUrlScheme: 'https',
      );
      // Parse the access token from the result URL
      final uri = Uri.parse(result);
      final accessToken = uri.queryParameters['access_token'];
      if (accessToken != null) {
        // Handle callback as on web
        // You may want to call a callback or update state here
      }
    }
  }

  Future<List<Map<String, dynamic>>> fetchGA4Properties(String accessToken) async {
    // Get accounts first
    final accountsResp = await http.get(
      Uri.parse('https://analyticsadmin.googleapis.com/v2/accounts'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (accountsResp.statusCode != 200) throw Exception('Failed to fetch accounts');
    final accounts = jsonDecode(accountsResp.body)['accounts'] as List?;
    if (accounts == null || accounts.isEmpty) return [];
    final accountId = accounts[0]['name']; // e.g. 'accounts/123456789'
    // Get properties for the first account
    final propsResp = await http.get(
      Uri.parse('https://analyticsadmin.googleapis.com/v2/$accountId/properties'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (propsResp.statusCode != 200) throw Exception('Failed to fetch properties');
    final properties = jsonDecode(propsResp.body)['properties'] as List?;
    if (properties == null) return [];
    return List<Map<String, dynamic>>.from(properties);
  }

  Future<void> saveSelectedProperty(String accessToken, String propertyId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    await _prefs.setString('analytics_token', accessToken);
    await _supabase.from('profiles').update({
      'ga4_id': propertyId,
      'ga_oauth_connected': true,
    }).eq('id', user.id);
  }

  Future<void> disconnect() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    await _prefs.remove('analytics_token');
    await _supabase.from('profiles').update({
      'ga4_id': null,
      'ga_oauth_connected': false,
    }).eq('id', user.id);
  }

  Future<String?> getStoredToken() async {
    return _prefs.getString('analytics_token');
  }

  Future<Map<String, dynamic>> getAnalyticsData() async {
    final token = await getStoredToken();
    final user = _supabase.auth.currentUser;
    if (token == null || user == null) {
      throw Exception('Not connected to Google Analytics');
    }
    final profile = await _supabase.from('profiles').select().eq('id', user.id).maybeSingle();
    final ga4Id = profile?['ga4_id'];
    if (ga4Id == null || ga4Id.toString().isEmpty) {
      throw Exception('No GA4 property selected');
    }
    final endpoint = 'https://analyticsdata.googleapis.com/v1beta/${ga4Id}:runReport';
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'dateRanges': [{
          'startDate': '30daysAgo',
          'endDate': 'today',
        }],
        'dimensions': [{
          'name': 'date',
        }],
        'metrics': [
          {'name': 'activeUsers'},
          {'name': 'screenPageViews'},
          {'name': 'sessions'},
        ],
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch analytics data: ${response.body}');
    }
    return jsonDecode(response.body);
  }
} 