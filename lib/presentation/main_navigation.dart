import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/constants/colors.dart'; // Patuh warna global
import 'dashboard/dashboard_screen.dart';
import 'tasks/tasks_screen.dart';
import 'activities/activities_screen.dart';
import 'profile/profile_screen.dart';
import 'tasks/form_task_screen.dart';
import 'activities/form_activity_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Menampilkan Bottom Sheet Pilihan Tambah Data saat FAB ditekan
  void _showAddOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Garis penanda handle di atas bottom sheet
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Create New',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'What would you like to add today?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    color: AppColors.textSecondary,
                  ),
                  
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    // Tombol Tambah Tugas Kuliah
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const FormTaskScreen()),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.15)),
                          ),
                          child: Column(
                            children: [
                              const Icon(LucideIcons.clipboardList, color: AppColors.primaryBlue, size: 28),
                              const SizedBox(height: 8),
                              Text(
                                'New Task',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Tombol Tambah Kegiatan Non-Tugas (Kuis/Ujian/Lomba)
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const FormActivityScreen()),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.orange.withValues(alpha: 0.15)),
                          ),
                          child: Column(
                            children: [
                              const Icon(LucideIcons.calendarDays, color: Colors.orange, size: 28),
                              const SizedBox(height: 8),
                              Text(
                                'New Activity',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    final List<Widget> screens = [
    DashboardScreen(
      onProfileTap: () {
        setState(() {
          _currentIndex = 3; // 👈 Pindahkan indeks ke halaman Profile (indeks 3)
        });
      },
    ),
    const TasksScreen(),
    const ActivitiesScreen(),
    const ProfileScreen(),
  ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      // FAB Utama di posisi tengah bawah
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptionsBottomSheet(context),
        backgroundColor: AppColors.primaryBlue,
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(LucideIcons.plus, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // Bottom Navigation Bar Terintegrasi
      
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          // Mengatur warna bayangan (shadow) agar lebih soft
          shadowColor: Colors.black.withValues(alpha: 0.10), 
        ),
        child: BottomAppBar(
          padding: EdgeInsets.zero,
          height: 65,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          color: AppColors.backgroundFab, // Latar belakang FAB
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0), // 👈 Memberi jarak kiri-kanan sebesar 16
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, LucideIcons.layoutDashboard, 'Home'),
                _buildNavItem(1, LucideIcons.checkSquare, 'Tasks'),
                const SizedBox(width: 40), 
                _buildNavItem(2, LucideIcons.calendarDays, 'Activity'),
                _buildNavItem(3, LucideIcons.user, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
            size: 22,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, // Memakai bobot yang rapi
              color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}