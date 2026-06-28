import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Menggunakan LucideIcons sesuai kesepakatan
import '../core/constants/colors.dart';
import 'dashboard/dashboard_screen.dart';
import 'tasks/tasks_screen.dart';
import 'activities/activities_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Daftar 4 halaman utama aplikasi sesuai struktur folder
  final List<Widget> _screens = [
    const DashboardScreen(),
    const Scaffold(body: Center(child: Text('Tasks Screen Placeholder'))), // Sementara sebelum Day 7
    const Scaffold(body: Center(child: Text('Activities Screen Placeholder'))), // Sementara sebelum Day 8
    const Scaffold(body: Center(child: Text('Profile Screen Placeholder'))), // Sementara sebelum Day 8
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      
      // ➕ Tombol Melayang Sentral di Tengah (Floating Action Button)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateModalSheet(context);
        },
        backgroundColor: AppColors.primaryBlue,
        shape: const CircleBorder(),
        child: const Icon(LucideIcons.plus, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // 🗺️ Bottom Navigation Bar Sentral
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        clipBehavior: Clip.antiAlias,
        child: Container(
          height: 60,
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Tab 1: Dashboard / Home
              _buildNavItem(LucideIcons.home, 'Home', 0),
              // Tab 2: Tasks
              _buildNavItem(LucideIcons.checkSquare, 'Tasks', 1),
              
              const SizedBox(width: 40), // Space kosong sebagai tempat notch FAB di tengah
              
              // Tab 3: Activities
              _buildNavItem(LucideIcons.calendarDays, 'Activities', 2), // Konsisten memakai calendarDays
              // Tab 4: Profile
              _buildNavItem(LucideIcons.user, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget untuk membangun item navigasi yang konsisten
  Widget _buildNavItem(IconData icon, String label, int index) {
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
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // 📑 Modal Bottom Sheet "Create New" Mandat Hari 4
  void _showCreateModalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8EAF6),
                  child: Icon(LucideIcons.checkSquare, color: AppColors.primaryBlue),
                ),
                title: const Text('Tambah Tugas Baru', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Tugas kuliah dengan kalkulasi prioritas otomatis'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigasi ke FormTaskScreen di Day 5
                },
              ),
              const Divider(),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFFF3E0),
                  child: Icon(LucideIcons.calendarDays, color: AppColors.accentOrange),
                ),
                title: const Text('Tambah Aktivitas Baru', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Agenda non-tugas seperti kuis, ujian, atau lomba'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigasi ke FormActivityScreen di Day 5
                },
              ),
            ],
          ),
        );
      },
    );
  }
}