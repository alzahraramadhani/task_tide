import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart'; // Import pondasi warna

class TaskOverviewGrid extends StatelessWidget {
  final int activeCount;
  final int doneCount;
  final int categoryCount;

  const TaskOverviewGrid({
    super.key,
    required this.activeCount,
    required this.doneCount,
    required this.categoryCount,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildCard('$activeCount', 'Active'),
        _buildCard('${activeCount + doneCount}', 'This Week'),
        _buildCard('$doneCount', 'Done'),
        _buildCard('$categoryCount', 'Categories'),
      ],
    );
  }

  static Widget _buildCard(String value, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26, 
              fontWeight: FontWeight.bold, 
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13, 
              fontWeight: FontWeight.w500, 
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}