class ActivityTypeModel {
  final int? id;
  final String name;

  ActivityTypeModel({
    this.id,
    required this.name,
  });

  //konversi ke map untuk disimpan ke SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
    };
  }

  //konversi dari map SQLite ke objek Dart
  factory ActivityTypeModel.fromMap(Map<String, dynamic> map) {
    return ActivityTypeModel(
      id: map['id'] as int?,
      name: map['name'] as String,
    );
  }
}