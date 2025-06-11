import 'package:flutter/material.dart';
import '../services/sheet_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../helpers/keyboard_dismiss_wrapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class InventorySummaryScreen extends StatefulWidget {
  const InventorySummaryScreen({super.key});

  @override
  State<InventorySummaryScreen> createState() => _InventorySummaryScreenState();
}

class _InventorySummaryScreenState extends State<InventorySummaryScreen> {
  final _sheetService = SheetService();
  bool _isLoading = false;
  Map<String, dynamic>? _summary;
  String? _error;
  String? _sheetId;
  String _sheetTab = 'Smartphone';
  final _sheetController = TextEditingController();
  String? _sheetGid;

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initAndLoad();
  }

  Future<void> _initAndLoad() async {
    await _restoreLinkedSheet();
    await _loadSummary();
  }

  Future<void> _saveSummaryToSupabase(Map<String, dynamic> summary) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    await Supabase.instance.client.from('inventorySheets').insert({
      'user_id': user.id,
      'sheet_id': _sheetId,
      'sheet_tab': _sheetTab,
      'summary': summary,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _loadSummary() async {
    if (_sheetId == null) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      print('DEBUG: Loading summary for sheet ID: $_sheetId, tab: $_sheetTab');
      final summary = await _sheetService.getPhoneSummary(_sheetId!, _sheetTab);
      setState(() {
        _summary = summary;
        _isLoading = false;
      });
      await _saveSummaryToSupabase(summary);
    } catch (e) {
      print('DEBUG: Error loading summary: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSheetPicked(String id) {
    print('DEBUG: Sheet picked with ID: $id');
    final extractedId = _extractSheetId(id);
    print('DEBUG: Extracted sheet ID: $extractedId');
    
    if (extractedId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid Google Sheet URL or ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _sheetId = extractedId;
      _summary = null;
    });
    _loadSummary();
  }

  Future<void> addAndLinkSheet(String sheetId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      await Supabase.instance.client.from('inventorySheets').insert({
        'user_id': user.id,
        'sheet_id': _extractSheetId(sheetId),
        'sheet_tab': _sheetTab,
        'created_at': DateTime.now().toIso8601String(),
      });
      setState(() {
        _sheetId = _extractSheetId(sheetId);
      });
      await _loadSummary();
    }
  }

  Widget _buildSheetPicker() {
    if (_sheetId != null && _sheetId!.isNotEmpty) {
      // Show only a 'View Inventory Sheet' link, not the ID
      return ListTile(
        title: const Text('Inventory Sheet Connected'),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new),
          onPressed: () {
            final url = 'https://docs.google.com/spreadsheets/d/$_sheetId';
            launchUrl(Uri.parse(url));
          },
        ),
      );
    }
    if (kIsWeb) {
      // Web: Google Picker button (placeholder for now)
      return ElevatedButton(
        onPressed: () async {
          // TODO: Integrate Google Picker API via JS interop
          // For now, prompt for ID
          final id = await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Enter Google Sheet ID'),
              content: TextField(
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Sheet ID'),
                onSubmitted: (val) => Navigator.of(context).pop(val),
              ),
            ),
          );
          if (id != null && id.isNotEmpty) _onSheetPicked(id);
        },
        child: const Text('Pick Google Sheet from Drive'),
      );
    } else {
      // Mobile: Paste URL/ID
      return Row(
        children: [
          Expanded(
            child: TextField(
              controller: _sheetController,
              decoration: const InputDecoration(
                labelText: 'Paste Google Sheet URL or ID',
              ),
              onChanged: (val) {
                final id = _extractSheetId(val);
                setState(() => _sheetId = id);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _sheetId == null || _sheetId!.isEmpty ? null : _loadSummary,
          ),
        ],
      );
    }
  }

  String? _extractSheetId(String input) {
    print('DEBUG: Extracting sheet ID from input: $input');
    // Try to match regular Google Sheets URL format
    final reg = RegExp(r'/d/([a-zA-Z0-9-_]+)');
    final match = reg.firstMatch(input);
    if (match != null) {
      final id = match.group(1);
      print('DEBUG: Found sheet ID: $id');
      return id;
    }
    // If it's just a long string without slashes, assume it's an ID
    if (input.length > 20 && !input.contains('/')) {
      print('DEBUG: Using input as direct sheet ID');
      return input;
    }
    print('DEBUG: No valid sheet ID found in input');
    return null;
  }

  Widget _buildSummaryCard(String title, Map<String, int> data) {
    final uniqueEntries = <String, int>{};
    data.forEach((key, value) {
      final normalizedKey = key.trim().toLowerCase();
      if (uniqueEntries.containsKey(normalizedKey)) {
        uniqueEntries[normalizedKey] = uniqueEntries[normalizedKey]! + value;
      } else {
        uniqueEntries[normalizedKey] = value;
      }
    });
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 8),
            ...uniqueEntries.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key),
                  Text(
                    entry.value.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _restoreLinkedSheet() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final sheets = await Supabase.instance.client
        .from('inventorySheets')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(1);
    if (sheets != null && sheets.isNotEmpty) {
      setState(() {
        _sheetId = _extractSheetId(sheets[0]['sheet_id'] ?? '');
        _sheetTab = sheets[0]['sheet_tab'] ?? 'Smartphone';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inventory Summary'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _sheetId == null || _sheetId!.isEmpty ? null : _loadSummary,
            ),
          ],
        ),
        resizeToAvoidBottomInset: true,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSheetPicker(),
                const SizedBox(height: 16),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
                if (_error != null)
                  Center(
                    child: Text(
                      'Error loading data: $_error',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (!_isLoading && _summary != null)
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Available Phones',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _summary!['totalAvailable'].toString(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSummaryCard('By Model', _summary!['byModel']),
                        _buildSummaryCard('By Storage', _summary!['byStorage']),
                        _buildSummaryCard('By Color', _summary!['byColor']),
                        _buildSummaryCard('By Condition', _summary!['byCondition']),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 