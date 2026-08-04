import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/body_measurement.dart';
import '../utils/constants.dart';
import '../widgets/animated_background.dart';
import '../widgets/custom_button.dart';
import 'body_measurement_screen.dart';
import 'body_visualization_screen.dart';
import 'product_match_screen.dart';
import 'profile_screen.dart';
import 'subscription_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  BodyMeasurement? _latestMeasurement;
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadData();
    _checkAccess();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final user = AuthService().currentUser;
    if (user?.id != null) {
      final measurement =
          await DatabaseService().getLatestMeasurement(user!.id!);
      if (mounted) {
        setState(() => _latestMeasurement = measurement);
      }
    }
  }

  Future<void> _checkAccess() async {
    final user = AuthService().currentUser;
    if (user != null && !user.hasAccess) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: IndexedStack(
            index: _currentIndex,
            children: [
              _buildDashboard(user),
              BodyVisualizationScreen(measurement: _latestMeasurement),
              ProductMatchScreen(measurement: _latestMeasurement),
              const ProfileScreen(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundDark,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.space_dashboard_outlined),
              activeIcon: Icon(Icons.space_dashboard),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.accessibility_new_outlined),
              activeIcon: Icon(Icons.accessibility_new),
              label: 'Visualisasi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined),
              activeIcon: Icon(Icons.storefront),
              label: 'Katalog',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Akun',
            ),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const BodyMeasurementScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 1),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        )),
                        child: child,
                      );
                    },
                  ),
                );
                _loadData();
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
              .animate()
              .scale(
                begin: const Offset(0, 0),
                end: const Offset(1, 1),
                duration: 400.ms,
                curve: Curves.elasticOut,
              )
          : null,
    );
  }

  Widget _buildDashboard(dynamic user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.premiumGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    (user?.name ?? 'S')[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, ${user?.name ?? 'User'}!',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppStrings.appTagline,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Trial badge
              if (user != null && user.isTrialActive && !user.isSubscribed)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    'Trial: ${user.trialDaysRemaining} hari',
                    style: const TextStyle(
                      color: AppColors.warning,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .slideX(begin: -0.1, end: 0),
          const SizedBox(height: 24),

          // Quick stats
          if (_latestMeasurement != null) ...[
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'BMI',
                    _latestMeasurement!.bmi.toStringAsFixed(1),
                    _latestMeasurement!.bmiCategory,
                    Icons.monitor_weight,
                    AppColors.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Tipe Tubuh',
                    _latestMeasurement!.calculateBodyType(),
                    '',
                    Icons.accessibility_new,
                    AppColors.secondary,
                  ),
                ),
              ],
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 500.ms)
                .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Size Atas',
                    _latestMeasurement!.getTopSize(),
                    '',
                    Icons.checkroom,
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Size Bawah',
                    _latestMeasurement!.getBottomSize(),
                    '',
                    Icons.straighten,
                    Colors.tealAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Sepatu',
                    _latestMeasurement!.getShoeSize(),
                    '',
                    Icons.ice_skating,
                    Colors.orangeAccent,
                  ),
                ),
              ],
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 500.ms)
                .slideY(begin: 0.1, end: 0),
          ] else ...[
            // No measurement prompt
            GlassCard(
              child: Column(
                children: [
                  const Icon(
                    Icons.straighten,
                    size: 48,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Mulai Ukur Tubuh Anda',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Masukkan ukuran tubuh untuk mendapatkan rekomendasi produk yang cocok',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GradientButton(
                    text: 'Ukur Sekarang',
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BodyMeasurementScreen(),
                        ),
                      );
                      _loadData();
                    },
                    icon: Icons.straighten,
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 600.ms)
                .slideY(begin: 0.2, end: 0),
          ],

          const SizedBox(height: 24),

          // Quick actions
          Row(
            children: [
              const Text(
                'Fitur Utama',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              Text(
                'Stylique',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary.withOpacity(0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _buildMenuCard(
                'Ukur Tubuh',
                Icons.straighten,
                AppColors.primary,
                () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const BodyMeasurementScreen()),
                  );
                  _loadData();
                },
              ),
              _buildMenuCard(
                'Body Scan 3D',
                Icons.view_in_ar,
                AppColors.secondary,
                () => setState(() => _currentIndex = 1),
              ),
              _buildMenuCard(
                'Katalog Produk',
                Icons.storefront,
                AppColors.accent,
                () => setState(() => _currentIndex = 2),
              ),
              _buildMenuCard(
                'Berlangganan',
                Icons.workspace_premium,
                AppColors.gold,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                  );
                },
              ),
            ],
          )
              .animate()
              .fadeIn(delay: 500.ms, duration: 500.ms)
              .slideY(begin: 0.1, end: 0),

          const SizedBox(height: 24),

          // Marketplace partners
          const Text(
            'Marketplace Partner',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().fadeIn(delay: 600.ms, duration: 500.ms),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: AppStrings.marketplaces.length,
              itemBuilder: (context, index) {
                final mp = AppStrings.marketplaces[index];
                final color = AppStrings.marketplaceColors[mp]!;
                return Container(
                  width: 130,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        AppStrings.marketplaceIcons[mp],
                        color: color,
                        size: 28,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        mp,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ).animate().fadeIn(delay: 700.ms, duration: 500.ms),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, String subtitle, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: TextStyle(
                color: color.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
