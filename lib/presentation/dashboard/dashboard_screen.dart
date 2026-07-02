import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../providers/task_provider.dart';
import '../../providers/activity_provider.dart';
import '../../providers/app_state_provider.dart';
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
    // Jika di provider lamamu tidak ada loadData(), Flutter biasanya otomatis memuat data lewat constructor provider
  }

  @override
  Widget build(BuildContext context) {
    final username = context.watch<AppStateProvider>().username ?? 'Zahra';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, $username 👋',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Yuk, selesaikan tugas kuliahmu hari ini!',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                    child: Text(
                      username.isNotEmpty ? username[0].toUpperCase() : 'Z',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // 2. Total Progress Bar (Menyesuaikan parameter 'progress' milik widget lamamu)
              Consumer<TaskProvider>(
                builder: (context, taskProvider, child) {
                  final totalTasks = taskProvider.tasks.length; // Menggunakan .tasks sesuai model lamamu
                  final completedTasks = taskProvider.tasks.where((t) => t.isCompleted).length;
                  final double progressValue = totalTasks > 0 ? (completedTasks / totalTasks) : 0.0;

                  return TotalProgressBar(progress: progressValue); // Menggunakan parameter 'progress'
                },
              ),
              const SizedBox(height: 28),

              // 3. Today's Focus Card
              Text(
                "Today's Focus",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Consumer<TaskProvider>(
                builder: (context, taskProvider, child) {
                  final focusTasks = taskProvider.tasks.where((task) => !task.isCompleted).take(2).toList();

                  // Menggunakan parameter kustom lama widgetmu: task, backgroundColor, accentColor, onToggle
                  if (focusTasks.isEmpty) {
                    return const SizedBox();
                  }
                  
                  return TodaysFocusCard(
                    task: focusTasks.first, 
                    backgroundColor: Colors.white,
                    accentColor: AppColors.primaryBlue,
                    onToggle: () {},
                  );
                },
              ),
              const SizedBox(height: 28),

              // 4. Task Overview Grid
              Text(
                "Task Overview",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Consumer<TaskProvider>(
                builder: (context, taskProvider, child) {
                  // 1. Menghitung jumlah tugas aktif (belum selesai)
                  final active = taskProvider.tasks.where((t) => !t.isCompleted).length;
                  
                  // 2. Menghitung jumlah tugas yang sudah selesai
                  final done = taskProvider.tasks.where((t) => t.isCompleted).length;
                  
                  // 3. Menghitung jumlah kategori unik dari data tugas yang ada
                  // Mencegah error jika properti .categories tidak ditemukan di provider
                  final uniqueCategoriesCount = taskProvider.tasks
                      .map((task) => task.categoryId) // Mengambil properti kategori dari setiap objek task
                      .where((category) => category != null) // Memastikan kategorinya tidak null
                      .toSet() // Mengubah ke bentuk Set agar menduplikasi nilai yang sama (unik)
                      .length;

                  // Tuliskan pemanggilan widget-mu secara pas seperti ini:
                  return TaskOverviewGrid(
                    activeCount: active,
                    doneCount: done,
                    categoryCount: uniqueCategoriesCount, // Data dinamis yang aman dari error!
                  );
                },
              ),
              const SizedBox(height: 28),

              // 5. Upcoming Activities
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
                  final upcomingActivities = activityProvider.activities // Menggunakan .activities
                      .where((act) => !act.isCompleted)
                      .toList();

                  if (upcomingActivities.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Center(
                        child: Text(
                          'Belum ada aktivitas mendatang.',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: upcomingActivities.length > 3 ? 3 : upcomingActivities.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final activity = upcomingActivities[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              color: Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activity.name,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    activity.notes != null && activity.notes!.isNotEmpty ? activity.notes! : 'Tidak ada catatan',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}