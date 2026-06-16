import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';
import '../widgets/animated_background.dart';
import '../widgets/custom_button.dart';

class PaymentScreen extends StatefulWidget {
  final String planName;
  final String planPrice;

  const PaymentScreen({
    super.key,
    required this.planName,
    required this.planPrice,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedMethod = -1;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'name': 'WhatsApp',
      'subtitle': 'Chat langsung untuk pembayaran',
      'icon': Icons.chat,
      'color': const Color(0xFF25D366),
      'type': 'chat',
      'action': 'https://wa.me/6289626856202?text=Halo%20Stylique%2C%20saya%20ingin%20berlangganan%20paket%20Premium',
    },
    {
      'name': 'Telegram',
      'subtitle': 'Hubungi via Telegram',
      'icon': Icons.send,
      'color': const Color(0xFF0088CC),
      'type': 'chat',
      'action': 'https://t.me/ravzxz',
    },
    {
      'name': 'Dana',
      'subtitle': '082261475937',
      'icon': Icons.account_balance_wallet,
      'color': const Color(0xFF108EE9),
      'type': 'ewallet',
      'number': '082261475937',
    },
    {
      'name': 'GoPay',
      'subtitle': '082261475937',
      'icon': Icons.payment,
      'color': const Color(0xFF00AED6),
      'type': 'ewallet',
      'number': '082261475937',
    },
    {
      'name': 'SeaBank',
      'subtitle': '901058578136',
      'icon': Icons.account_balance,
      'color': const Color(0xFFFF6600),
      'type': 'bank',
      'number': '901058578136',
    },
    {
      'name': 'E-Wallet Lainnya',
      'subtitle': 'OVO, LinkAja, ShopeePay',
      'icon': Icons.wallet,
      'color': const Color(0xFF8B5CF6),
      'type': 'chat',
      'action': 'https://wa.me/6289626856202?text=Halo%20Stylique%2C%20saya%20ingin%20bayar%20via%20E-Wallet',
    },
  ];

  Future<void> _processPayment() async {
    if (_selectedMethod < 0) return;

    final method = _paymentMethods[_selectedMethod];
    final type = method['type'] as String;

    if (type == 'chat') {
      final url = Uri.parse(method['action'] as String);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } else {
      final number = method['number'] as String;
      _showTransferDialog(method['name'] as String, number);
    }
  }

  void _showTransferDialog(String name, String number) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Transfer ke $name',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nomor Rekening',
                          style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7), fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          number,
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: number));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Nomor berhasil disalin'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Transfer sebesar ${widget.planPrice} lalu konfirmasi via WhatsApp',
                      style: TextStyle(color: AppColors.textSecondary.withOpacity(0.9), fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Tutup', style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7))),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              final url = Uri.parse(
                'https://wa.me/6289626856202?text=Halo%20Stylique%2C%20saya%20sudah%20transfer%20via%20$name%20untuk%20paket%20${widget.planName}',
              );
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            icon: const Icon(Icons.chat, size: 18),
            label: const Text('Konfirmasi via WA'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.08),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Pembayaran',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.15),
                              AppColors.gold.withOpacity(0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.workspace_premium, color: AppColors.gold, size: 28),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Stylique ${widget.planName}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Akses penuh semua fitur premium',
                                        style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7), fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundDark.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                                  Text(
                                    widget.planPrice,
                                    style: const TextStyle(color: AppColors.gold, fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 24),
                      const Text(
                        'Pilih Metode Pembayaran',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                      const SizedBox(height: 14),
                      ...List.generate(_paymentMethods.length, (index) {
                        final method = _paymentMethods[index];
                        final isSelected = _selectedMethod == index;
                        final color = method['color'] as Color;

                        return GestureDetector(
                          onTap: () => setState(() => _selectedMethod = index),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? LinearGradient(colors: [color.withOpacity(0.15), color.withOpacity(0.05)])
                                  : AppColors.cardGradient,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? color.withOpacity(0.6) : Colors.white.withOpacity(0.05),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(method['icon'] as IconData, color: color, size: 22),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        method['name'] as String,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                                      ),
                                      Text(
                                        method['subtitle'] as String,
                                        style: TextStyle(color: AppColors.textSecondary.withOpacity(0.6), fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: isSelected ? color : AppColors.textSecondary, width: 2),
                                    color: isSelected ? color : Colors.transparent,
                                  ),
                                  child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(
                              delay: Duration(milliseconds: 300 + index * 80),
                              duration: 400.ms,
                            ).slideX(begin: 0.05, end: 0);
                      }),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.success.withOpacity(0.15)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_user, color: AppColors.success, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Transaksi aman & terenkripsi. Konfirmasi otomatis setelah pembayaran.',
                                style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7), fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 800.ms, duration: 500.ms),
                      const SizedBox(height: 24),
                      GradientButton(
                        text: _selectedMethod >= 0
                            ? 'Bayar dengan ${_paymentMethods[_selectedMethod]['name']}'
                            : 'Pilih Metode Pembayaran',
                        onPressed: _selectedMethod >= 0 ? _processPayment : () {},
                        icon: Icons.payment,
                      ).animate().fadeIn(delay: 900.ms, duration: 500.ms),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
