import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'price_checks_screen.dart';
import 'imei_checks_screen.dart';
import '../helpers/session_helper.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _handleLogout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    // Navigate to login screen after logout
    Navigator.of(context).pushReplacementNamed('/login');
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchWhatsApp() async {
    final whatsappUrl = Uri.parse('https://wa.me/15413504896');
    if (!await launchUrl(whatsappUrl)) {
      throw Exception('Could not launch WhatsApp');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 35, color: Colors.blue),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user?.email ?? 'User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About BuyBack.Tools'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/about');
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Account'),
              subtitle: Text(user?.email ?? ''),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/account');
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('Credits'),
              subtitle: const Text('Coming soon'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/credits');
              },
            ),
            ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text('Support'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Support Options'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.language),
                          title: const Text('Visit Website'),
                          onTap: () {
                            Navigator.pop(context);
                            _launchUrl('https://buyback.tools');
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.message),
                          title: const Text('WhatsApp Support'),
                          onTap: () {
                            Navigator.pop(context);
                            _launchWhatsApp();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.pop(context);
                await _handleLogout(context);
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Welcome to STACKS',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = 2;
                  double maxWidth = constraints.maxWidth;
                  if (maxWidth > 1200) {
                    crossAxisCount = 4;
                  } else if (maxWidth > 800) {
                    crossAxisCount = 3;
                  }
                  return GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: maxWidth / crossAxisCount,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1,
                    ),
                    children: [
                      _buildDashboardCard(
                        context,
                        'IMEI Checks',
                        Icons.phone_android,
                        Colors.blue,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ImeiChecksScreen(),
                            ),
                          );
                        },
                      ),
                      _buildDashboardCard(
                        context,
                        'Price STACKS',
                        Icons.attach_money,
                        Colors.green,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PriceChecksScreen(),
                            ),
                          );
                        },
                      ),
                      _buildDashboardCard(
                        context,
                        'Inventory',
                        Icons.inventory,
                        Colors.orange,
                        () {
                          // TODO: Navigate to Inventory screen
                        },
                      ),
                      _buildDashboardCard(
                        context,
                        'Purchase',
                        Icons.shopping_cart,
                        Colors.purple,
                        () {
                          // TODO: Navigate to Purchase screen
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.8),
                color,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 