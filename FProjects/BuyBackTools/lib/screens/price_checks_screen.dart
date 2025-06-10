import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import '../services/price_service.dart';
import '../helpers/keyboard_dismiss_wrapper.dart';

class PriceChecksScreen extends StatefulWidget {
  const PriceChecksScreen({super.key});

  @override
  State<PriceChecksScreen> createState() => _PriceChecksScreenState();
}

class _PriceChecksScreenState extends State<PriceChecksScreen> {
  String? _selectedModel;
  String? _selectedStorage;
  String? _selectedCondition;
  Map<String, dynamic>? _priceData;
  bool _isLoading = false;
  bool _isLoadingModels = true;
  bool _isLoadingStorage = false;
  bool _isLoadingConditions = false;
  final _priceService = PriceService();

  List<String> _models = [];
  List<String> _storageOptions = [];
  List<String> _conditions = [];

  @override
  void initState() {
    super.initState();
    _loadModels();
  }

  Future<void> _loadModels() async {
    try {
      final models = await _priceService.getIPhoneModels();
      // Accurate order for iPhones (newest to oldest, including variants)
      final customOrder = [
        'iphone 16 pro max', 'iphone 16 pro', 'iphone 16 plus', 'iphone 16',
        'iphone 15 pro max', 'iphone 15 pro', 'iphone 15 plus', 'iphone 15',
        'iphone 14 pro max', 'iphone 14 pro', 'iphone 14 plus', 'iphone 14',
        'iphone 13 pro max', 'iphone 13 pro', 'iphone 13 mini', 'iphone 13',
        'iphone 12 pro max', 'iphone 12 pro', 'iphone 12 mini', 'iphone 12',
        'iphone 11 pro max', 'iphone 11 pro', 'iphone 11',
        'iphone xs max', 'iphone xs', 'iphone xr',
        'iphone x',
        'iphone 8 plus', 'iphone 8',
        'iphone 7 plus', 'iphone 7',
        'iphone 6s plus', 'iphone 6s',
        'iphone 6 plus', 'iphone 6',
        'iphone se3', 'iphone se2', 'iphone se',
      ];
      String normalize(String s) => s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
      models.sort((a, b) {
        final aNorm = normalize(a);
        final bNorm = normalize(b);
        final aIndex = customOrder.indexOf(aNorm);
        final bIndex = customOrder.indexOf(bNorm);
        if (aIndex == -1 && bIndex == -1) {
          return aNorm.compareTo(bNorm); // fallback: alpha
        } else if (aIndex == -1) {
          return 1;
        } else if (bIndex == -1) {
          return -1;
        } else {
          return aIndex.compareTo(bIndex);
        }
      });
      setState(() {
        _models = models;
        _isLoadingModels = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingModels = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading iPhone models: $e')),
        );
      }
    }
  }

  Future<void> _loadStorageOptions(String modelId) async {
    setState(() {
      _isLoadingStorage = true;
      _storageOptions = [];
      _selectedStorage = null;
      _conditions = [];
      _selectedCondition = null;
    });

    try {
      final storageOptions = await _priceService.getStorageSizes(modelId);
      // Sort storage options numerically (e.g., 64GB, 128GB, ..., 1TB)
      storageOptions.sort((a, b) {
        // Convert to bytes for comparison
        int toBytes(String s) {
          final match = RegExp(r'(\d+)([GT]B)').firstMatch(s);
          if (match == null) return 0;
          final num = int.parse(match.group(1)!);
          final unit = match.group(2)!;
          return unit == 'TB' ? num * 1024 : num; // Convert TB to GB equivalent
        }
        return toBytes(a).compareTo(toBytes(b));
      });
      setState(() {
        _storageOptions = storageOptions;
        _isLoadingStorage = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingStorage = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading storage options: $e')),
        );
      }
    }
  }

  Future<void> _loadConditions(String modelId, String storageSize) async {
    setState(() {
      _isLoadingConditions = true;
      _conditions = [];
      _selectedCondition = null;
    });

    try {
      final conditions = await _priceService.getLockStatuses(modelId, storageSize);
      setState(() {
        _conditions = conditions;
        _isLoadingConditions = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingConditions = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading conditions: $e')),
        );
      }
    }
  }

