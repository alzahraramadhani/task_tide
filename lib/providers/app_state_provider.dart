import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStateProvider with ChangeNotifier {
  bool _isFirstTimeUser = true;
  String _username = '';

  bool get isFirstTimeUser => _isFirstTimeUser;
  String get username => _username;

  // 1. Cek status pengguna saat aplikasi pertama kali dibuka
  Future<void> checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // Jika key 'isFirstTime' tidak ada, maka default-nya adalah true
    _isFirstTimeUser = prefs.getBool('isFirstTime') ?? true;
    _username = prefs.getString('username') ?? '';
    notifyListeners();
  }

  // 2. Simpan data profil pengguna baru setelah menyelesaikan onboarding
  Future<void> completeOnboarding(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
    await prefs.setString('username', name);
    _isFirstTimeUser = false;
    _username = name;
    notifyListeners();
  }

  // 3. Opsi untuk reset data (jika pengguna ingin membersihkan profil)
  Future<void> resetProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _isFirstTimeUser = true;
    _username = '';
    notifyListeners();
  }
}