import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../widgets/animated_background.dart';
import '../widgets/custom_button.dart';
import 'home_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _selectedPlan = 1;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _plans = [
    {
      'name': 'Basic',
      'price': 'Rp 29.000',
      'period': '/bulan',
      'features': [
        'Pengukuran tubuh',
        'Rekomendasi size',
        '2 marketplace',
        'Riwayat pengukuran',
      ],
      'color': AppColors.textSecondary,
    },
    {
      'name': 'Premium',
      'price': 'Rp 49.000',
      'period': '/bulan',
      'popular': true,
      'features': [
        'Semua fitur Basic',
        'Visualisasi 3D',
        'Semua marketplace',
        'Rekomendasi AI',
        'Analisis tren',
        'Prioritas support',
      ],
      'color': AppColors.primary,
    },
    {
      'name': 'Pro',
      'price': 'Rp 99.000',
      'period': '/tahun',
      'features': [
        'Semua fitur Premium',
        'Hemat 83%',
        'Akses selamanya',
        'Fitur beta eksklusif',
        'Personal stylist AI',
        'Export data',
      ],
      'color': AppColors.accent,
    },
  ];

  Future<void> _subscribe() async {
    setState(() => _isLoading = true);

    final planName = _plans[_selectedPlan]['name'] as String;
    final result = await AuthService().subscribe(planName);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] as String),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 10),
                // Header
                if (user != null && !user.isTrialActive && !user.isSubscribed)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber,
                            color: AppColors.error, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Trial Anda Telah Berakhir',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Berlangganan untuk melanjutkan akses',
                                style: TextStyle(
                                  color:
                                      AppColors.textSecondary.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .shake(delay: 500.ms, duration: 300.ms),

                const SizedBox(height: 20),

                const Icon(
                  Icons.workspace_premium,
                  size: 48,
                  color: AppColors.accent,
                ).animate().scale(
                      begin: const Offset(0, 0),
                      end: const Offset(1, 1),
                      duration: 600.ms,
                      curve: Curves.elasticOut,
                    ),
                const SizedBox(height: 12),
                const Text(
                  'Pilih Paket Langganan',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                const SizedBox(height: 6),
                Text(
                  'Upgrade untuk akses penuh ke semua fitur',
                  style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 500.ms),

                const SizedBox(height: 24),

                // Plans
                ...List.generate(_plans.length, (index) {
                  final plan = _plans[index];
                  final isSelected = _selectedPlan == index;
                  final isPopular = plan['popular'] == true;
                  final planColor = plan['color'] as Color;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedPlan = index),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  planColor.withOpacity(0.2),
                                  planColor.withOpacity(0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : AppColors.cardGradient,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? planColor
                              : Colors.white.withOpacity(0.05),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: planColor.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Radio
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        isSelected ? planColor : AppColors.textSecondary,
                                    width: 2,
                                  ),
                                  color: isSelected
                                      ? planColor
                                      : Colors.transparent,
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check,
                                        size: 16, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                plan['name'] as String,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  shadows: isSelected
                                      ? [
                                          Shadow(
                                              color:
                                                  planColor.withOpacity(0.5),
                                              blurRadius: 10)
                                        ]
                                      : null,
                                ),
                              ),
                              if (isPopular) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'POPULER',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    plan['price'] as String,
                                    style: TextStyle(
                                      color: planColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    plan['period'] as String,
                                    style: TextStyle(
                                      color: AppColors.textSecondary
                                          .withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (isSelected) ...[
                            const SizedBox(height: 14),
                            const Divider(color: AppColors.surface),
                            const SizedBox(height: 8),
                            ...((plan['features'] as List<String>).map(
                              (feature) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 3),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: planColor, size: 18),
                                    const SizedBox(width: 10),
                                    Text(
                                      feature,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                          ],
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: 400 + index * 100),
                        duration: 500.ms,
                      )
                      .slideY(begin: 0.1, end: 0);
                }),

                const SizedBox(height: 20),

                GradientButton(
                  text: 'Berlangganan Sekarang',
                  onPressed: _subscribe,
                  isLoading: _isLoading,
                  icon: Icons.star,
                ).animate().fadeIn(delay: 800.ms, duration: 500.ms),

                const SizedBox(height: 12),

                // Skip for now (if still in trial)
                if (user != null && user.isTrialActive)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (_) => const HomeScreen()),
                        (route) => false,
                      );
                    },
                    child: Text(
                      'Lewati untuk sekarang (${user.trialDaysRemaining} hari tersisa)',
                      style: TextStyle(
                        color: AppColors.textSecondary.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ).animate().fadeIn(delay: 900.ms, duration: 500.ms),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
