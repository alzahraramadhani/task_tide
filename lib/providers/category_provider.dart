import 'package:flutter/material.dart';
import 'package:task_tide/data/database/database_helper.dart';
import 'package:task_tide/data/models/category_model.dart';

class CategoryProvider with ChangeNotifier {
  // Add your category provider implementation here
  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;

  //1. ambil smua kategori dari database
  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();

    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('categories');

    _categories = maps.map((map) => CategoryModel.fromMap(map)).toList();
    _isLoading = false;
    notifyListeners();
  }

  //2. tambah kategori baru (inline popup support)
  Future<int> addCategory(CategoryModel category) async {
    final db = await DatabaseHelper.instance.database;
    final id = await db.insert('categories', category.toMap());

    //refresh daftar lokal agar ui terupdate reaktif
    await fetchCategories();
    return id;
  }

  //3. proteksi hapus kategori
  Future<bool> deleteCategory(int categoryId) async {
    final db = await DatabaseHelper.instance.database;
    
    // Cek apakah masih ada tugas aktif yang menggunakan kategori ini
    final List<Map<String, dynamic>> activeTasks = await db.query(
      'tasks',
      where: 'category_id = ? AND is_completed = 0',
      whereArgs: [categoryId],
    );

    // Jika ada tugas aktif, batalkan penghapusan dan kembalikan nilai false ke UI
    if (activeTasks.isNotEmpty) {
      return false; // Indikasi bahwa penghapusan tidak berhasil karena ada tugas aktif
    }

    // Jika aman, lakukan eksekusi hapus murni
    await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [categoryId],
    );
    await fetchCategories(); // Refresh daftar lokal agar UI terupdate reaktif
    return true; // Indikasi bahwa penghapusan berhasil
  }
}