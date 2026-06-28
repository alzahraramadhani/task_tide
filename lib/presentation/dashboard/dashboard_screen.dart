import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:task_tide/core/constants/colors.dart'; // Memastikan import AppColors terhubung
import '../../../providers/task_provider.dart';
import '../../../providers/activity_provider.dart';
import '../../../providers/category_provider.dart'; 
import 'widgets/total_progress_bar.dart';
import 'widgets/todays_focus_card.dart';
import 'widgets/task_overview_grid.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

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
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final activityProvider = context.watch<ActivityProvider>();
    final categoryProvider = context.watch<CategoryProvider>(); 

    return Scaffold(
      backgroundColor: AppColors.background, // Menggunakan warna latar belakang global
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // 1. HEADER SECTION
              // ==========================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.progressBackground, // Menggunakan warna progress background pastel
                    child: Icon(Icons.person, color: AppColors.textSecondary), // Menggunakan teks sekunder abu-abu
                  ),
                  Text(
                    'TaskTide',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue, // Menggunakan warna Royal Blue utama
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Halo, Zahra 👋',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark, // Menggunakan hitam pekat terpusat
                ),
              ),
              const SizedBox(height: 20),

              // ==========================================
              // 2. WEEKLY PROGRESS BAR
              // ==========================================
              TotalProgressBar(progress: taskProvider.weeklyProgress),
              const SizedBox(height: 28),

              // ==========================================
              // 3. TODAY'S FOCUS SECTION
              // ==========================================
              Text(
                "Today's Focus",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              taskProvider.activeTasks.isEmpty
                  ? _buildEmptyState('Tidak ada tugas aktif harian.')
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: taskProvider.activeTasks.take(2).length,
                      itemBuilder: (context, index) {
                        final task = taskProvider.activeTasks[index];
                        return TodaysFocusCard(
                          task: task,
                          // Mengambil dinamis dari 2 palet pertama di pastelPalette & warna aksennya
                          backgroundColor: index == 0 ? AppColors.pastelPalette[0] : AppColors.pastelPalette[1],
                          accentColor: index == 0 ? AppColors.accentOrange : AppColors.accentPurple,
                          onToggle: () {
                            taskProvider.toggleTaskStatus(task.id!, task.isCompleted);
                          },
                        );
                      },
                    ),
              const SizedBox(height: 24),

              // ==========================================
              // 4. TASK OVERVIEW GRID
              // ==========================================
              Text(
                "Task Overview",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              TaskOverviewGrid(
                activeCount: taskProvider.activeTasks.length,
                doneCount: taskProvider.tasks.length - taskProvider.activeTasks.length,
                categoryCount: categoryProvider.categories.length, 
              ),
              const SizedBox(height: 28),

              // ==========================================
              // 5. UPCOMING ACTIVITIES
              // ==========================================
              Text(
                "Upcoming Activities",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              activityProvider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
                  : activityProvider.activities.isEmpty
                      ? _buildEmptyState('Belum ada aktivitas mendatang.')
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: activityProvider.activities.length,
                          itemBuilder: (context, index) {
                            final activity = activityProvider.activities[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: IntrinsicHeight(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryBlue,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          bottomLeft: Radius.circular(16),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 4.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.progressBackground,
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: const Icon(
                                                    LucideIcons.calendarDays, 
                                                    color: AppColors.primaryBlue, 
                                                    size: 20,
                                                  ),
                                                ),
                                                const SizedBox(width: 14),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      activity.name,
                                                      style: GoogleFonts.plusJakartaSans(
                                                        fontSize: 15, 
                                                        fontWeight: FontWeight.bold, 
                                                        color: AppColors.textDark,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      '⏰ ${activity.activityDate.toString().substring(0, 16)}',
                                                      style: GoogleFonts.plusJakartaSans(
                                                        fontSize: 12, 
                                                        color: Colors.red.shade700, // Dipertahankan merah bawaan sebagai indikator urgensi/sisa waktu
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: AppColors.progressBackground,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                activity.typeName ?? 'UMUM',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 11, 
                                                  color: AppColors.primaryBlue, 
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Text(
        message, 
        style: GoogleFonts.plusJakartaSans(
          color: AppColors.textSecondary, // Menggunakan warna abu-abu teks sekunder global
          fontSize: 14,
        ),
      ),
    );
  }
}