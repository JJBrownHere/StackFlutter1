import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/wallet_service.dart';

// Conditional import for web
import 'dart:html' if (dart.library.html) 'dart:html' as html;

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final WalletService _walletService = WalletService();
  double? _balance;
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    if (!kIsWeb) return;
    
    setState(() => _isLoading = true);
    try {
      final balance = await _walletService.getWalletBalance();
      final transactions = await _walletService.getTransactionHistory();
      setState(() {
        _balance = balance;
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading wallet data')),
        );
      }
    }
  }

  Future<void> _addFunds() async {
    if (!kIsWeb) return;
    
    final amount = await showDialog<double>(
      context: context,
      builder: (context) => const AddFundsDialog(),
    );
    
    if (amount == null || amount <= 0) return;
    
    final checkoutUrl = await _walletService.createCheckoutSession(amount);
    if (checkoutUrl != null && mounted && kIsWeb) {
      // Open Stripe checkout in new window
      html.window.open(checkoutUrl, 'stripe_checkout');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return const Scaffold(
        body: Center(
          child: Text('Wallet features are only available on web'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWalletData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadWalletData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Balance',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${_balance?.toStringAsFixed(2) ?? '0.00'}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _addFunds,
                              child: const Text('Add Funds'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Transaction History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._transactions.map((tx) => TransactionCard(transaction: tx)),
                ],
              ),
            ),
    );
  }
}

class AddFundsDialog extends StatefulWidget {
  const AddFundsDialog({super.key});

  @override
  State<AddFundsDialog> createState() => _AddFundsDialogState();
}

class _AddFundsDialogState extends State<AddFundsDialog> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Funds'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount (\$)',
            prefixText: '\$',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter an amount';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter a valid amount';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.pop(
                context,
                double.tryParse(_amountController.text),
              );
            }
          },
          child: const Text('Continue'),
        ),
      ],
    );
  }
}

class TransactionCard extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionCard({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final amount = (transaction['amount'] as num).toDouble();
    final type = transaction['type'] as String;
    final date = DateTime.parse(transaction['created_at'] as String);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          type == 'credit' ? Icons.add_circle : Icons.remove_circle,
          color: type == 'credit' ? Colors.green : Colors.red,
        ),
        title: Text(
          type == 'credit' ? 'Added Funds' : 'Used Credits',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
        ),
        trailing: Text(
          '\$${amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            color: type == 'credit' ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
} 