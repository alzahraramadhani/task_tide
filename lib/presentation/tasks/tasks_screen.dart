import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:task_tide/core/constants/colors.dart';
import 'package:task_tide/providers/task_provider.dart';
import 'package:task_tide/providers/category_provider.dart';
import 'widgets/task_item_card.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TextEditingController _searchController = TextEditingController();
  int? _selectedCategoryId; // null berarti tab filter 'All'
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    // Inisialisasi data SQLite saat halaman pertama kali dibuka
    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      context.read<TaskProvider>().fetchTasks();
      context.read<CategoryProvider>().fetchCategories();
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
              // 1. JUDUL HALAMAN UTAMA (Mockup Desain Presisi)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Tasks',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. SEARCH BAR (Menyelaraskan gaya _buildInputDecoration)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06), // Warna shadow soft
                      blurRadius: 10, // Kelembutan bayangan
                      offset: const Offset(0, 4), // Posisi bayangan (x: kanan/kiri, y: atas/bawah)
                      spreadRadius: 0, // Penyebaran bayangan
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
                    hintText: 'Search tasks...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
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

              // 3. CAPSULE TABS HORIZONTAL FILTER (Data Dinamis dari CategoryProvider)
              Consumer<CategoryProvider>(
                builder: (context, categoryProvider, child) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        // Kapsul bawaan 'All'
                        _buildTabCapsule(
                          label: 'All',
                          isSelected: _selectedCategoryId == null,
                          onTap: () => setState(() => _selectedCategoryId = null),
                        ),
                        // Menampilkan list kategori dinamis dari DB SQLite
                        ...categoryProvider.categories.map((category) {
                          return _buildTabCapsule(
                            label: category.name,
                            isSelected: _selectedCategoryId == category.id,
                            onTap: () => setState(() => _selectedCategoryId = category.id),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // 4. TEKS JUMLAH TUGAS AKTIF
              Consumer<TaskProvider>(
                builder: (context, taskProvider, child) {
                  // Melakukan pra-filter untuk menghitung total tugas aktif yang sesuai kriteria tab saat ini
                  final currentActiveFiltered = taskProvider.activeTasks.where((task) {
                    final matchCategory = _selectedCategoryId == null || task.categoryId == _selectedCategoryId;
                    final matchSearch = task.title.toLowerCase().contains(_searchQuery);
                    return matchCategory && matchSearch;
                  }).length;

                  return Text(
                    "$currentActiveFiltered Active Task",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // 5. DAFTAR TUGAS RESPONSIF (Consumer<TaskProvider>)
              Expanded(
                child: Consumer2<TaskProvider, CategoryProvider>(
                  builder: (context, taskProvider, categoryProvider, child) {
                    if (taskProvider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.primaryBlue),
                      );
                    }

                    // Logika Filter Gabungan: Kategori Kapsul + Query Pencarian Kalimat
                    final filteredTasks = taskProvider.tasks.where((task) {
                      final matchesCategory = _selectedCategoryId == null || task.categoryId == _selectedCategoryId;
                      final matchesSearch = task.title.toLowerCase().contains(_searchQuery);
                      return matchesCategory && matchesSearch;
                    }).toList();

                    if (filteredTasks.isEmpty) {
                      return Center(
                        child: Text(
                          'Tidak ada tugas ditemukan.',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredTasks.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        // Mencari data objek kategori milik tugas terkait untuk dikirim ke widget kartu
                        final matchedCategory = categoryProvider.categories.firstWhere(
                          (cat) => cat.id == task.categoryId,
                          orElse: () => categoryProvider.categories.isNotEmpty 
                              ? categoryProvider.categories.first 
                              : throw Exception('Kategori tidak sinkron'),
                        );

                        // Membungkus Kartu dengan Dismissible untuk Fitur Geser Hapus
                        return Dismissible(
                          key: Key('task_${task.id}'),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (direction) async {
                            // Dialog Konfirmasi sebelum benar-benar menghapus data dari SQLite
                            return await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                title: Text(
                                  'Delete Task?', 
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold, 
                                    color: AppColors.textDark
                                  )
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
                            margin: const EdgeInsets.only(bottom: 15), // Sejajar dengan margin bawah TaskItemCard
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            decoration: BoxDecoration(
                              color: Colors.red.shade400,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.centerRight,
                            child: const Icon(LucideIcons.trash2, color: Colors.white, size: 24),
                          ),
                          child: TaskItemCard(
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Desain Kapsul Filter Tab Sesuai Mockup Gambar
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
                    color: AppColors.primaryBlue.withValues(alpha: 0.2),
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