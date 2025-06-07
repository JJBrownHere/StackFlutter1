import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_screen.dart';
import 'dart:html' as html;

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _sheets = [];

  @override
  void initState() {
    super.initState();
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
          .from('sheets')
          .select()
          .eq('user_id', user.id);
      setState(() {
        _profile = profile;
        _sheets = List<Map<String, dynamic>>.from(sheets);
        _isLoading = false;
      });
    } else {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _createSheet(String type, String sheetName) async {
    setState(() { _isLoading = true; });
    // TODO: Replace with your Google Sheets creation logic
    final sheetId = DateTime.now().millisecondsSinceEpoch.toString(); // Placeholder
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      await Supabase.instance.client.from('sheets').insert({
        'user_id': user.id,
        'type': type,
        'sheet_id': sheetId,
        'sheet_name': sheetName,
      });
      await _loadProfileAndSheets();
    }
    setState(() { _isLoading = false; });
  }

  Widget _buildSheetSection(String type, String label) {
    final sheet = _sheets.firstWhere(
      (s) => s['type'] == type,
      orElse: () => {},
    );
    if (sheet.isEmpty) {
      return ElevatedButton(
        onPressed: () => _createSheet(type, label),
        child: Text('Create $label'),
      );
    } else {
      return ListTile(
        title: Text('$label: Connected'),
        subtitle: Text(sheet['sheet_name'] ?? ''),
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
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSheetSection('lead', 'STACKS Lead Sheet'),
                    _buildSheetSection('inventory', 'STACKS Inventory Sheet'),
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
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Toggle dark theme'),
                  value: Theme.of(context).brightness == Brightness.dark,
                  onChanged: (isDark) {
                    final appState = context.findAncestorStateOfType<MyAppState>();
                    appState?.setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
                  },
                  secondary: Icon(
                    Theme.of(context).brightness == Brightness.dark
                        ? Icons.dark_mode
                        : Icons.light_mode,
                  ),
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
    return Card(
      elevation: 2,
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