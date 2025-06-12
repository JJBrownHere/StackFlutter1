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
  String _phoneSearch = '';
  bool _phonesExpanded = false;
  List<Map<String, String>> _availablePhones = [];
  bool _loadingPhones = false;
  String? _lastSheetId;

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
    if (kIsWeb) {
      await SheetService.loadApiKeys();
    } else {
      // For mobile, load synchronously
      SheetService.loadApiKeys();
    }
    await _restoreLinkedSheet();
    await _loadSummary();
    await _loadAvailablePhones();
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
    if (_sheetId == null || _sheetId!.isEmpty) {
      setState(() {
        _error = 'No Google Sheet selected. Please pick a sheet to view inventory.';
        _isLoading = false;
      });
      return;
    }
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
      final normalizedKey = key.trim();
      if (uniqueEntries.containsKey(normalizedKey)) {
        uniqueEntries[normalizedKey] = uniqueEntries[normalizedKey]! + value;
      } else {
        uniqueEntries[normalizedKey] = value;
      }
    });
    List<MapEntry<String, int>> entries = uniqueEntries.entries.toList();
    if (title.toLowerCase().contains('storage')) {
      // Sort storage: TB > GB, numerically descending
      int storageValue(String s) {
        final match = RegExp(r'(\d+)(TB|GB)').firstMatch(s.toUpperCase());
        if (match == null) return 0;
        int num = int.tryParse(match.group(1) ?? '0') ?? 0;
        String unit = match.group(2) ?? 'GB';
        return unit == 'TB' ? num * 1024 : num;
      }
      entries.sort((a, b) => storageValue(b.key).compareTo(storageValue(a.key)));
    } else if (title.toLowerCase().contains('color')) {
      // Sort colors alphabetically
      entries.sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));
    }
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(
              title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
        initiallyExpanded: false,
        children: entries.map((entry) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
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
        )).toList(),
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

  Future<void> _loadAvailablePhones() async {
    if (_sheetId == null || _sheetId!.isEmpty) {
      setState(() {
        _availablePhones = [];
        _loadingPhones = false;
        _lastSheetId = null;
      });
      return;
    }
    if (_sheetId == _lastSheetId) return; // Don't reload if same sheet
    setState(() { _loadingPhones = true; });
    try {
      final phones = await _sheetService.getAvailablePhones(_sheetId!, _sheetTab);
      setState(() {
        _availablePhones = phones;
        _loadingPhones = false;
        _lastSheetId = _sheetId;
      });
    } catch (e) {
      setState(() {
        _availablePhones = [];
        _loadingPhones = false;
        _lastSheetId = _sheetId;
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
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/account');
                  },
                  child: const Text('Visit Your Account Page'),
                ),
                const SizedBox(height: 16),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
                if (_error != null)
                  SizedBox.shrink(),
                if (_summary != null)
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.85,
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
                        const SizedBox(height: 16),
                        _buildAvailablePhonesSection(),
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

  Widget _buildAvailablePhonesSection() {
    // Custom order for iPhones (newest to oldest)
    final customOrder = [
      'iPhone 16 Pro Max', 'iPhone 16 Pro', 'iPhone 16 Plus', 'iPhone 16',
      'iPhone 15 Pro Max', 'iPhone 15 Pro', 'iPhone 15 Plus', 'iPhone 15',
      'iPhone 14 Pro Max', 'iPhone 14 Pro', 'iPhone 14 Plus', 'iPhone 14',
      'iPhone 13 Pro Max', 'iPhone 13 Pro', 'iPhone 13 Mini', 'iPhone 13',
      'iPhone 12 Pro Max', 'iPhone 12 Pro', 'iPhone 12 Mini', 'iPhone 12',
      'iPhone 11 Pro Max', 'iPhone 11 Pro', 'iPhone 11',
      'iPhone XS Max', 'iPhone XS', 'iPhone XR',
      'iPhone X',
      'iPhone 8 Plus', 'iPhone 8',
      'iPhone 7 Plus', 'iPhone 7',
      'iPhone 6s Plus', 'iPhone 6s',
      'iPhone 6 Plus', 'iPhone 6',
      'iPhone SE3', 'iPhone SE2', 'iPhone SE',
    ];
    String normalize(String s) => s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
    final phones = List<Map<String, String>>.from(_availablePhones);
    phones.sort((a, b) {
      final aModel = a['Model'] ?? '';
      final bModel = b['Model'] ?? '';
      final aNorm = normalize(aModel);
      final bNorm = normalize(bModel);
      final aIndex = customOrder.map((e) => e.toLowerCase()).toList().indexOf(aNorm);
      final bIndex = customOrder.map((e) => e.toLowerCase()).toList().indexOf(bNorm);
      if (aIndex == -1 && bIndex == -1) {
        return bModel.compareTo(aModel); // fallback: alpha, newest first
      } else if (aIndex == -1) {
        return 1;
      } else if (bIndex == -1) {
        return -1;
      } else {
        return aIndex.compareTo(bIndex);
      }
    });
    final filteredPhones = _phoneSearch.isEmpty
        ? phones
        : phones.where((phone) {
            final model = (phone['Model'] ?? '').toLowerCase();
            final storage = (phone['Storage'] ?? '').toLowerCase();
            final condition = (phone['Condition'] ?? '').toLowerCase();
            final search = _phoneSearch.toLowerCase();
            return model.contains(search) || storage.contains(search) || condition.contains(search);
          }).toList();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: const Text(
          'Available Phones',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        initiallyExpanded: _phonesExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            _phonesExpanded = expanded;
            if (!expanded) _phoneSearch = '';
          });
        },
        children: [
          if (_phonesExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search by model, storage, or condition',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (val) {
                  setState(() {
                    _phoneSearch = val;
                  });
                },
              ),
            ),
          if (_loadingPhones)
            const Center(child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            )),
          if (!_loadingPhones && filteredPhones.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No phones match your search.'),
            ),
          ...filteredPhones.map((phone) {
            final model = phone['Model'] ?? '';
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: ListTile(
                title: Text(model),
                subtitle: Text('${phone['Storage'] ?? ''} | ${phone['Condition'] ?? ''}'),
                trailing: Text('${phone['Price'] ?? ''}'),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(covariant InventorySummaryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadAvailablePhones();
  }
} 