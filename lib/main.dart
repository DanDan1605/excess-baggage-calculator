import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class AppColors {
  static const Color primary = Color(0xFF0D47A1); // Deep Airline Navy Blue
  static const Color onPrimary = Colors.white;
  static const Color secondary = Color(0xFFFF8F00); // Warm Aviation Amber
}

void main() => runApp(const ExcessBaggageApp());

class ExcessBaggageApp extends StatelessWidget {
  const ExcessBaggageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Baggage Fee Estimator',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          secondary: AppColors.secondary,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const MainNavigationScreen(),
    );
  }
}

// ==========================================
// NAVIGATION SHELL (DRAWER MENU)
// ==========================================
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    AboutPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _selectedIndex == 0 ? Icons.flight_takeoff : Icons.info_outline,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              _selectedIndex == 0 ? 'Baggage Fee Estimator' : 'About App',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.luggage, size: 30, color: Colors.white),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Excess Baggage Estimator',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Air Travel Fee Calculator',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_rounded),
              title: const Text('Home', style: TextStyle(fontWeight: FontWeight.w500)),
              selected: _selectedIndex == 0,
              selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.4),
              onTap: () {
                setState(() => _selectedIndex = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_rounded),
              title: const Text('About', style: TextStyle(fontWeight: FontWeight.w500)),
              selected: _selectedIndex == 1,
              selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.4),
              onTap: () {
                setState(() => _selectedIndex = 1);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}

// ==========================================
// HOME PAGE (BAGGAGE CALCULATOR)
// ==========================================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();

  String _ticketClass = 'Economy';

  double? _excessWeight;
  double? _excessCharge;
  double? _totalPayable;

  @override
  void dispose() {
    _weightController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _calculateFee() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard on calculate

    final double? weight = double.tryParse(_weightController.text.trim());
    final double? rate = double.tryParse(_rateController.text.trim());

    if (weight == null || weight < 0) {
      _showError('Please enter a valid baggage weight (0 or more kg).');
      return;
    }

    if (rate == null || rate < 0) {
      _showError('Please enter a valid excess rate per kg (RM 0 or more).');
      return;
    }

    final double allowance = (_ticketClass == 'Economy') ? 20.0 : 40.0;
    final double excessKg = (weight > allowance) ? (weight - allowance) : 0.0;
    final double charge = excessKg * rate;
    final double total = charge + (0.08 * charge);

    setState(() {
      _excessWeight = excessKg;
      _excessCharge = charge;
      _totalPayable = total;
    });
  }

  void _resetForm() {
    FocusScope.of(context).unfocus();
    setState(() {
      _weightController.clear();
      _rateController.clear();
      _ticketClass = 'Economy';
      _excessWeight = null;
      _excessCharge = null;
      _totalPayable = null;
    });
  }

  void _showError(String message) {
    setState(() {
      _excessWeight = null;
      _excessCharge = null;
      _totalPayable = null;
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Instructions & Allowance Notice Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, color: colorScheme.primary, size: 22),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Enter baggage weight and excess rate, then select your ticket class.\n'
                    '• Free Allowance: 20 kg (Economy) | 40 kg (Business)\n'
                    '• Service Tax: 8% applied to excess charges',
                    style: TextStyle(fontSize: 12.5, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Input Form Card
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Baggage Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Input 1: Weight
                  TextField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Checked Baggage Weight (kg)',
                      hintText: 'e.g., 25 or 42.5',
                      prefixIcon: Icon(Icons.scale_outlined),
                      suffixText: 'kg',
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Input 2: Ticket Class Selection Cards (Non-TextField Widget)
                  const Text(
                    'Select Ticket Class',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  RadioGroup<String>(
                    groupValue: _ticketClass,
                    onChanged: (value) {
                      if (value != null) setState(() => _ticketClass = value);
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildClassOptionCard(
                            title: 'Economy',
                            subtitle: 'Free: 20 kg',
                            value: 'Economy',
                            icon: Icons.airline_seat_recline_normal,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildClassOptionCard(
                            title: 'Business',
                            subtitle: 'Free: 40 kg',
                            value: 'Business',
                            icon: Icons.airline_seat_flat,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Input 3: Rate per kg
                  TextField(
                    controller: _rateController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Excess Baggage Rate (per kg)',
                      hintText: 'e.g., 15',
                      prefixIcon: Icon(Icons.payments_outlined),
                      prefixText: 'RM ',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _calculateFee,
                          icon: const Icon(Icons.calculate_outlined),
                          label: const Text(
                            'Calculate Fee',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _resetForm,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reset'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Receipt-Style Output Summary Card
          if (_totalPayable != null)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.3)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.receipt_long, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        const Text(
                          'Fee Estimation Summary',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildResultRow(
                      'Ticket Class Allowance',
                      _ticketClass == 'Economy' ? '20.00 kg' : '40.00 kg',
                    ),
                    const SizedBox(height: 10),
                    _buildResultRow(
                      'Excess Baggage Weight',
                      '${_excessWeight!.toStringAsFixed(2)} kg',
                    ),
                    const SizedBox(height: 10),
                    _buildResultRow(
                      'Excess Baggage Charge',
                      'RM ${_excessCharge!.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 10),
                    _buildResultRow(
                      'Service Tax (8%)',
                      'RM ${(_excessCharge! * 0.08).toStringAsFixed(2)}',
                    ),
                    const Divider(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Payable',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                          Text(
                            'RM ${_totalPayable!.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildClassOptionCard({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
  }) {
    final isSelected = _ticketClass == value;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => setState(() => _ticketClass = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer.withValues(alpha: 0.7)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              visualDensity: VisualDensity.compact,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isSelected ? colorScheme.primary : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

// ==========================================
// ABOUT PAGE
// ==========================================
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  // Replace with your actual GitHub repository URL
  final String _githubUrl = 'https://github.com/yourusername/excess-baggage-app';

  Future<void> _launchGitHub() async {
    final Uri uri = Uri.parse(_githubUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $_githubUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // App Icon Emblem
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.75)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.luggage,
              size: 64,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Excess Baggage Fee Estimator',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Version 1.0.0',
            style: TextStyle(color: colorScheme.outline, fontSize: 13),
          ),
          const SizedBox(height: 24),

          // Author Information Card
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(child: Icon(Icons.person)),
                    title: Text('Author Name', style: TextStyle(fontSize: 12)),
                    subtitle: Text(
                      'Adam Danial Bin Mohammad Hadi',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: CircleAvatar(child: Icon(Icons.badge)),
                    title: Text('Matric Number', style: TextStyle(fontSize: 12)),
                    subtitle: Text(
                      '2025227982',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: CircleAvatar(child: Icon(Icons.school)),
                    title: Text('Course', style: TextStyle(fontSize: 12)),
                    subtitle: Text(
                      'ICT602 - Mobile Technology Assignment 1',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Clickable GitHub Repository Button
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _launchGitHub,
              icon: const Icon(Icons.code),
              label: const Text(
                'View Source Code on GitHub here',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Copyright Notice
          Text(
            '© 2026 Adam Danial Bin Mohammad Hadi. All Rights Reserved.',
            style: TextStyle(color: colorScheme.outline, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}