  Future<void> _fetchPriceData() async {
    if (_selectedModel == null || 
        _selectedStorage == null || 
        _selectedCondition == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final priceData = await _priceService.getPrice(
        model: _selectedModel!,
        storage: _selectedStorage!,
        condition: _selectedCondition!,
      );

      setState(() {
        _priceData = priceData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching price data: $e')),
        );
      }
    }
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    bool isLoading = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: isLoading
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: value,
                      isExpanded: true,
                      hint: Text('Select $label'),
                      items: items.map((String item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: onChanged,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradedPricing(BuildContext context, Map<String, dynamic> buybackPricing) {
    final companies = buybackPricing.keys.toList();
    final grades = [
      {'id': 'aGrade', 'label': 'A Grade'},
      {'id': 'bGrade', 'label': 'B Grade'},
      {'id': 'cGrade', 'label': 'C Grade'},
      {'id': 'dGrade', 'label': 'D Grade'},
    ];
    final isMobile = MediaQuery.of(context).size.width < 600;
    // Find max per grade
    Map<String, double> maxPerGrade = {};
    for (var g in grades) {
      double max = 0;
      for (var company in companies) {
        final val = buybackPricing[company][g['id']];
        if (val != null && val > max) max = val.toDouble();
      }
      maxPerGrade[g['id']!] = max;
    }
    if (!isMobile) {
      // Table layout for wide screens
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('GRADED PRICING', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.blueGrey.shade50),
                columns: [
                  const DataColumn(label: Text('Company', style: TextStyle(fontWeight: FontWeight.bold))),
                  ...grades.map((g) => DataColumn(label: Text(g['label']!, style: const TextStyle(fontWeight: FontWeight.bold))))
                ],
                rows: List<DataRow>.generate(companies.length, (index) {
                  final company = companies[index];
                  final prices = buybackPricing[company];
                  return DataRow(
                    color: MaterialStateProperty.all(index % 2 == 0 ? Colors.white : Colors.grey.shade100),
                    cells: [
                      DataCell(Text(company)),
                      ...grades.map((g) {
                        final val = prices[g['id']];
                        final isMax = val != null && val.toDouble() == maxPerGrade[g['id']];
                        return DataCell(Text(
                          val != null ? val.toStringAsFixed(2) : '-',
                          style: TextStyle(
                            fontFeatures: const [FontFeature.tabularFigures()],
                            fontWeight: isMax ? FontWeight.bold : null,
                            color: isMax ? Colors.green : null,
                          ),
                        ));
                      }),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      );
    } else {
      // Card layout for mobile, two cards per row
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('GRADED PRICING', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final company in companies)
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 40) / 2, // 2 cards per row with some margin
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(company, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ...grades.map((g) {
                            final val = buybackPricing[company][g['id']];
                            final isMax = val != null && val.toDouble() == maxPerGrade[g['id']];
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(g['label']!),
                                Text(
                                  val != null ? val.toStringAsFixed(2) : '-',
                                  style: TextStyle(
                                    fontWeight: isMax ? FontWeight.bold : null,
                                    color: isMax ? Colors.green : null,
                                  ),
                                )
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildTradeInPricing(BuildContext context, Map<String, dynamic> tradeinPricing) {
    final companies = [
      {'id': 'apple', 'label': 'Apple'},
      {'id': 'att', 'label': 'ATT'},
      {'id': 'tmobile', 'label': 'TMobile'},
      {'id': 'verizon', 'label': 'Verizon'},
    ];
    final isMobile = MediaQuery.of(context).size.width < 600;
    // Find max value
    double maxValue = 0;
    for (var c in companies) {
      final value = tradeinPricing[c['id']] != null ? tradeinPricing[c['id']]['upTo'] : null;
      if (value != null && value > maxValue) maxValue = value.toDouble();
    }
    if (!isMobile) {
      // Table layout for wide screens
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('TRADEIN PRICING (Up To)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.blueGrey.shade50),
                columns: companies.map((c) => DataColumn(label: Text(c['label']!, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
                rows: [
                  DataRow(
                    color: MaterialStateProperty.all(Colors.white),
                    cells: companies.map((c) {
                      final value = tradeinPricing[c['id']] != null ? tradeinPricing[c['id']]['upTo'] : null;
                      final isMax = value != null && value.toDouble() == maxValue;
                      return DataCell(Text(
                        value != null ? value.toStringAsFixed(2) : '-',
                        style: TextStyle(
                          fontFeatures: const [FontFeature.tabularFigures()],
                          fontWeight: isMax ? FontWeight.bold : null,
                          color: isMax ? Colors.green : null,
                        ),
                      ));
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      // Card layout for mobile
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('TRADEIN PRICING (Up To)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          ...companies.map((c) {
            final value = tradeinPricing[c['id']] != null ? tradeinPricing[c['id']]['upTo'] : null;
            final isMax = value != null && value.toDouble() == maxValue;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(c['label']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      value != null ? value.toStringAsFixed(2) : '-',
                      style: TextStyle(
                        fontWeight: isMax ? FontWeight.bold : null,
                        color: isMax ? Colors.green : null,
                      ),
                    )
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      );
    }
  }

  Widget _buildSellerPricing(BuildContext context, Map<String, dynamic> salePricing) {
    final vendors = [
      {'id': 'gazelle', 'label': 'Gazelle'},
      {'id': 'itsworthmore', 'label': "It's Worth More"},
      {'id': 'plugtech', 'label': 'Plug.Tech'},
    ];
    final conditions = [
      {'id': 'likeNew', 'label': 'Like New'},
      {'id': 'excellent', 'label': 'Excellent'},
      {'id': 'veryGood', 'label': 'Very Good'},
      {'id': 'good', 'label': 'Good'},
      {'id': 'fair', 'label': 'Fair'},
      {'id': 'ecofriendly', 'label': 'Ecofriendly'},
    ];
    final isMobile = MediaQuery.of(context).size.width < 600;
    // Find max per condition
    Map<String, double> maxPerCond = {};
    for (var c in conditions) {
      double max = 0;
      for (var vendor in vendors) {
        final val = salePricing[vendor['id']] != null ? salePricing[vendor['id']][c['id']] : null;
        if (val != null && val > max) max = val.toDouble();
      }
      maxPerCond[c['id']!] = max;
    }
    if (!isMobile) {
      // Table layout for wide screens
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('SELLER PRICING', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.blueGrey.shade50),
                columns: [
                  const DataColumn(label: Text('Vendor', style: TextStyle(fontWeight: FontWeight.bold))),
                  ...conditions.map((c) => DataColumn(label: Text(c['label']!, style: const TextStyle(fontWeight: FontWeight.bold))))
                ],
                rows: List<DataRow>.generate(vendors.length, (index) {
                  final vendor = vendors[index];
                  final prices = salePricing[vendor['id']] ?? {};
                  return DataRow(
                    color: MaterialStateProperty.all(index % 2 == 0 ? Colors.white : Colors.grey.shade100),
                    cells: [
                      DataCell(Text(vendor['label']!)),
                      ...conditions.map((c) {
                        final val = prices[c['id']];
                        final isMax = val != null && val.toDouble() == maxPerCond[c['id']];
                        return DataCell(Text(
                          val != null ? val.toStringAsFixed(2) : '-',
                          style: TextStyle(
                            fontFeatures: const [FontFeature.tabularFigures()],
                            fontWeight: isMax ? FontWeight.bold : null,
                            color: isMax ? Colors.green : null,
                          ),
                        ));
                      }),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      );
    } else {
      // Card layout for mobile
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('SELLER PRICING', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          ...vendors.map((vendor) {
            final prices = salePricing[vendor['id']] ?? {};
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vendor['label']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ...conditions.map((c) {
                      final val = prices[c['id']];
                      final isMax = val != null && val.toDouble() == maxPerCond[c['id']];
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(c['label']!),
                          Text(
                            val != null ? val.toStringAsFixed(2) : '-',
                            style: TextStyle(
                              fontWeight: isMax ? FontWeight.bold : null,
                              color: isMax ? Colors.green : null,
                            ),
                          )
                        ],
                      );
                    }),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      );
    }
  }

  Widget _buildPriceDisplay() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_priceData == null) {
      return const Center(
        child: Text(
          'Select all options to see price data',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    final pricing = _priceData!['pricing'] as Map<String, dynamic>?;
    final summary = _priceData!['summary'] as Map<String, dynamic>?;

    if (pricing == null || summary == null) {
      return const Center(
        child: Text(
          'No price data available',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Price Summary',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Text('Device: ${summary['deviceName']}'),
                Text('Storage: ${summary['storageSize']}'),
                Text('Condition: ${summary['condition']}'),
              ],
            ),
          ),
        ),
        if (pricing['buybackPricing'] != null)
          _buildGradedPricing(context, pricing['buybackPricing']),
        if (pricing['tradeinPricing'] != null)
          _buildTradeInPricing(context, pricing['tradeinPricing']),
        if (pricing['salePricing'] != null)
          _buildSellerPricing(context, pricing['salePricing']),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingModels) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('iPhone Price Check'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: KeyboardDismissOnTap(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDropdown(
                label: 'iPhone Model',
                value: _selectedModel,
                items: _models,
                onChanged: (value) {
                  setState(() {
                    _selectedModel = value;
                  });
                  if (value != null) {
                    _loadStorageOptions(value);
                  }
                },
              ),
              _buildDropdown(
                label: 'Storage',
                value: _selectedStorage,
                items: _storageOptions,
                isLoading: _isLoadingStorage,
                onChanged: (value) {
                  setState(() {
                    _selectedStorage = value;
                  });
                  if (value != null && _selectedModel != null) {
                    _loadConditions(_selectedModel!, value);
                  }
                },
              ),
              _buildDropdown(
                label: 'Condition',
                value: _selectedCondition,
                items: _conditions,
                isLoading: _isLoadingConditions,
                onChanged: (value) {
                  setState(() {
                    _selectedCondition = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _selectedModel != null &&
                        _selectedStorage != null &&
                        _selectedCondition != null
                    ? _fetchPriceData
                    : null,
                child: const Text('Get Price'),
              ),
              const SizedBox(height: 24),
              _buildPriceDisplay(),
            ],
          ),
        ),
      ),
    );
  }
} 