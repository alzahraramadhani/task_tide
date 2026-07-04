import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:task_tide/core/constants/colors.dart';
import '../../../providers/task_provider.dart';
import '../../../providers/activity_provider.dart';
import '../../../providers/category_provider.dart'; 
import '../../../providers/app_state_provider.dart';
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
      context.read<AppStateProvider>().checkOnboardingStatus();
    });
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
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.progressBackground,
                    child: Icon(Icons.person, color: AppColors.textSecondary),
                  ),
                  Text(
                    'TaskTide',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
              const SizedBox(height: 24),
              Consumer<AppStateProvider>(
                builder: (context, appStateProvider, child) {
                  final username = appStateProvider.username ?? 'Zahra';
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
                    return _buildEmptyState('Tidak ada tugas aktif harian.');
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
                            : throw Exception('Kategori tidak sinkron'),
                      );

                      return Dismissible(
                        key: Key('focus_${task.id}'),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: Text('Hapus Tugas', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                              content: Text('Apakah kamu yakin ingin menghapus tugas "${task.title}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext, false),
                                  child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary)),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade600,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () => Navigator.pop(dialogContext, true),
                                  child: Text('Hapus', style: GoogleFonts.plusJakartaSans(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) async {
                          await taskProvider.deleteTask(task.id!);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Tugas "${task.title}" berhasil dihapus.')),
                            );
                          }
                        },
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 12), // Sesuai margin bawah TodaysFocusCard
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            color: Colors.red.shade600,
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
                    return _buildEmptyState('Belum ada aktivitas mendatang.');
                  }

                  return ListView.builder(
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
                              color: Colors.black.withOpacity(0.02),
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
                                                  color: Colors.red.shade700,
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