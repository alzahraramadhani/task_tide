import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/colors.dart';
import '../../providers/activity_provider.dart';
import 'widgets/activity_item_card.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  final TextEditingController _searchController = TextEditingController();
  int? _selectedTypeId; // null berarti tab filter 'All'
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    // Proteksi inisialisasi state reaktif masa awal prapemuatan SQLite
    Future.delayed(Duration.zero, () {
      context.read<ActivityProvider>().fetchActivities();
      context.read<ActivityProvider>().fetchActivityTypes();
    });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. JUDUL HALAMAN UTAMA (Presisi sesuai standar UI Tasks)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Agenda',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. SEARCH BAR (Gaya Serasi Bulat Sempurna 54px Tinggi & Soft Shadow)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search agenda...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      color: AppColors.textSecondary.withOpacity(0.5),
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppColors.textSecondary),
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 3. CAPSULE TABS HORIZONTAL FILTER (Data Dinamis Tipe Aktivitas + Opsi Bawaan 'All')
              Consumer<ActivityProvider>(
                builder: (context, activityProvider, child) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildTabCapsule(
                          label: 'All',
                          isSelected: _selectedTypeId == null,
                          onTap: () => setState(() => _selectedTypeId = null),
                        ),
                        ...activityProvider.activityTypes.map((type) {
                          return _buildTabCapsule(
                            label: type.name,
                            isSelected: _selectedTypeId == type.id,
                            onTap: () => setState(() => _selectedTypeId = type.id),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // 4. SUB-HEADER LIST JUDUL SECTION
              Text(
                "Upcoming Activities",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),

              // 5. DAFTAR TUGAS RESPONSIF MENGGUNAKAN CONSUMER EFIENSI TINGGI
              Expanded(
                child: Consumer<ActivityProvider>(
                  builder: (context, activityProvider, child) {
                    if (activityProvider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.primaryBlue),
                      );
                    }

                    // Kombinasi filter lokal: Filter Kapsul Tipe + Query Input Pencarian Kata Kunci
                    final filteredActivities = activityProvider.activities.where((activity) {
                      final matchesType = _selectedTypeId == null || activity.activityTypeId == _selectedTypeId;
                      final matchesSearch = activity.name.toLowerCase().contains(_searchQuery);
                      return matchesType && matchesSearch;
                    }).toList();

                    if (filteredActivities.isEmpty) {
                      return Center(
                        child: Text(
                          'No agenda found.',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredActivities.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final activity = filteredActivities[index];
                        return ActivityItemCard(
                          activity: activity,
                          index: index,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Builder Pembentuk Kapsul Filter Tab Horizontal
  Widget _buildTabCapsule({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}