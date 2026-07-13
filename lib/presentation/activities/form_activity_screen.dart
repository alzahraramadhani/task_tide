import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/colors.dart'; // Patuh pada pondasi warna global
import '../../data/models/activity_model.dart';
import '../../providers/activity_provider.dart';
import 'widgets/inline_type_dialog.dart';

class FormActivityScreen extends StatefulWidget {
  final ActivityModel? activity;

  const FormActivityScreen({super.key, this.activity});

  @override
  State<FormActivityScreen> createState() => _FormActivityScreenState();
}

class _FormActivityScreenState extends State<FormActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  int? _selectedTypeId;
  DateTime? _selectedDate;

  bool get _isEditing => widget.activity != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      _nameController.text = widget.activity!.name;
      _notesController.text = widget.activity!.notes ?? '';
      _selectedTypeId = widget.activity!.activityTypeId;
      _selectedDate = widget.activity!.activityDate;
    }

    // Memastikan data tipe aktivitas termuat langsung dari SQLite saat form dibuka
    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      context.read<ActivityProvider>().fetchActivityTypes();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Fungsi picker tanggal pelaksanaan agenda
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)), // Izinkan catat agenda sebulan lalu
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primaryBlue),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Fungsi memicu modal dialog pembuatan tipe kustom inline
  void _openInlineTypeDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const InlineTypeDialog(),
    );

    // Jika sukses menambahkan tipe baru, refresh dropdown tipe data
    if (result == true) {
      if (!mounted) return;
      await context.read<ActivityProvider>().fetchActivityTypes();
    }
  }


  @override
  Widget build(BuildContext context) {
    final activityProvider = context.watch<ActivityProvider>();

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
          _isEditing ? 'Edit Activity' : 'New Activity',      
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
                // INPUT NAMA AGENDA / KEGIATAN
                // ==========================================
                Text(
                  'Name of Activity',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: _buildInputDecoration('Example: UI/UX Workshop'),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Activity name is required' : null,
                ),
                const SizedBox(height: 10),

                // ==========================================
                // DROPDOWN TIPE AGENDA + INLINE BUTTON TRIGGER
                // ==========================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Activity Type',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                        fontSize: 14,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _openInlineTypeDialog,
                      icon: const Icon(LucideIcons.plus, size: 16, color: AppColors.primaryBlue),
                      label: Text(
                        'New Type',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                DropdownButtonFormField<int>(
                  initialValue: _selectedTypeId,
                  items: activityProvider.activityTypes.map((type) {
                    return DropdownMenuItem<int>(
                      value: type.id,
                      child: Text(
                        type.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTypeId = value;
                    });
                  },
                  decoration: _buildInputDecoration('Select an activity type...'),
                ),
                const SizedBox(height: 20),

                // ==========================================
                // SELEKTOR TANGGAL KEGIATAN
                // ==========================================
                Text(
                  'Activity Date',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickDate,
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
                          _selectedDate == null
                              ? 'Select activity date...'
                              : DateFormat('EEEE, dd MMMM yyyy', 'id').format(_selectedDate!),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: _selectedDate == null
                                ? AppColors.textSecondary.withValues(alpha: 0.6)
                                : AppColors.textDark,
                          ),
                        ),
                        const Icon(LucideIcons.calendarDays, color: AppColors.primaryBlue, size: 20), // Konsisten menggunakan rumpun Lucide kategorial calendar
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ==========================================
                // INPUT CATATAN / DESKRIPSI AGENDA
                // ==========================================
                Text(
                  'Notes (Optional)',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: _buildInputDecoration('Enter exam room, quiz material, required materials...'),
                ),
                const SizedBox(height: 32),

                // ==========================================
                // ACTION BUTTON SIMPAN
                // ==========================================
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (_selectedTypeId == null || _selectedDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill all required fields!')),
                        );
                        return;
                      }

                      final navigator = Navigator.of(context);

                      // Susun objek ActivityModel
                      final activityData = ActivityModel(
                        id: widget.activity?.id, // Bernilai ID lama jika Edit, null jika Tambah
                        name: _nameController.text,
                        activityTypeId: _selectedTypeId!,
                        activityDate: _selectedDate!,
                        notes: _notesController.text.isEmpty ? null : _notesController.text,
                        isCompleted: widget.activity?.isCompleted ?? false, // Pertahankan status checklist sebelumnya
                      );

                      final activityProvider = context.read<ActivityProvider>();

                      if (_isEditing) {
                        // Jika mode edit, jalankan update
                        await activityProvider.updateActivity(activityData);
                      } else {
                        // Jika mode tambah, jalankan insert/add
                        await activityProvider.addActivity(activityData);
                      }

                      // if (mounted) {
                        
                        navigator.pop(); // Kembali ke halaman sebelumnya setelah berhasil menyimpan
                      // }  
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
                    _isEditing ? 'Update Activity' : 'Save Activity',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Pembentuk dekorasi kolom input seragam
  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.plusJakartaSans(
        color: AppColors.textSecondary.withValues(alpha: 0.5),
        fontSize: 14,
      ),
      fillColor: Colors.white,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
      ),
    );
  }
}