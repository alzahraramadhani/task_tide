import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart'; // Import pondasi warna

class TotalProgressBar extends StatelessWidget {
  final double progress; 

  const TotalProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Progress',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16, 
                fontWeight: FontWeight.bold, 
                color: AppColors.textDark,
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%', 
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14, 
                fontWeight: FontWeight.bold, 
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor: AppColors.progressBackground,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
          ),
        ),
      ],
    );
  }
}