import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/models/task_model.dart';
import '../../../../core/constants/colors.dart'; // Import pondasi warna

class TodaysFocusCard extends StatelessWidget {
  final TaskModel task;
  final Color backgroundColor;
  final Color accentColor;
  final VoidCallback onToggle;

  const TodaysFocusCard({
    super.key,
    required this.task,
    required this.backgroundColor,
    required this.accentColor,
    required this.onToggle,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 24,
              height: 25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: accentColor.withValues(alpha: 0.5), width: 2),
                color: Colors.white
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    const SizedBox(width: 6), // Dirapikan jaraknya
                    Text(
                      'Kuliah', // Menggunakan font terpusat
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14, 
                        fontWeight: FontWeight.bold, 
                        color: AppColors.primaryBlue,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  task.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold, 
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Skor Prioritas: ${task.priorityScore.toStringAsFixed(1)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, 
                    color: accentColor, 
                    fontWeight: FontWeight.w600,
                  ),
                )
              ],
            )
          )
        ],
      ),
    );
  }
}