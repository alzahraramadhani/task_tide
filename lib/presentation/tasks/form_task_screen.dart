import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/colors.dart';
import '../../data/models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../providers/category_provider.dart';
import 'widgets/inline_category_dialog.dart';

class FormTaskScreen extends StatefulWidget {
  final TaskModel? task; 

  const FormTaskScreen({super.key, this.task});

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

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      _titleController.text = widget.task!.title;
      _notesController.text = widget.task!.notes ?? '';
      _selectedCategoryId = widget.task!.categoryId;
      _selectedDifficulty = widget.task!.priorityLevel;
      _selectedDateTime = widget.task!.deadline;
    }

    // Memastikan data kategori terbaru dimuat dari SQLite saat form dibuka
    Future.delayed(Duration.zero, () {
      if (!mounted) return;
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

  // Dialog Konfirmasi Protektif Hapus Kategori langsung dari Dropdown Menu
  void _showDeleteCategoryDialog(BuildContext context, int categoryId, String categoryName) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Category',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete the category "$categoryName"? A category can only be deleted if it does not have any active tasks within it.',
          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              final navigator = Navigator.of(context); // Tutup dialog konfirmasi utama
              final messenger = ScaffoldMessenger.of(context);
              final taskProvider = context.read<TaskProvider>();
              final categoryProvider = context.read<CategoryProvider>();
              
              // Eksekusi fungsi proteksi hapus kategori
              final success = await categoryProvider.deleteCategory(categoryId);
              
              if (mounted) {
                if (success) {
                  // Jika sukses dihapus dan kategori yang dihapus sedang terpilih, reset field dropdown
                  if (_selectedCategoryId == categoryId) {
                    setState(() {
                      _selectedCategoryId = null;
                    });
                  }
                  await taskProvider.fetchTasks(); // Sinkronisasi ulang state tugas
                  messenger.showSnackBar(
                    SnackBar(content: Text('Category "$categoryName" deleted successfully.')),
                  );
                } else {
                  // Munculkan dialog peringatan jika terdapat relasi tugas aktif
                  showDialog(
                    context: navigator.context,
                    builder: (errContext) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: Text(
                        'Failed to Delete Category', 
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.red.shade700),
                      ),
                      content: Text(
                        'This category cannot be deleted because it is still associated with several active college task lists.',
                        style: GoogleFonts.plusJakartaSans(fontSize: 14),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(errContext),
                          child: Text('Understood', style: GoogleFonts.plusJakartaSans(color: AppColors.primaryBlue)),
                        )
                      ],
                    ),
                  );
                }
              }
            },
            child: Text('Delete', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Task' : 'New Task',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
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
                  'Task Title / Course Name',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textDark, fontWeight: FontWeight.w600),
                  decoration: _buildInputDecoration('Example: Database'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Task title cannot be empty' : null,
                ),
                const SizedBox(height: 10),

                // ==========================================
                // SELEKTOR KATEGORI DINAMIS + INLINE TRIGGER
                // ==========================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Task Category',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 14),
                    ),
                    TextButton.icon(
                      onPressed: _openInlineCategoryDialog,
                      icon: const Icon(LucideIcons.plus, size: 16, color: AppColors.primaryBlue),
                      label: Text(
                        'New Category',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                DropdownButtonFormField<int>(
                  initialValue: _selectedCategoryId, // Menggunakan parameter properti 'value' yang tepat untuk form dinamis
                  items: categoryProvider.categories.map((category) {
                    return DropdownMenuItem<int>(
                      value: category.id,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            category.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14, 
                              color: AppColors.textDark, 
                              fontWeight: FontWeight.w600
                            ),
                          ),
                          // Ikon Tempat Sampah untuk Menghapus Kategori Langsung dari Dropdown Item
                          IconButton(
                            icon: Icon(LucideIcons.trash2, size: 18, color: Colors.red.shade600),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              // Menutup dropdown menu terlebih dahulu sebelum memicu dialog konfirmasi
                              Navigator.pop(context);
                              _showDeleteCategoryDialog(context, category.id!, category.name);
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                  style: GoogleFonts.plusJakartaSans(
                              fontSize: 14, 
                              color: AppColors.textDark, 
                              fontWeight: FontWeight.w500
                            ),
                  decoration: _buildInputDecoration('Select category...'),
                  // Menambahkan kustomisasi tampilan item terpilih agar ikon tempat sampah tidak ikut muncul di field utama dropdown
                  selectedItemBuilder: (BuildContext context) {
                    return categoryProvider.categories.map<Widget>((category) {
                      return Text(
                        category.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15, 
                          color: AppColors.textDark, 
                          fontWeight: FontWeight.w500
                        ),
                      );
                    }).toList();
                  },
                ),
                const SizedBox(height: 20),

                // ==========================================
                // SELEKTOR DIFFICULTY LEVEL (LOW, MEDIUM, HIGH)
                // ==========================================
                Text(
                  'Difficulty Level',
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
                  'Submission Deadline',
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
                              ? 'Select date & time...'
                              : DateFormat('EEEE, dd MMMM yyyy - HH:mm', 'id').format(_selectedDateTime!),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
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
                  'Additional Notes (Optional)',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textDark, fontWeight: FontWeight.w600),
                  decoration: _buildInputDecoration('Enter task instructions, submission links, etc...'),
                ),
                const SizedBox(height: 32),

                // ==========================================
                // TOMBOL SAVE TUGAS
                // ==========================================
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (_selectedCategoryId == null || _selectedDateTime == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill all required fields!')),
                        );
                        return;
                      }

                      final navigator = Navigator.of(context);

                      // Buat object TaskModel baru / update
                      final taskData = TaskModel(
                        id: widget.task?.id, // Kirim ID lama jika Edit, null jika Tambah
                        title: _titleController.text,
                        categoryId: _selectedCategoryId!,
                        priorityLevel: _selectedDifficulty,
                        deadline: _selectedDateTime!,
                        notes: _notesController.text.isEmpty ? null : _notesController.text,
                        isCompleted: widget.task?.isCompleted ?? false, // Pertahankan status ceklis
                      );

                      final taskProvider = context.read<TaskProvider>();

                      if (_isEditing) {
                        // Jalankan fungsi update jika mode edit
                        await taskProvider.updateTask(taskData);
                      } else {
                        // Jalankan fungsi add jika mode tambah
                        await taskProvider.addTask(taskData);
                      }
                      
                      navigator.pop(); // Kembali ke halaman sebelumnya setelah berhasil menyimpan
                    }
                  },
                  
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(
                    _isEditing ? 'Update Task' : 'Save Task',
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