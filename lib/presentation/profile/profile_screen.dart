import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:task_tide/presentation/onboarding/onboarding_screen.dart';
import 'package:task_tide/providers/app_state_provider.dart';
import '../../core/constants/colors.dart';
import 'package:task_tide/presentation/profile/notification_screen.dart';
import 'package:task_tide/presentation/profile/backup_restore_screen.dart';
import 'package:task_tide/presentation/profile/about_app_screen.dart';

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
                        color: Colors.black.withValues(alpha: 0.02),
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
                        final username = appStateProvider.username;
                        return Text(
                          '$username',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
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
                const SizedBox(height: 25),

                // 3. SEKSI INFORMASI AKUN
                Text(
                  "Account Information",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),

                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
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
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
                        },
                      ),
                      _buildProfileTile(
                        icon: LucideIcons.databaseBackup,
                        title: 'Backup Data',
                        subtitle: 'Export and restore application data',
                        isLast: false,
                        // textColor: Colors.blue.shade700,
                        iconColor: AppColors.primaryBlue,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const BackupRestoreScreen()));
                        },
                      ),
                      _buildProfileTile(
                        icon: LucideIcons.info,
                        title: 'About App',
                        subtitle: 'Version information and app details',
                        isLast: false,
                        // textColor: Colors.purple.shade700,
                        iconColor: AppColors.primaryBlue,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutAppScreen()));
                        },
                      ),
                      _buildProfileTile(
                        icon: LucideIcons.logOut,
                        title: 'Logout',
                        subtitle: 'Sign out from the application',
                        isLast: true,
                        textColor: Colors.red.shade700,
                        iconColor: Colors.red.shade700,
                        onTap: () async {
                          // 1. Tampilkan Dialog Konfirmasi untuk kenyamanan pengguna (UX)
                          bool confirmReset = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(
                                    'Reset Profile?',
                                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                                  ),
                                  content: Text(
                                    'This action will permanently delete your data from local storage.',
                                    style: GoogleFonts.plusJakartaSans(),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary)),
                                    ),
                                    TextButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:  Colors.red.shade400,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      onPressed: () => Navigator.pop(context, true),
                                      child: Text('Logout', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ) ?? false;

                          // 2. Jika pengguna memilih "Ya, Keluar"
                          if (confirmReset && context.mounted) {
                            // Picu fungsi pembersihan SharedPreferences via AppStateProvider
                            await context.read<AppStateProvider>().resetProfile();

                            if (context.mounted) {
                              // 3. Paksa navigasi balik ke OnboardingScreen & hapus seluruh tumpukan halaman terdahulu
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                                (route) => false, // Stack memori dibersihkan total
                              );
                            }
                          }
                        },
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


  // Helper Widget untuk membangun baris menu item profil (ListTile Kustom)
  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isLast,
    Color? textColor,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap, // 👈 Pasangkan callback di sini
      splashColor: Colors.grey.shade100,
      highlightColor: Colors.transparent,
      child: Column(
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
                        ? iconColor.withValues(alpha: 0.08) 
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
                          color: AppColors.textSecondary.withValues(alpha: 0.7),
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
                    color: AppColors.textSecondary.withValues(alpha: 0.4),
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
      ),
    );
  }
}