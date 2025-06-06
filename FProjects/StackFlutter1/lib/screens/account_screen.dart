import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? 'Not signed in';

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
            _buildInfoCard(
              title: 'Subscription',
              children: [
                _buildInfoRow('Plan', 'Standard'),
                _buildInfoRow('Status', 'Active'),
                _buildInfoRow('Next Billing', 'Monthly'),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Preferences',
              children: [
                SwitchListTile(
                  title: const Text('Email Notifications'),
                  value: true,
                  onChanged: (value) {
                    // TODO: Implement notification toggle
                  },
                ),
                // Dark mode toggle
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
            Center(
              child: TextButton(
                onPressed: () {
                  // TODO: Implement account deletion
                },
                child: const Text(
                  'Delete Account',
                  style: TextStyle(color: Colors.red),
                ),
              ),
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