import 'package:flutter/material.dart';
import 'package:task_tide/data/database/database_helper.dart';
import 'package:task_tide/data/models/activity_model.dart';
import 'package:task_tide/data/models/activity_type_model.dart';

class ActivityProvider with ChangeNotifier {
  List<ActivityModel> _activities = [];
  List<ActivityTypeModel> _activityTypes = [];
  bool _isLoading = false;

  List<ActivityModel> get activities => _activities;
  List<ActivityTypeModel> get activityTypes => _activityTypes;
  bool get isLoading => _isLoading;

 // 1. Ambil Semua Tipe Aktivitas Kustom (Untuk Dropdown Form Input)
  Future<void> fetchActivityTypes() async {
    final db = await DatabaseHelper.instance.database;
    // Tarik seluruh data dari tabel activity_types
    final List<Map<String, dynamic>> maps = await db.query('activity_types');

    _activityTypes = maps.map((map) => ActivityTypeModel.fromMap(map)).toList();
    notifyListeners();
  }

  // 2. Tambah Tipe Aktivitas Baru via Pop-Up Dialog Inline
  Future<int> addActivityType(ActivityTypeModel type) async {
    final db = await DatabaseHelper.instance.database;
    final id = await db.insert('activity_types', type.toMap());
    
    await fetchActivityTypes(); // Sinkronisasi otomatis daftar tipe lokal
    return id;
  }

  // 3. Ambil Semua Aktivitas Mendatang Menggunakan SQL JOIN
  Future<void> fetchActivities() async {
    _isLoading = true;
    notifyListeners();

    final db = await DatabaseHelper.instance.database;
    
    // Query JOIN untuk mengambil nama tipe dari tabel activity_types secara simultan
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT activities.*, activity_types.name AS type_name 
      FROM activities
      INNER JOIN activity_types ON activities.activity_type_id = activity_types.id
      ORDER BY activities.is_completed ASC, activities.activity_date ASC
    ''');

    _activities = maps.map((map) => ActivityModel.fromMap(map)).toList();
    _isLoading = false;
    notifyListeners();
  }

  // 4. Tambah Aktivitas Agenda Baru
  Future<void> addActivity(ActivityModel activity) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('activities', activity.toMap());
    await fetchActivities();
  }

  // 5. Mengubah Status Penyelesaian Aktivitas (is_completed)
  Future<void> toggleActivityStatus(int activityId, bool currentStatus) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'activities',
      {'is_completed': currentStatus ? 0 : 1},
      where: 'id = ?',
      whereArgs: [activityId],
    );
    await fetchActivities();
  }

  // 6. Hapus Aktivitas
  Future<void> deleteActivity(int activityId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('activities', where: 'id = ?', whereArgs: [activityId]);
    await fetchActivities();
  }

  // 7. Update Aktivitas (Misalnya untuk mengubah nama, tanggal, atau tipe)
  Future<void> updateActivity(ActivityModel activity) async {
  final db = await DatabaseHelper.instance.database;
  await db.update(
    'activities',
    activity.toMap(),
    where: 'id = ?',
    whereArgs: [activity.id],
  );
  await fetchActivities(); // Refresh daftar aktivitas agar UI otomatis terupdate
}
}