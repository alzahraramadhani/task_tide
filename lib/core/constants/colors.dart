import 'package:flutter/material.dart';

class AppColors {
  // Warna Utama Aplikasi (Sesuai Mockup Dashboard)
  static const Color primaryBlue = Color(0xFF3F51B5);     // Royal Blue / Indigo Utama
  static const Color background = Color.fromARGB(255, 245, 242, 242);      // Off-White Latar Belakang
  static const Color textDark = Color(0xFF151C27);        // Hitam Pekat untuk Judul/Teks Utama
  static const Color textSecondary = Color(0xFF404754);   // Abu-abu untuk Label/Sub-teks
  static const Color progressBackground = Color(0xFFD9D9FF);
  static const Color iconBackground = Color(0xFFE8EAF6);
  static const Color backgroundFab = Color.fromARGB(255, 255, 255, 255); // Latar Belakang FAB

  // 🎨 Daftar 6 Warna Pastel Bawaan untuk Kategori Baru (Color Tag Picker)
  // Sesuai mandat dokumen kesepakatan Struktur Folder Project
  static const List<Color> pastelPalette = [
    Color(0xFFFFEDD5), // Oranye Pastel 
    Color(0xFFEEE3FA), // Ungu Pastel 
    Color(0xFFD7F9DC), // Hijau Pastel 
    Color(0xFFE1F5FE), // Biru Muda Pastel 
    Color(0xFFFCE4EC), // Pink Pastel 
    Color(0xFFFFFDE7), // Kuning Pastel 
  ];

  // Warna Aksen Pencocokan Sesuai Palet di Atas
  static const Color accentOrange = Color(0xFFE65100);
  static const Color accentPurple = Color(0xFF4A148C);
}