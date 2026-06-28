import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/colors.dart';
import '../../data/models/task_model.dart';
import '../../data/models/category_model.dart';
import '../../providers/task_provider.dart';
import '../../providers/category_provider.dart';
import 'widgets/inline_category_dialog.dart';

class FormTaskScreen extends StatefulWidget {
  const FormTaskScreen({super.key});

  @override
  State<FormTaskScreen> createState() => _FormTaskScreenState();
}

class _FormTaskScreenState extends State<FormTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  int? _selectedCategoryId;
  String _selectedDifficulty = 'Medium'; // Default tingkat kesulitan
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    // Memastikan data kategori terbaru dimuat dari SQLite saat form dibuka
    Future.delayed(Duration.zero, () {
      context.read<CategoryProvider>().fetchCategories();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Fungsi picker untuk memilih Tanggal & Waktu Deadline secara berurutan
  Future<void> _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primaryBlue),
        ),
        child: child!,
      ),
    );

    if (pickedDate != null) {
      if (!mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primaryBlue),
          ),
          child: child!,
        ),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  // Fungsi untuk memicu kemunculan dialog kategori inline kustom kita
  void _openInlineCategoryDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const InlineCategoryDialog(),
    );

    // Jika berhasil menyimpan kategori baru, refresh dropdown list
    if (result == true) {
      if (!mounted) return;
      await context.read<CategoryProvider>().fetchCategories();
    }
  }

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih kategori tugas terlebih dahulu!')),
        );
        return;
      }
      if (_selectedDateTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tentukan tenggat waktu (due date) tugas!')),
        );
        return;
      }

      final taskProvider = context.read<TaskProvider>();
      
      final newTask = TaskModel(
        categoryId: _selectedCategoryId!,
        title: _titleController.text.trim(),
        notes: _notesController.text.trim(),
        priorityLevel: _selectedDifficulty,
        deadline: _selectedDateTime!,
        isCompleted: false, // Tugas baru berstatus aktif
        priorityScore: 0.0, // Akan dihitung otomatis oleh priority engine di layer provider
      );

      await taskProvider.addTask(newTask);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tugas baru berhasil ditambahkan!')),
        );
        Navigator.pop(context); // Kembali ke halaman navigasi utama
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tambah Tugas Kuliah',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==========================================
                // INPUT JUDUL TUGAS
                // ==========================================
                Text(
                  'Judul Tugas / Mata Kuliah',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  style: GoogleFonts.plusJakartaSans(fontSize: 15, color: AppColors.textDark, fontWeight: FontWeight.w500),
                  decoration: _buildInputDecoration('Contoh: Analisis Program Sorting C...'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Judul tugas tidak boleh kosong' : null,
                ),
                const SizedBox(height: 20),

                // ==========================================
                // SELEKTOR KATEGORI DINAMIS + INLINE TRIGGER
                // ==========================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kategori Tugas',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 14),
                    ),
                    TextButton.icon(
                      onPressed: _openInlineCategoryDialog,
                      icon: const Icon(LucideIcons.plus, size: 16, color: AppColors.primaryBlue),
                      label: Text(
                        'Kategori Baru',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                DropdownButtonFormField<int>(
                  initialValue: _selectedCategoryId,
                  items: categoryProvider.categories.map((category) {
                    return DropdownMenuItem<int>(
                      value: category.id,
                      child: Text(
                        category.name,
                        style: GoogleFonts.plusJakartaSans(fontSize: 15, color: AppColors.textDark, fontWeight: FontWeight.w500),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                  decoration: _buildInputDecoration('Pilih kategori kuliah...'),
                ),
                const SizedBox(height: 20),

                // ==========================================
                // SELEKTOR DIFFICULTY LEVEL (LOW, MEDIUM, HIGH)
                // ==========================================
                Text(
                  'Tingkat Kesulitan (Bobot)',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 14),
                ),
                const SizedBox(height: 10),
                Row(
                  children: ['Low', 'Medium', 'High'].map((level) {
                    final isSelected = _selectedDifficulty == level;
                    Color activeColor = AppColors.primaryBlue;
                    if (level == 'Low') activeColor = Colors.green;
                    if (level == 'High') activeColor = Colors.redAccent;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedDifficulty = level),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected ? activeColor.withValues(alpha: 0.1) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? activeColor : Colors.grey.shade200,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            level,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isSelected ? activeColor : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // ==========================================
                // SELEKTOR DEADLINE (DATE & TIME PICKER)
                // ==========================================
                Text(
                  'Batas Pengumpulan (Deadline)',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 14),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickDateTime,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDateTime == null
                              ? 'Pilih tanggal & jam batas waktu...'
                              : DateFormat('EEEE, dd MMMM yyyy - HH:mm', 'id').format(_selectedDateTime!),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: _selectedDateTime == null ? AppColors.textSecondary.withValues(alpha: 0.6) : AppColors.textDark,
                          ),
                        ),
                        const Icon(LucideIcons.calendar, color: AppColors.primaryBlue, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ==========================================
                // INPUT CATATAN / DETAIL TUGAS
                // ==========================================
                Text(
                  'Catatan Tambahan (Opsional)',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  style: GoogleFonts.plusJakartaSans(fontSize: 15, color: AppColors.textDark, fontWeight: FontWeight.w500),
                  decoration: _buildInputDecoration('Masukkan detail instruksi tugas, tautan pengumpulan, dsb...'),
                ),
                const SizedBox(height: 32),

                // ==========================================
                // TOMBOL SAVE TUGAS
                // ==========================================
                ElevatedButton(
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Simpan Tugas Kuliah',
                    style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper dekorasi input field yang bersih dan konsisten
  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary.withValues(alpha: 0.5), fontSize: 14),
      fillColor: Colors.white,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2)),
    );
  }
}