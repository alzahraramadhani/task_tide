import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:task_tide/core/constants/colors.dart';
import 'package:task_tide/presentation/onboarding/onboarding_screen.dart';
import 'package:task_tide/presentation/profile/profile_screen.dart';
import '../../../providers/task_provider.dart';
import '../../../providers/activity_provider.dart';
import '../../../providers/category_provider.dart'; 
import '../../../providers/app_state_provider.dart';
import '../activities/widgets/activity_item_card.dart';
import 'widgets/total_progress_bar.dart';
import 'widgets/todays_focus_card.dart';
import 'widgets/task_overview_grid.dart'; // Pastikan path ini sesuai dengan struktur proyek Anda

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onProfileTap;

  const DashboardScreen({super.key, this.onProfileTap});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}


class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<TaskProvider>().fetchTasks();
      context.read<ActivityProvider>().fetchActivities();
      context.read<CategoryProvider>().fetchCategories(); 
      context.read<AppStateProvider>().checkOnboardingStatus();
    });
  }

  // logika logout dan reset profile
  Future<void> _showLogoutDialog(BuildContext context) async {
    bool confirmReset = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Reset Profile?', 
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)
            ),
            content: Text(
              'This action will permanently delete your data from local storage.', 
              style: GoogleFonts.plusJakartaSans()
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel', 
                  style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary)
                ),
              ),
              TextButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Logout', 
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)
                ),
              ),
            ],
          ),
        ) ?? false;

    if (confirmReset && context.mounted) {
      await context.read<AppStateProvider>().resetProfile();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER SECTION (Struktur Urutan Codingan 1 + Nama Dinamis)
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                
                // Pembungkus avatar menjadi menu melayang kecil yang rapi
                  PopupMenuButton<int>(
                    tooltip: 'Menu Profil',
                    padding: EdgeInsets.zero, // FIX: Menghilangkan padding bawaan agar posisi avatar tidak bergeser
                    offset: const Offset(0, 52), // Jarak memicu kemunculan tepat di bawah avatar
                    color: Colors.white,
                    elevation: 4,
                    shadowColor: Colors.black.withValues(alpha: 0.15), // FIX: Menggunakan syntax dengan nilai alpha terbaru
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16), // Membuat sudut kotak melayang melengkung halus
                    ),
                    onSelected: (value) {
                      // Eksekusi aksi jika opsi menu dipilih
                      if (value == 1) {
                        // Contoh: Pindah ke halaman profil atau trigger aksi lainnya
                      }
                    },
                    itemBuilder: (context) => [
                    
                      // Item 1: Tombol Navigasi profil
                      PopupMenuItem<int>(
                        value: 1,
                        // FIX 1: Pindahkan logika navigasi ke onTap bawaan PopupMenuItem agar seluruh area responsif
                        onTap: () {
                        if (widget.onProfileTap != null) {
                            // Beri sedikit delay agar animasi pop up menutup selesai terlebih dahulu dengan mulus
                            Future.delayed(
                              const Duration(milliseconds: 100),
                              () => widget.onProfileTap!(),
                            );
                          }
                        },
                          child: Row(
                            children: [
                              const Icon(LucideIcons.user, size: 19, color: AppColors.primaryBlue),
                              const SizedBox(width: 12),
                              Text(
                                'Profile',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                    

                      const PopupMenuDivider(height: 1),

                      // Item 2: Tombol Logout
                      PopupMenuItem<int>(
                        value: 2,
                        // FIX 2: Pindahkan juga logika logout ke onTap bawaan PopupMenuItem
                        onTap: () {
                          Future.delayed(
                            const Duration(milliseconds: 100),
                            () => _showLogoutDialog(context),
                          );
                        },
                          child: Row(
                            children: [
                              const Icon(LucideIcons.logOut, size: 18, color: Colors.redAccent),
                              const SizedBox(width: 12),
                              Text(
                                'Logout',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
          
                    ],
                    
                    // Pemicu Klik: Menggunakan asset UI CircleAvatar asli dari rancangan awal Anda
                    child: const CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.iconBackground,
                      child: Icon(Icons.person, color: Color.fromARGB(255, 87, 94, 107)),
                    ),
                  ),
                  
                  // Judul Aplikasi: Tetap terkunci aman tepat di posisi tengah layar
                  Text(
                    'TaskTide',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  
                  // Penyeimbang porsi row kanan agar sumbu 'TaskTide' mutlak sentral (44 didapat dari diameter avatar)
                  const SizedBox(width: 44),
                ],
              ),
              const SizedBox(height: 24),
              Consumer<AppStateProvider>(
                builder: (context, appStateProvider, child) {
                  final username = appStateProvider.username;
                  return Text(
                    'Halo, $username 👋',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // 2. WEEKLY PROGRESS BAR (Optimasi Consumer + Properti Codingan 1)
              Consumer<TaskProvider>(
                builder: (context, taskProvider, child) {
                  return TotalProgressBar(progress: taskProvider.weeklyProgress);
                },
              ),
              const SizedBox(height: 28),

              // 3. TODAY'S FOCUS SECTION (Optimasi Consumer + Detail Estetik Codingan 1)
              Text(
                "Today's Focus",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              // Ubah menjadi Consumer2<TaskProvider, CategoryProvider>
              Consumer2<TaskProvider, CategoryProvider>(
                builder: (context, taskProvider, categoryProvider, child) {
                  if (taskProvider.activeTasks.isEmpty) {
                    return _buildEmptyState('No active daily tasks.');
                  }
                  
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: taskProvider.activeTasks.take(2).length,
                    itemBuilder: (context, index) {
                      final task = taskProvider.activeTasks[index];
                      
                      final matchedCategory = categoryProvider.categories.firstWhere(
                        (cat) => cat.id == task.categoryId,
                        orElse: () => categoryProvider.categories.isNotEmpty 
                            ? categoryProvider.categories.first 
                            : throw Exception('Categories out of sync'),
                      );

                      return Dismissible(
                        key: Key('focus_${task.id}'),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: Text('Delete Task', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                              content: Text('Are you sure you want to delete the task "${task.title}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext, false),
                                  child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary)),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade400,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () => Navigator.pop(dialogContext, true),
                                  child: Text('Delete', style: GoogleFonts.plusJakartaSans(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) async {
                          await taskProvider.deleteTask(task.id!);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Task "${task.title}" deleted successfully.')),
                            );
                          }
                        },
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 12), // Sesuai margin bawah TodaysFocusCard
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.centerRight,
                          child: const Icon(LucideIcons.trash2, color: Colors.white, size: 24),
                        ),
                        child: TodaysFocusCard(
                          task: task,
                          category: matchedCategory,
                          index: index,
                          onToggle: () {
                            taskProvider.toggleTaskCompletion(task.id!, task.isCompleted);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),

              // 4. TASK OVERVIEW GRID (Multi-Consumer untuk Efisiensi Maksimal)
              Text(
                "Task Overview",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Consumer2<TaskProvider, CategoryProvider>(
                builder: (context, taskProvider, categoryProvider, child) {
                  return TaskOverviewGrid(
                    activeCount: taskProvider.activeTasks.length,
                    doneCount: taskProvider.tasks.length - taskProvider.activeTasks.length,
                    categoryCount: categoryProvider.categories.length, 
                  );
                },
              ),
              const SizedBox(height: 28),

              // 5. UPCOMING ACTIVITIES (Desain 100% Codingan 1 + Loading State + Consumer)
              Text(
                "Upcoming Activities",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Consumer<ActivityProvider>(
                builder: (context, activityProvider, child) {
                  if (activityProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primaryBlue),
                    );
                  }
                  
                  if (activityProvider.activities.isEmpty) {
                    return _buildEmptyState('No upcoming activities.');
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: activityProvider.activities.length,
                    itemBuilder: (context, index) {
                      final activity = activityProvider.activities[index];
                      
                      // 👇 Memanggil widget ActivityItemCard terpusat yang reusable
                      return ActivityItemCard(
                        activity: activity,
                        index: index,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi Pembantu Empty State dari Codingan 1
  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Text(
        message, 
        style: GoogleFonts.plusJakartaSans(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),
    );
  }
}