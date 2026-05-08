import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/body_measurement.dart';
import '../utils/constants.dart';
import '../widgets/body_painter.dart';
import '../widgets/custom_button.dart';

class BodyVisualizationScreen extends StatefulWidget {
  final BodyMeasurement? measurement;

  const BodyVisualizationScreen({super.key, this.measurement});

  @override
  State<BodyVisualizationScreen> createState() =>
      _BodyVisualizationScreenState();
}

class _BodyVisualizationScreenState extends State<BodyVisualizationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.measurement == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.accessibility_new,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada data pengukuran',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Silakan ukur tubuh Anda terlebih dahulu',
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 500.ms);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Visualisasi Tubuh',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().fadeIn(duration: 500.ms),
          const SizedBox(height: 8),
          Text(
            'Sentuh bagian tubuh untuk melihat detail',
            style: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.7),
              fontSize: 13,
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
          const SizedBox(height: 20),

          // Body visualization
          Center(
            child: BodyVisualizationWidget(
              measurement: widget.measurement,
            ),
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 600.ms)
              .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),

          const SizedBox(height: 24),

          // Tab bar for details
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'Ukuran'),
                Tab(text: 'Size'),
                Tab(text: 'Info'),
              ],
            ),
          ).animate().fadeIn(delay: 500.ms, duration: 500.ms),

          const SizedBox(height: 16),

          SizedBox(
            height: 280,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMeasurementsTab(),
                _buildSizeTab(),
                _buildInfoTab(),
              ],
            ),
          ).animate().fadeIn(delay: 600.ms, duration: 500.ms),
        ],
      ),
    );
  }

  Widget _buildMeasurementsTab() {
    final m = widget.measurement!;
    return GlassCard(
      child: Column(
        children: [
          _buildMeasurementRow('Tinggi Badan', '${m.height} cm', Icons.height),
          _buildMeasurementRow(
              'Berat Badan', '${m.weight} kg', Icons.monitor_weight),
          _buildMeasurementRow(
              'Lingkar Dada', '${m.chest} cm', Icons.circle_outlined),
          _buildMeasurementRow(
              'Lingkar Pinggang', '${m.waist} cm', Icons.circle),
          _buildMeasurementRow(
              'Lingkar Pinggul', '${m.hips} cm', Icons.circle_outlined),
          _buildMeasurementRow('Lebar Bahu', '${m.shoulder} cm', Icons.open_with),
          _buildMeasurementRow(
              'Lingkar Leher', '${m.neck} cm', Icons.circle_outlined),
        ],
      ),
    );
  }

  Widget _buildSizeTab() {
    final m = widget.measurement!;
    return GlassCard(
      child: Column(
        children: [
          _buildSizeRow('Atasan', m.getTopSize(), AppColors.primary),
          const Divider(color: AppColors.surface),
          _buildSizeRow('Bawahan', m.getBottomSize(), AppColors.secondary),
          const Divider(color: AppColors.surface),
          _buildSizeRow('Sepatu', m.getShoeSize(), AppColors.accent),
          const Divider(color: AppColors.surface),
          _buildSizeRow(
              'Tipe Tubuh', m.calculateBodyType(), Colors.tealAccent),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    final m = widget.measurement!;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BMI
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getBmiColor(m.bmi).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.monitor_weight,
                  color: _getBmiColor(m.bmi),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BMI: ${m.bmi.toStringAsFixed(1)}',
                    style: TextStyle(
                      color: _getBmiColor(m.bmi),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    m.bmiCategory,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // BMI bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (m.bmi / 40).clamp(0, 1),
              minHeight: 8,
              backgroundColor: AppColors.surface,
              valueColor:
                  AlwaysStoppedAnimation<Color>(_getBmiColor(m.bmi)),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Kurus',
                  style: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.5),
                      fontSize: 10)),
              Text('Normal',
                  style: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.5),
                      fontSize: 10)),
              Text('Gemuk',
                  style: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.5),
                      fontSize: 10)),
              Text('Obesitas',
                  style: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.5),
                      fontSize: 10)),
            ],
          ),
          const SizedBox(height: 16),
          // Body type info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accent.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    color: AppColors.accent, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tipe tubuh Anda: ${m.calculateBodyType()}. Rasio pinggang-pinggul: ${(m.waist / m.hips).toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Text(label,
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSizeRow(String label, String size, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 15)),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Text(
              size,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBmiColor(double bmi) {
    if (bmi < 18.5) return Colors.lightBlueAccent;
    if (bmi < 25) return AppColors.success;
    if (bmi < 30) return AppColors.warning;
    return AppColors.error;
  }
}
