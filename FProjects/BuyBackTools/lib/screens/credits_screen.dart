import 'package:flutter/material.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credits'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCreditCard(),
            const SizedBox(height: 24),
            _buildUsageSection(),
            const SizedBox(height: 24),
            _buildPurchaseSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue, Colors.blueAccent],
          ),
        ),
        child: Column(
          children: [
            const Text(
              'Available Credits',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '1,000',
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Credits',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Usage',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildUsageCard(
          'IMEI Check',
          '10 credits',
          '2 hours ago',
        ),
        _buildUsageCard(
          'Price Check',
          '5 credits',
          '5 hours ago',
        ),
        _buildUsageCard(
          'Inventory Update',
          '20 credits',
          '1 day ago',
        ),
      ],
    );
  }

  Widget _buildUsageCard(String title, String credits, String time) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.history, color: Colors.white),
        ),
        title: Text(title),
        subtitle: Text(time),
        trailing: Text(
          credits,
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPurchaseSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Purchase Credits',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildPurchaseOption(
          'Basic Pack',
          '1,000 credits',
          '\$99',
          () {
            // TODO: Implement purchase
          },
        ),
        _buildPurchaseOption(
          'Standard Pack',
          '5,000 credits',
          '\$449',
          () {
            // TODO: Implement purchase
          },
        ),
        _buildPurchaseOption(
          'Premium Pack',
          '10,000 credits',
          '\$799',
          () {
            // TODO: Implement purchase
          },
        ),
      ],
    );
  }

  Widget _buildPurchaseOption(
    String title,
    String credits,
    String price,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Text(credits),
        trailing: ElevatedButton(
          onPressed: onTap,
          child: Text(price),
        ),
      ),
    );
  }
} 