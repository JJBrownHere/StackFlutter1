import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_screen.dart';
import '../services/inventory_sheet_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/glass_container.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _sheets = [];
  final _inventorySheetService = InventorySheetService();
  TextEditingController _sheetUrlController = TextEditingController();
  TextEditingController _sickwApiController = TextEditingController();
  bool _savingSickwApi = false;
  final _encryptionKey = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');
  final _iv = encrypt.IV.fromLength(16);
  late final encrypt.Encrypter _encrypter;

  @override
  void initState() {
    super.initState();
    _encrypter = encrypt.Encrypter(encrypt.AES(_encryptionKey));
    _loadProfileAndSheets();
  }

  Future<void> _loadProfileAndSheets() async {
    setState(() { _isLoading = true; });
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      final sheets = await Supabase.instance.client
          .from('leadsSheets')
          .select()
          .eq('user_id', user.id);
      setState(() {
        _profile = profile;
        _sheets = List<Map<String, dynamic>>.from(sheets);
        _isLoading = false;
        _sickwApiController.text = '';
      });
    } else {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _saveSickwApiKey() async {
    setState(() { _savingSickwApi = true; });
    final user = Supabase.instance.client.auth.currentUser;
    final key = _sickwApiController.text.trim();
    if (user != null && key.isNotEmpty) {
      final encrypted = _encrypter.encrypt(key, iv: _iv).base64;
      await Supabase.instance.client.from('profiles').update({'SickwAPI': encrypted}).eq('id', user.id);
      await _loadProfileAndSheets();
    }
    setState(() { _savingSickwApi = false; });
  }

  Future<void> _createInventorySheet() async {
    setState(() { _isLoading = true; });
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('User not logged in or email not available');
      }

      // Ensure profile exists
      final profile = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      if (profile == null) {
        await Supabase.instance.client.from('profiles').insert({
          'id': user.id,
          'email': user.email,
          // Add other required fields with defaults if needed
        });
      }

      final sheetId = await _inventorySheetService.createInventorySheet(user.email!);
      
      await Supabase.instance.client.from('inventorySheets').insert({
        'user_id': user.id,
        'sheet_id': sheetId,
        'created_at': DateTime.now().toIso8601String(),
      });

      await _loadProfileAndSheets();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inventory sheet created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating inventory sheet: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  Future<void> _createSheet(String type, String sheetName) async {
    setState(() { _isLoading = true; });
    try {
    final user = Supabase.instance.client.auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('User not logged in or email not available');
      }
      // Call the backend Cloud Function for lead sheet creation
      final response = await http.post(
        Uri.parse('https://us-central1-stackflutter1.cloudfunctions.net/createSheet'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'sheetType': type, 'userEmail': user.email}),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to create sheet: ${response.body}');
      }
      final data = json.decode(response.body);
      final sheetId = data['sheetId'] ?? data['sheetUrl'] ?? '';
      await Supabase.instance.client.from('leadsSheets').insert({
        'user_id': user.id,
        'type': type,
        'sheet_id': sheetId,
        'sheet_name': sheetName,
      });
      await _loadProfileAndSheets();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lead sheet created and shared!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating lead sheet: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  Future<void> _connectCustomInventorySheet() async {
    setState(() { _isLoading = true; });
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('User not logged in or email not available');
      }
      final url = _sheetUrlController.text.trim();
      final reg = RegExp(r'/d/([a-zA-Z0-9-_]+)');
      final match = reg.firstMatch(url);
      String? sheetId;
      if (match != null) {
        sheetId = match.group(1);
      } else if (url.length > 20 && !url.contains('/')) {
        sheetId = url;
      }
      if (sheetId == null) throw Exception('Invalid Google Sheet URL or ID');

      // Ensure profile exists
      final profile = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      if (profile == null) {
        await Supabase.instance.client.from('profiles').insert({
          'id': user.id,
          'email': user.email,
        });
      }

      // Upsert inventorySheets (replace if exists)
      final existing = await Supabase.instance.client
          .from('inventorySheets')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();
      if (existing != null) {
        await Supabase.instance.client.from('inventorySheets').update({
          'sheet_id': sheetId,
          'created_at': DateTime.now().toIso8601String(),
        }).eq('user_id', user.id);
      } else {
        await Supabase.instance.client.from('inventorySheets').insert({
          'user_id': user.id,
          'sheet_id': sheetId,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
      await _loadProfileAndSheets();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inventory sheet connected successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error connecting inventory sheet: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
    setState(() { _isLoading = false; });
      }
    }
  }

  Widget _buildSheetSection(String type, String label) {
    final sheet = _sheets.firstWhere(
      (s) => s['type'] == type,
      orElse: () => {},
    );
    if (type == 'inventory') {
      // Check if inventory sheet is linked in inventorySheets
      final user = Supabase.instance.client.auth.currentUser;
      return FutureBuilder<List<dynamic>>(
        future: user == null
            ? Future.value([])
            : Supabase.instance.client
                .from('inventorySheets')
                .select()
                .eq('user_id', user.id)
                .order('created_at', ascending: false)
                .limit(1),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const CircularProgressIndicator();
          }
          final inventorySheets = snapshot.data ?? [];
          if (inventorySheets.isEmpty) {
            // Not linked: show create button
            return ElevatedButton(
              onPressed: _isLoading ? null : _createInventorySheet,
              child: _isLoading 
                ? const CircularProgressIndicator()
                : const Text('Create STACKS Inventory Sheet'),
            );
          } else {
            // Linked: show link out to Google Sheet
            final sheetId = inventorySheets[0]['sheet_id'];
            final sheetName = inventorySheets[0]['sheet_name'] ?? 'Google Sheet';
            return ListTile(
              title: Row(
                children: [
                  const Text('STACKS Inventory Sheet: Connected'),
                  const SizedBox(width: 8),
                  const Icon(Icons.verified, color: Colors.green, size: 20),
                ],
              ),
              subtitle: Text(sheetName),
              trailing: IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: () {
                  final url = 'https://docs.google.com/spreadsheets/d/$sheetId';
                  launchUrl(Uri.parse(url));
                },
              ),
            );
          }
        },
      );
    } else {
      if (sheet.isEmpty) {
        return ElevatedButton(
          onPressed: () => _createSheet(type, label),
          child: Text('Create $label'),
        );
      } else {
        final sheetName = sheet['sheet_name'] ?? 'Google Sheet';
        return ListTile(
          title: Row(
            children: [
              Text('$label: Connected'),
              const SizedBox(width: 8),
              const Icon(Icons.verified, color: Colors.green, size: 20),
            ],
          ),
          subtitle: Text(sheetName),
          trailing: IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: () {
              final url = 'https://docs.google.com/spreadsheets/d/${sheet['sheet_id']}';
              launchUrl(Uri.parse(url));
            },
          ),
        );
      }
    }
  }

  Widget _buildCustomSheetOption(bool show) {
    if (!show) return SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Use your current ECOM STACKS Feed',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _sheetUrlController,
                decoration: const InputDecoration(
                  hintText: 'Paste Google Sheet URL or ID',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _connectCustomInventorySheet,
              child: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Connect'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? 'Not signed in';

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoCard(
              title: 'Account Information',
              children: [
                _buildInfoRow('Email', email),
                _buildInfoRow('Account Type', 'Business'),
                _buildInfoRow('Member Since', '2024'),
              ],
            ),
            const SizedBox(height: 16),
            // Google Sheets section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Google Sheets',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            GlassContainer(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSheetSection('lead', 'STACKS Lead Sheet'),
                    _buildSheetSection('inventory', 'STACKS Inventory Sheet'),
                    _buildCustomSheetOption(true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Google Analytics section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Google Analytics',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            GlassContainer(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((_profile?['ga4_id'] ?? '').toString().isNotEmpty || (_profile?['ga_oauth_connected'] ?? false) == true) ...[
                      Row(
                        children: const [
                          Icon(Icons.verified, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Google Analytics Connected ✅', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              enabled: !(_profile?['ga4_id'] ?? '').toString().isNotEmpty,
                              controller: TextEditingController(),
                              decoration: const InputDecoration(
                                labelText: 'Enter GA4 Measurement ID',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: (_profile?['ga4_id'] ?? '').toString().isNotEmpty ? null : () async {
                              // Save GA4 ID logic
                              final user = Supabase.instance.client.auth.currentUser;
                              final ga4Id = '';
                              // TODO: Get value from TextField
                              if (user != null && ga4Id.isNotEmpty) {
                                await Supabase.instance.client.from('profiles').update({'ga4_id': ga4Id}).eq('id', user.id);
                                await _loadProfileAndSheets();
                              }
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: (_profile?['ga_oauth_connected'] ?? false) == true ? null : () async {
                          // Placeholder for Google OAuth connect
                          final user = Supabase.instance.client.auth.currentUser;
                          if (user != null) {
                            await Supabase.instance.client.from('profiles').update({'ga_oauth_connected': true}).eq('id', user.id);
                            await _loadProfileAndSheets();
                          }
                        },
                        child: const Text('Connect Your Google Analytics Account'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // IMEI Integration section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'IMEI Integration',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            GlassContainer(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_profile != null && (_profile!['SickwAPI'] ?? '').toString().isNotEmpty) ...[
                      Row(
                        children: const [
                          Icon(Icons.verified, color: Colors.green),
                          SizedBox(width: 8),
                          Text('SickW API Key Connected ✅', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Builder(
                        builder: (context) {
                          return GestureDetector(
                            onTap: () async {
                              const url = 'https://SickW.com';
                              if (Theme.of(context).platform == TargetPlatform.iOS || Theme.of(context).platform == TargetPlatform.android) {
                                await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                              } else {
                                await launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');
                              }
                            },
                            child: const Text(
                              'Manage your SickW Account',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          );
                        },
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _sickwApiController,
                              decoration: const InputDecoration(
                                labelText: 'Enter SickW API Key',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _savingSickwApi ? null : _saveSickwApiKey,
                            child: _savingSickwApi
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Text('Save'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Builder(
                        builder: (context) {
                          return GestureDetector(
                            onTap: () async {
                              const url = 'https://SickW.com';
                              if (Theme.of(context).platform == TargetPlatform.iOS || Theme.of(context).platform == TargetPlatform.android) {
                                await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                              } else {
                                await launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');
                              }
                            },
                            child: const Text(
                              'Get your SickW API Key Here',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Preferences',
              children: [
                SwitchListTile(
                  title: const Text('Email Notifications'),
                  value: true,
                  onChanged: (value) {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await Supabase.instance.client.auth.signOut();
                    globalRefreshSession(context);
                    if (mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
} 