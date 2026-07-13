import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:task_tide/core/constants/colors.dart';
import 'package:task_tide/data/models/activity_model.dart';
import 'package:task_tide/providers/activity_provider.dart';
import 'package:task_tide/presentation/activities/form_activity_screen.dart';

void showActivityDetailBottomSheet(BuildContext context, ActivityModel activity) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Fleksibel mengikuti isi konten
    backgroundColor: Colors.white, // Latar belakang putih kontras
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (BuildContext context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Drag Handle (Garis abu-abu di atas)
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

              // 2. Activity Type Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.iconBackground, // Latar biru pudar bawaan
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  (activity.typeName ?? 'UMUM').toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 3. Name of Activity
              Text(
                activity.name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 24),

              // 4. Activity Date & Time
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD), // Biru sangat muda (Light Blue)
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      LucideIcons.calendarDays,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DATE & TIME',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMMM d, yyyy • h:mm a').format(activity.activityDate),
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

              // 5. Notes & Details (Hanya tampil jika ada isi)
              if (activity.notes != null && activity.notes!.trim().isNotEmpty) ...[
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
                    activity.notes!,
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
                        Navigator.pop(context); // Tutup bottom sheet dulu
                      
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FormActivityScreen(activity: activity),
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
                      showDeleteConfirmationDialog(context, activity.id!, isFromBottomSheet: true);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE), // Latar merah pucat
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
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
}

// Fungsi helper dialog konfirmasi hapus aktivitas
Future<bool?> showDeleteConfirmationDialog(BuildContext context, int activityId, {bool isFromBottomSheet = false}) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Activity?',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this activity? This action cannot be undone.',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            // Mengembalikan nilai false jika batal agar Dismissible kembali ke posisi semula
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
            onPressed: () {
              // 1. Jalankan fungsi hapus data
              Provider.of<ActivityProvider>(context, listen: false).deleteActivity(activityId);
              
              // 2. Tutup dialog dengan mengembalikan nilai true agar Dismissible bergeser hilang
              Navigator.pop(dialogContext, true);
              
              // 3. Hanya tutup BottomSheet jika dipicu dari tombol hapus di dalam BottomSheet
              if (isFromBottomSheet == true) {
                Navigator.pop(context);
              }
            },
            child: Text('Delete', style: GoogleFonts.plusJakartaSans(color: Colors.white)),
          ),
        ],
      );
    },
  );
}