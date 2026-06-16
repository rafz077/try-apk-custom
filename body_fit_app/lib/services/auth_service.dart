import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final DatabaseService _db = DatabaseService();
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      final existingUser = await _db.getUserByEmail(email);
      if (existingUser != null) {
        return {'success': false, 'message': 'Email sudah terdaftar'};
      }

      final now = DateTime.now();
      final user = UserModel(
        name: name,
        email: email,
        password: _hashPassword(password),
        createdAt: now,
        trialEndsAt: now.add(const Duration(days: 7)),
      );

      final id = await _db.insertUser(user);
      _currentUser = user.copyWith(id: id);

      await _saveSession(id);

      return {
        'success': true,
        'message': 'Registrasi berhasil! Anda mendapat trial 7 hari gratis.',
        'user': _currentUser,
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final user = await _db.getUserByEmail(email);
      if (user == null) {
        return {'success': false, 'message': 'Email tidak ditemukan'};
      }

      if (user.password != _hashPassword(password)) {
        return {'success': false, 'message': 'Password salah'};
      }

      _currentUser = user;
      await _saveSession(user.id!);

      if (!user.hasAccess) {
        return {
          'success': true,
          'message': 'Trial Anda telah berakhir. Silakan berlangganan.',
          'user': user,
          'needSubscription': true,
        };
      }

      return {
        'success': true,
        'message': 'Login berhasil!',
        'user': user,
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
  }

  Future<void> _saveSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
  }

  Future<bool> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId == null) return false;

    final user = await _db.getUserById(userId);
    if (user == null) return false;

    _currentUser = user;
    return true;
  }

  Future<Map<String, dynamic>> subscribe(String subscriptionType) async {
    if (_currentUser == null) {
      return {'success': false, 'message': 'Belum login'};
    }

    final updatedUser = _currentUser!.copyWith(
      isSubscribed: true,
      subscriptionType: subscriptionType,
    );

    await _db.updateUser(updatedUser);
    _currentUser = updatedUser;

    return {
      'success': true,
      'message': 'Berlangganan berhasil! Nikmati akses penuh.',
    };
  }

  Future<void> checkAndUpdateTrialStatus() async {
    if (_currentUser == null) return;
    if (!_currentUser!.isSubscribed && !_currentUser!.isTrialActive) {
      // Trial expired - user needs to subscribe
    }
  }
}
