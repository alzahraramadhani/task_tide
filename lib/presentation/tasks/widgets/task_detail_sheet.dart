import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:task_tide/core/constants/colors.dart';
import 'package:task_tide/data/models/task_model.dart';
import 'package:task_tide/data/models/category_model.dart';
import 'package:task_tide/presentation/tasks/form_task_screen.dart';
import 'package:task_tide/providers/task_provider.dart'; 

void showTaskDetailBottomSheet(BuildContext context, TaskModel task, CategoryModel? category) {
  // Helper untuk mendapatkan warna dari model kategori atau warna default
  Color getCategoryColor() {
    if (category?.colorHex != null) {
      try {
        final hexStr = category!.colorHex.replaceFirst('#', '');
        return Color(int.parse('FF$hexStr', radix: 16));
      } catch (_) {}
    }
    // Warna fallback acak/pastel pertama jika tidak ada
    return AppColors.pastelPalette[0];
  }

  // Helper untuk warna aksen (teks di dalam chip kategori)
  Color getAccentColor(Color basePastel) {
    if (basePastel == AppColors.pastelPalette[0]) return AppColors.accentOrange;
    if (basePastel == AppColors.pastelPalette[1]) return AppColors.accentPurple;
    if (basePastel == AppColors.pastelPalette[2]) return const Color(0xFF2E7D32);
    if (basePastel == AppColors.pastelPalette[3]) return const Color(0xFF0277BD);
    if (basePastel == AppColors.pastelPalette[4]) return const Color.fromARGB(255, 189, 2, 152);
    if (basePastel == AppColors.pastelPalette[5]) return const Color.fromARGB(255, 154, 166, 20);
    return AppColors.primaryBlue;
  }

  final categoryBgColor = getCategoryColor();
  final categoryTextColor = getAccentColor(categoryBgColor);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Memungkinkan tinggi sheet fleksibel
    backgroundColor: Colors.white, // Latar belakang putih bersih kontras
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (BuildContext context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Menyesuaikan dengan konten
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Drag Handle (Garis abu-abu kecil di atas)
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 2. Category Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: categoryBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  (category?.name ?? 'GENERAL').toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: categoryTextColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 3. Task Title
              Text(
                task.title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 24),

              // 4. Deadline Date & Time (Sesuai Gambar)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F0), // Merah sangat muda
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      LucideIcons.calendar,
                      color: Color(0xFFD32F2F),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DEADLINE',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMMM d, yyyy • h:mm a').format(task.deadline),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 5. Notes & Details (Opsional, hanya tampil jika ada)
              if (task.notes != null && task.notes!.isNotEmpty) ...[
                Text(
                  'NOTES',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100, // Abu-abu tipis
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    task.notes!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textDark,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // 6. Action Buttons (Edit & Delete)
              Row(
                children: [
                  // Tombol Edit
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // 2. Tutup bottom sheet terlebih dahulu agar bersih
                        
                        // 3. Arahkan pengguna ke FormTaskScreen sambil MEMBAWA data task aktif saat ini
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FormTaskScreen(task: task), // Data dikirim ke sini!
                          ),
                        );
                      },
                      icon: const Icon(LucideIcons.edit2, size: 18, color: Colors.white),
                      label: Text(
                        'Edit',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Tombol Delete
                  InkWell(
                    onTap: () {
                      _showDeleteConfirmationDialog(context, task.id!);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE), // Latar merah pudar
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        LucideIcons.trash2,
                        color: Color(0xFFD32F2F), // Merah tegas
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8), // Ekstra padding bawah
            ],
          ),
        ),
      );
    },
  );
}

// Fungsi helper untuk menampilkan Dialog Konfirmasi Hapus
void _showDeleteConfirmationDialog(BuildContext context, int taskId) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Task?',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this task? This action cannot be undone.',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary,
                // fontWeight: FontWeight.bold,
              ),
            ),
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
      );
    },
  );
}