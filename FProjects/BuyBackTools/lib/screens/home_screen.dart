import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'price_checks_screen.dart';
import 'imei_checks_screen.dart';
import '../helpers/session_helper.dart';
import 'inventory_summary_screen.dart';
import 'purchase_device_screen.dart';
import '../widgets/glass_container.dart';
import '../app_state.dart';
import '../services/analytics_service.dart';
import 'analytics_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    globalRefreshSession(context);
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
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

  Future<bool> _isAnalyticsConnected() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return false;
    final profile = await Supabase.instance.client
        .from('profiles')
        .select('ga4_id')
        .eq('id', user.id)
        .maybeSingle();
    return profile != null && profile['ga4_id'] != null && profile['ga4_id'].toString().isNotEmpty;
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
                        'IMEI STACKS',
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
                        'Inventory STACKS',
                        Icons.inventory,
                        Colors.orange,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const InventorySummaryScreen(),
                            ),
                          );
                        },
                      ),
                      _buildDashboardCard(
                        context,
                        'Buy A Device 💵',
                        Icons.shopping_cart,
                        Colors.purple,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PurchaseDeviceScreen(),
                            ),
                          );
                        },
                      ),
                      _buildDashboardCard(
                        context,
                        'Web Analytics',
                        Icons.analytics,
                        Colors.teal,
                        () async {
                          final connected = await _isAnalyticsConnected();
                          if (connected) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AnalyticsScreen(
                                  analyticsService: AnalyticsService(
                                    SharedPreferences.getInstance() as SharedPreferences,
                                    Supabase.instance.client,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            Navigator.pushNamed(context, '/account');
                          }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF2D3436);
    return GlassContainer(
      borderRadius: 16,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 140,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
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