class TaskModel {
  final int? id;
  final String title;
  final int categoryId;
  final String priorityLevel;
  final double priorityScore;
  final DateTime deadline;
  final String? notes;
  final bool isCompleted;

  TaskModel({
    this.id,
    required this.title,
    required this.categoryId,
    required this.priorityLevel,
    this.priorityScore = 0.0,
    required this.deadline,
    this.notes,
    this.isCompleted = false,
  });



  // 🚀 ENGINE UTAMA: AUTO-CALCULATED PRIORITY ALGORITHM
  static double calculatePriorityScore({
    required String priorityLevel,
    required DateTime deadline,
  }) {
    final now = DateTime.now();
    // Hitung selisih waktu dalam satuan Menit
    final int remainingMinutes = deadline.difference(now).inMinutes;

    // 1. Penanganan Edge Case: Jika tugas sudah telat/jatuh tempo
    if (remainingMinutes <= 0) {
      return 9999.0; // Skor absolut tertinggi agar melesat ke atas UI
    }

    // 2. Konversi Nilai Bobot Tugas (Mapping String ke Angka)
    int weightValue = 1; // Default 'Low'
    if (priorityLevel == 'High') {
      weightValue = 3;
    } else if (priorityLevel == 'Medium') {
      weightValue = 2;
    }

    // 3. Batas Minimum (Floor Limit): Jika kurang dari 1 jam (1-59 menit), kunci di 60 menit
    int adjustedMinutes = remainingMinutes;
    if (remainingMinutes >= 1 && remainingMinutes < 60) {
      adjustedMinutes = 60;
    }

    // 4. Standarisasi Rumus Sesuai PRD
    return (weightValue * 10000) / adjustedMinutes;
  }  


  // Mengubah objek Dart menjadi Map untuk disimpan ke SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'category_id': categoryId,
      'difficulty_level': priorityLevel,
      // Otomatis menghitung ulang skor terbaru saat akan disimpan ke DB
      'priority_score': calculatePriorityScore(priorityLevel: priorityLevel, deadline: deadline),
      'deadline': deadline.toIso8601String(),
      'notes': notes,
      'is_completed': isCompleted ? 1 : 0, // SQLite tidak memiliki tipe boolean
    };
  }

  // Mengubah Map dari SQLite menjadi objek Dart
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      categoryId: map['category_id'] as int,
      priorityLevel: map['difficulty_level'] as String,
      priorityScore: (map['priority_score'] as num).toDouble(),
      deadline: DateTime.parse(map['deadline'] as String),
      notes: map['notes'] as String?,
      isCompleted: map['is_completed'] as int == 1, 
    );
  }
}