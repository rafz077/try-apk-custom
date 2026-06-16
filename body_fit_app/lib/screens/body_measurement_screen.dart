import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/body_measurement.dart';
import '../utils/constants.dart';
import '../widgets/animated_background.dart';
import '../widgets/custom_button.dart';

class BodyMeasurementScreen extends StatefulWidget {
  const BodyMeasurementScreen({super.key});

  @override
  State<BodyMeasurementScreen> createState() => _BodyMeasurementScreenState();
}

class _BodyMeasurementScreenState extends State<BodyMeasurementScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  bool _isLoading = false;
  int _currentStep = 0;

  final List<List<String>> _steps = [
    ['height', 'weight'],
    ['chest', 'waist', 'hips'],
    ['shoulder', 'neck'],
    ['armLength', 'legLength', 'footLength'],
  ];

  final List<String> _stepTitles = [
    'Tinggi & Berat',
    'Lingkar Tubuh',
    'Bahu & Leher',
    'Panjang Anggota Badan',
  ];

  final List<IconData> _stepIcons = [
    Icons.height,
    Icons.circle_outlined,
    Icons.accessibility_new,
    Icons.straighten,
  ];

  @override
  void initState() {
    super.initState();
    for (final key in BodyPartLabels.labels.keys) {
      _controllers[key] = TextEditingController();
    }
    _loadExistingMeasurement();
  }

  Future<void> _loadExistingMeasurement() async {
    final user = AuthService().currentUser;
    if (user?.id != null) {
      final measurement =
          await DatabaseService().getLatestMeasurement(user!.id!);
      if (measurement != null && mounted) {
        setState(() {
          _controllers['height']!.text = measurement.height.toString();
          _controllers['weight']!.text = measurement.weight.toString();
          _controllers['chest']!.text = measurement.chest.toString();
          _controllers['waist']!.text = measurement.waist.toString();
          _controllers['hips']!.text = measurement.hips.toString();
          _controllers['shoulder']!.text = measurement.shoulder.toString();
          _controllers['armLength']!.text = measurement.armLength.toString();
          _controllers['legLength']!.text = measurement.legLength.toString();
          _controllers['neck']!.text = measurement.neck.toString();
          _controllers['footLength']!.text = measurement.footLength.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveMeasurement() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = AuthService().currentUser;
      if (user?.id == null) {
        throw Exception('User not logged in');
      }

      final measurement = BodyMeasurement(
        userId: user!.id!,
        height: double.parse(_controllers['height']!.text),
        weight: double.parse(_controllers['weight']!.text),
        chest: double.parse(_controllers['chest']!.text),
        waist: double.parse(_controllers['waist']!.text),
        hips: double.parse(_controllers['hips']!.text),
        shoulder: double.parse(_controllers['shoulder']!.text),
        armLength: double.parse(_controllers['armLength']!.text),
        legLength: double.parse(_controllers['legLength']!.text),
        neck: double.parse(_controllers['neck']!.text),
        footLength: double.parse(_controllers['footLength']!.text),
      );

      await DatabaseService().insertMeasurement(measurement);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Pengukuran berhasil disimpan!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios,
                          color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'Ukur Tubuh',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),

              // Step indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: List.generate(_steps.length, (index) {
                    final isActive = index == _currentStep;
                    final isDone = index < _currentStep;
                    return Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isDone
                                  ? AppColors.success
                                  : isActive
                                      ? AppColors.primary
                                      : AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: isDone
                                  ? const Icon(Icons.check,
                                      color: Colors.white, size: 18)
                                  : Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        color: isActive
                                            ? Colors.white
                                            : AppColors.textSecondary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                            ),
                          ),
                          if (index < _steps.length - 1)
                            Expanded(
                              child: Container(
                                height: 2,
                                color: isDone
                                    ? AppColors.success
                                    : AppColors.surface,
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

              const SizedBox(height: 16),

              // Step title
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _stepIcons[_currentStep],
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _stepTitles[_currentStep],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

              const SizedBox(height: 16),

              // Form
              Expanded(
                child: Form(
                  key: _formKey,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.1, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: SingleChildScrollView(
                      key: ValueKey(_currentStep),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          ..._steps[_currentStep].map((field) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: GlassCard(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      BodyPartLabels.labels[field] ?? field,
                                      style: const TextStyle(
                                        color: AppColors.accent,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _controllers[field],
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      style:
                                          const TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        hintText: 'Masukkan ${BodyPartLabels.labels[field]?.toLowerCase() ?? field}',
                                        hintStyle: TextStyle(
                                          color: AppColors.textSecondary
                                              .withOpacity(0.5),
                                        ),
                                        prefixIcon: Icon(
                                          _getFieldIcon(field),
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Harus diisi';
                                        }
                                        if (double.tryParse(value) == null) {
                                          return 'Masukkan angka yang valid';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Navigation buttons
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() => _currentStep--);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Kembali'),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: _currentStep < _steps.length - 1
                          ? GradientButton(
                              text: 'Selanjutnya',
                              onPressed: () {
                                // Validate current step fields
                                bool valid = true;
                                for (final field in _steps[_currentStep]) {
                                  final value = _controllers[field]?.text;
                                  if (value == null ||
                                      value.isEmpty ||
                                      double.tryParse(value) == null) {
                                    valid = false;
                                    break;
                                  }
                                }
                                if (valid) {
                                  setState(() => _currentStep++);
                                } else {
                                  _formKey.currentState!.validate();
                                }
                              },
                              icon: Icons.arrow_forward,
                            )
                          : GradientButton(
                              text: 'Simpan',
                              onPressed: _saveMeasurement,
                              isLoading: _isLoading,
                              icon: Icons.save,
                            ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getFieldIcon(String field) {
    switch (field) {
      case 'height':
        return Icons.height;
      case 'weight':
        return Icons.monitor_weight;
      case 'chest':
        return Icons.circle_outlined;
      case 'waist':
        return Icons.circle;
      case 'hips':
        return Icons.circle_outlined;
      case 'shoulder':
        return Icons.open_with;
      case 'armLength':
        return Icons.straighten;
      case 'legLength':
        return Icons.straighten;
      case 'neck':
        return Icons.circle_outlined;
      case 'footLength':
        return Icons.ice_skating;
      default:
        return Icons.straighten;
    }
  }
}
