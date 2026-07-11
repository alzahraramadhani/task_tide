import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:task_tide/core/constants/colors.dart';
import 'package:task_tide/data/models/task_model.dart';
import 'package:task_tide/data/models/category_model.dart';
import 'package:task_tide/presentation/tasks/widgets/task_detail_sheet.dart';

class TaskItemCard extends StatelessWidget {
  final TaskModel task;
  final CategoryModel? category;
  final int index;
  final VoidCallback onToggle;

  const TaskItemCard({
    super.key,
    required this.task,
    required this.category,
    required this.index,
    required this.onToggle,
  });

  // Helper untuk menentukan sisa hari tenggat waktu (Tanpa Emoji)
  Widget _buildDueDateWidget() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDate = DateTime(task.deadline.year, task.deadline.month, task.deadline.day);
    final difference = deadlineDate.difference(today).inDays;

    String text;
    IconData icon;
    Color textColor;

    if (task.isCompleted) {
      text = "Done";
      icon = LucideIcons.checkCircle;
      textColor = AppColors.textSecondary;
    } else if (difference == 0) {
      text = "Due today";
      icon = LucideIcons.clock;
      textColor = const Color(0xFFD32F2F); // Merah tegas mendesak
    } else if (difference == 1) {
      text = "Due tomorrow";
      icon = LucideIcons.clock;
      textColor = AppColors.accentOrange;
    } else if (difference > 1) {
      text = "$difference days remaining";
      icon = LucideIcons.calendar;
      textColor = AppColors.textSecondary;
    } else {
      text = "Passed due";
      icon = LucideIcons.alertTriangle;
      textColor = const Color(0xFFD32F2F);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: textColor),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }

  // Helper konversi HEX ke Color objek
  Color _getCategoryColor() {
    if (category?.colorHex != null) {
      try {
        final hexStr = category!.colorHex.replaceFirst('#', '');
        return Color(int.parse('FF$hexStr', radix: 16));
      } catch (_) {}
    }
    // Jika gagal, distribusikan warna pastel bawaan berurutan
    return AppColors.pastelPalette[index % AppColors.pastelPalette.length];
  }

  // Helper untuk mendapatkan warna teks aksen berdasarkan warna pastel background
  Color _getAccentColor(Color basePastel) {
    if (basePastel == AppColors.pastelPalette[0]) return AppColors.accentOrange;
    if (basePastel == AppColors.pastelPalette[1]) return AppColors.accentPurple;
    if (basePastel == AppColors.pastelPalette[2]) return const Color(0xFF2E7D32);
    if (basePastel == AppColors.pastelPalette[3]) return const Color(0xFF0277BD);
    if (basePastel == AppColors.pastelPalette[4]) return const Color.fromARGB(255, 189, 2, 152);
    if (basePastel == AppColors.pastelPalette[5]) return const Color.fromARGB(255, 154, 166, 20);
    return AppColors.primaryBlue;
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getCategoryColor();
    final accentColor = _getAccentColor(backgroundColor);

    // Warna Badge Tingkat Kesulitan
    Color difficultyBg;
    Color difficultyText;
    if (task.priorityLevel == 'High') {
      difficultyBg = const Color(0xFFFFEBEE);
      difficultyText = const Color(0xFFC62828);
    } else if (task.priorityLevel == 'Medium') {
      difficultyBg = const Color(0xFFFFF9C4);
      difficultyText = const Color(0xFFF57F17);
    } else {
      difficultyBg = const Color(0xFFE8F5E9);
      difficultyText = const Color(0xFF2E7D32);
    }

    return GestureDetector(
      onTap: () {
        // Panggil fungsi pop-up di sini
        showTaskDetailBottomSheet(context, task, category);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Ujung kiri kartu memiliki indikator warna pastel yang sedikit lebih tebal/pekat
                Container(
                  width: 6,
                  // color: accentColor.withOpacity(0.4),
                ),
                const SizedBox(width: 12),
                
                // Checkbox Melingkar Kustom
                GestureDetector(
                    onTap: onToggle,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white, // Bagian dalam tetap putih bersih
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: task.isCompleted ? Colors.grey.shade400 : accentColor, // Outline warna aksen
                          width: 2, // Garis outline tebal
                        ),
                      ),
                      child: task.isCompleted
                          ? Icon(
                              LucideIcons.check,
                              size: 14,
                              color: Colors.grey.shade600,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 14),

                // Konten Informasi Utama Tugas
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 16.0, right: 16.0, left: 5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Baris Kategori dengan Titik Bulat Indikator
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: accentColor,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              category?.name ?? 'Umum',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Judul Tugas (Dengan Efek Coret jika Selesai)
                        Text(
                          task.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: task.isCompleted ? AppColors.textSecondary : AppColors.textDark,
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Batas Waktu murni menggunakan LucideIcons
                        _buildDueDateWidget(),
                      ],
                    ),
                  ),
                ),

                // Badge Tingkat Kesulitan di Pojok Kanan Atas Kartu
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, right: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: task.isCompleted ? Colors.grey.shade300 : difficultyBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          task.priorityLevel,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: task.isCompleted ? Colors.grey.shade600 : difficultyText,
                          ),
                        ),
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
}