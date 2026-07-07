import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:task_tide/providers/app_state_provider.dart';
import '../../core/constants/colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. JUDUL HALAMAN UTAMA
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Profile',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 2. KARTU IDENTITAS UTAMA (AVATAR & NAMA)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Avatar Lingkaran dengan Inisial Nama
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.iconBackground,
                        child: Icon(Icons.person, color: Color.fromARGB(255, 87, 94, 107), size: 45),
                      ),

                      const SizedBox(height: 16),
                      
                      // Nama Lengkap Pengguna
                      Consumer<AppStateProvider>(
                      builder: (context, appStateProvider, child) {
                        final username = appStateProvider.username ?? 'Zahra';
                        return Text(
                          '$username',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                          textAlign: TextAlign.center,
                        );
                      },
                    ),
                      const SizedBox(height: 6),
                      
                      // Institusi/Universitas Asal
                      Text(
                        'Student Productivity Tracker',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 3. SEKSI INFORMASI AKUN
                _buildSectionTitle('Account Information'),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildProfileTile(
                        icon: LucideIcons.bell,
                        title: 'Notifications',
                        subtitle: 'Manage reminders and alerts',
                        isLast: false,
                        // textColor: Colors.green.shade700,
                        iconColor: AppColors.primaryBlue,
                      ),
                      _buildProfileTile(
                        icon: LucideIcons.databaseBackup,
                        title: 'Backup Data',
                        subtitle: 'Export and restore application data',
                        isLast: false,
                        // textColor: Colors.blue.shade700,
                        iconColor: AppColors.primaryBlue,
                      ),
                      _buildProfileTile(
                        icon: LucideIcons.info,
                        title: 'About App',
                        subtitle: 'Version information and app details',
                        isLast: false,
                        // textColor: Colors.purple.shade700,
                        iconColor: AppColors.primaryBlue,
                      ),
                      _buildProfileTile(
                        icon: LucideIcons.logOut,
                        title: 'Logout',
                        subtitle: 'Sign out from the application',
                        isLast: true,
                        textColor: Colors.red.shade700,
                        iconColor: Colors.red.shade700,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widget untuk membangun Judul Seksi
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
    );
  }

  // Helper Widget untuk membangun baris menu item profil (ListTile Kustom)
  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isLast,
    Color? textColor,
    Color? iconColor,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              // Kotak Wadah Ikon Kiri
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor != null 
                      ? iconColor.withOpacity(0.08) 
                      : AppColors.progressBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? AppColors.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              
              // Blok Teks Informasi Menu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: textColor ?? AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Ikon Panah Navigasi Kanan (hanya tampil jika bukan menu aksi destruktif/logout)
              if (textColor == null)
                Icon(
                  LucideIcons.chevronRight,
                  size: 18,
                  color: AppColors.textSecondary.withOpacity(0.4),
                ),
            ],
          ),
        ),
        // Garis pemisah tipis antar baris menu internal
        if (!isLast)
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey.shade100,
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }
}