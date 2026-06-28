class ActivityModel {
  final int? id;
  final String name;
  final int activityTypeId;
  final String? typeName; // Helper untuk menampilkan nama tipe di UI
  final DateTime activityDate;
  final String? notes;
  final bool isCompleted;

  ActivityModel({
    this.id,
    required this.name,
    required this.activityTypeId,
    this.typeName,
    required this.activityDate,
    this.notes,
    this.isCompleted = false,
  });


  // Mengubah objek Dart menjadi Map untuk disimpan ke SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'activity_type_id': activityTypeId,
      'activityDate': activityDate.toIso8601String(),
      'notes': notes,
      'is_completed': isCompleted ? 1 : 0, // Konversi bool ke int (0 atau 1)
    };
  }

  // Mengubah Map dari SQLite menjadi objek Dart
  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      activityTypeId: map['activity_type_id'] as int,
      typeName: map['type_name'] as String?, // Diambil dari hasil SQL JOIN nanti
      activityDate: DateTime.parse(map['activity_date'] as String),
      notes: map['notes'] as String?,
      isCompleted: map['is_completed'] == 1,
    );
  }
}