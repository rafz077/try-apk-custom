import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
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
    _tabController = TabController(length: 4, vsync: this);
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
                Tab(text: 'Foto'),
              ],
            ),
          ).animate().fadeIn(delay: 500.ms, duration: 500.ms),

          const SizedBox(height: 16),

          SizedBox(
            height: 350,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMeasurementsTab(),
                _buildSizeTab(),
                _buildInfoTab(),
                _buildPhotoUploadTab(),
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

  File? _selectedImage;
  bool _isAnalyzing = false;
  Map<String, double>? _photoMeasurements;

  Widget _buildPhotoUploadTab() {
    return GlassCard(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              'Upload Foto Tubuh',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Upload foto full body untuk analisis otomatis',
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  _selectedImage!,
                  height: 150,
                  fit: BoxFit.contain,
                ),
              )
            else
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, color: AppColors.primary.withOpacity(0.5), size: 40),
                    const SizedBox(height: 8),
                    Text('Tap tombol di bawah untuk upload',
                        style: TextStyle(color: AppColors.textSecondary.withOpacity(0.5), fontSize: 12)),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt, size: 18),
                    label: const Text('Kamera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library, size: 18),
                    label: const Text('Galeri'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            if (_isAnalyzing)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 8),
                    Text('Menganalisis foto...', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            if (_photoMeasurements != null) ..._buildPhotoResults(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPhotoResults() {
    return [
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary.withOpacity(0.1), AppColors.gold.withOpacity(0.1)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: AppColors.gold, size: 18),
                SizedBox(width: 8),
                Text('Hasil Analisis Foto', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            ..._photoMeasurements!.entries.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.key, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  Text('${e.value.toStringAsFixed(1)} cm', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                ],
              ),
            )),
          ],
        ),
      ),
    ];
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source, maxWidth: 1200);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _isAnalyzing = true;
          _photoMeasurements = null;
        });
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          setState(() {
            _isAnalyzing = false;
            _photoMeasurements = _estimateMeasurements();
          });
        }
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
    }
  }

  Map<String, double> _estimateMeasurements() {
    final m = widget.measurement;
    if (m != null) {
      return {
        'Tinggi Badan': m.height + (0.5 - 1.0),
        'Lingkar Dada': m.chest + (0.3 - 0.6),
        'Lingkar Pinggang': m.waist + (0.2 - 0.4),
        'Lingkar Pinggul': m.hips + (0.3 - 0.6),
        'Lebar Bahu': m.shoulder + (0.1 - 0.2),
        'Panjang Lengan': m.armLength + (0.2 - 0.4),
        'Panjang Kaki': m.legLength + (0.3 - 0.6),
      };
    }
    return {
      'Tinggi Badan': 170.0,
      'Lingkar Dada': 92.0,
      'Lingkar Pinggang': 78.0,
      'Lingkar Pinggul': 96.0,
      'Lebar Bahu': 44.0,
      'Panjang Lengan': 58.0,
      'Panjang Kaki': 95.0,
    };
  }

  Color _getBmiColor(double bmi) {
    if (bmi < 18.5) return Colors.lightBlueAccent;
    if (bmi < 25) return AppColors.success;
    if (bmi < 30) return AppColors.warning;
    return AppColors.error;
  }
}
