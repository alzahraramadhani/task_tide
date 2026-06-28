class CategoryModel {
  final int? id;
  final String name;
  final String colorHex;

  CategoryModel({
    this.id, 
    required this.name, 
    required this.colorHex
  });

  // Mengubah objek Dart menjadi Map untuk disimpan ke SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'color_hex': colorHex,
    };
  }

  // Mengubah Map dari SQLite menjadi objek Dart
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      colorHex: map['color_hex'] as String,
    );
  }
}