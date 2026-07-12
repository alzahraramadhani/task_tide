import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:task_tide/providers/activity_provider.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/activity_model.dart';
import 'package:task_tide/presentation/activities/widgets/activity_detail_sheet.dart';

class ActivityItemCard extends StatelessWidget {
  final ActivityModel activity;
  final int index;

  const ActivityItemCard({
    super.key,
    required this.activity,
    required this.index,
  });

  // Helper untuk menentukan sisa hari tenggat waktu (Tanpa Emoji)
  Widget _buildDueDateWidget() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final activityDay = DateTime(activity.activityDate.year, activity.activityDate.month, activity.activityDate.day);
    final difference = activityDay.difference(today).inDays;

    String text;
    IconData icon;
    Color textColor;

    if (activity.isCompleted) {
      // Acara sudah selesai diikuti atau ditandai selesai
      text = "Attended"; // atau "Finished" / "Done"
      icon = LucideIcons.checkCircle2;
      textColor = AppColors.textSecondary;
    } else if (difference == 0) {
      // Acara diadakan hari ini
      text = "Today"; // atau "Happening today"
      icon = LucideIcons.calendarDays;
      textColor = AppColors.primaryBlue; // Warna utama agar mencolok tapi tidak menakutkan seperti merah tugas
    } else if (difference == 1) {
      // Acara besok
      text = "Tomorrow";
      icon = LucideIcons.calendar;
      textColor = AppColors.accentOrange; // Mengingatkan bahwa besok ada acara
    } else if (difference > 1) {
      // Masih beberapa hari lagi
      text = "In $difference days"; // Contoh: "In 4 days" terasa lebih natural untuk event
      icon = LucideIcons.calendar;
      textColor = AppColors.textSecondary;
    } else {
      // Acara sudah lewat tanggalnya tapi belum ditandai selesai
      text = "Ended"; // atau "Past event"
      icon = LucideIcons.calendarX;
      textColor = Colors.grey.shade500; // Warna abu-abu redup karena event-nya sudah berlalu
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

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        // 3. Panggil fungsi pop-up di sini dengan melemparkan data activity saat ini
        showActivityDetailBottomSheet(context, activity);
      },
      child:Dismissible(
        key: Key('activity_${activity.id}'), // Menggunakan ID unik dari SQLite
        direction: DismissDirection.endToStart, // Geser dari kanan ke kiri untuk menghapus
        background: Container(
          margin: const EdgeInsets.only(bottom: 16), // Sesuaikan dengan margin/jarak antar kartu Anda
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.red.shade400, // Warna merah pastel yang bersih untuk indikasi hapus
            borderRadius: BorderRadius.circular(14), // Samakan dengan border radius kartu Anda
          ),
          child: const Icon(
            LucideIcons.trash2,
            color: Colors.white,
            size: 24,
          ),
        ),
        onDismissed: (direction) {
          final activityName = activity.name;

          // 4. Panggil fungsi hapus dari ActivityProvider secara asinkronus
          context.read<ActivityProvider>().deleteActivity(activity.id!);

          // 5. Berikan feedback berupa SnackBar mengambang yang rapi kepada pengguna
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Agenda "$activityName" berhasil dihapus'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            // 👇 Tambahkan border khusus di sisi kiri saja
            border: const Border(
              left: BorderSide(
                color: AppColors.primaryBlue, // Warna birumu
                width: 5,                     // Ketebalan indikator
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [            
                // Konten Kartu Utama
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              // Kotak Ikon Kiri dekoratif
                              Container(
                                margin: EdgeInsets.only(left: 12),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.iconBackground,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  LucideIcons.calendarDays,
                                  color: AppColors.primaryBlue,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              
                              // Detail Informasi Agenda
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      activity.name,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textDark,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    
                                    // Informasi Waktu Terikat Aturan (Ikon Lucide murni + No Emoji)
                                    _buildDueDateWidget(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        
                        // Badge tipe aktivitas di pojok kanan kartu
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.iconBackground,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  (activity.typeName ?? 'UMUM').toUpperCase(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.bold,
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
                const SizedBox(width: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}