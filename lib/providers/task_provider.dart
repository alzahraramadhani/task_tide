import 'package:flutter/material.dart';
import 'package:task_tide/data/database/database_helper.dart';
import 'package:task_tide/data/models/task_model.dart';

class TaskProvider with ChangeNotifier {
  List<TaskModel> _tasks = [];
  bool _isLoading = false;

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;

  // Mengambil tugas yang belum selesai untuk alur Today's Focus di Dashboard
  List<TaskModel> get activeTasks =>
    _tasks.where((task) => !task.isCompleted).toList();

  // Hitung persentase kemajuan belajar mingguan (Weekly Progress Bar)
  double get weeklyProgress {
    if (_tasks.isEmpty) return 0.0;

    final completedCount = _tasks.where((task) => task.isCompleted).length;
    return completedCount / _tasks.length;
  }

  // 1. Ambil Data & Urutkan Menggunakan Algoritma Prioritas Otomatis (PRD Spec)
  Future<void> fetchTasks() async {
    _isLoading = true;
    notifyListeners();

    final db = await DatabaseHelper.instance.database;

    // Tarik seluruh data dari tabel tasks
    final List<Map<String, dynamic>> maps = await db.query('tasks');

    List<TaskModel> temporaryList = maps.map((map) => TaskModel.fromMap(map)).toList();

    // Jalankan sistem kalkulasi ulang skor dinamis secara realtime sebelum diurutkan
    for (var i = 0; i < temporaryList.length; i++) {
      if (temporaryList[i].isCompleted) {
        // Hitung ulang skor terbaru berdasarkan waktu detik ini
        double newScore = TaskModel.calculatePriorityScore(
          priorityLevel: temporaryList[i].priorityLevel,
          deadline: temporaryList[i].deadline,
        );

        // Update nilai skor terbaru ke database lokal (Hidden Background Process)
        await db.update(
          'tasks',
          {'priority_score': newScore},
          where: 'id = ?',
          whereArgs: [temporaryList[i].id],
        );

        // Ambil ulang data yang sudah di-update skornya, lalu urutkan dari SKOR TERTINGGI (Desc)
        final List<Map<String, dynamic>> updatedMaps = await db.query(
            'tasks',
            orderBy: 'is_completed ASC, priority_score DESC',
          );

          _tasks = updatedMaps.map((map) => TaskModel.fromMap(map)).toList();
          _isLoading = false;
          notifyListeners();
      }
    }
  }

  // 2. Tambah Tugas Baru
  Future<void> addTask(TaskModel task) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('tasks', task.toMap());
    await fetchTasks(); // Refresh the task list
  }

  // 3. Mengubah Status Ceklis Tugas (is_completed) via Checkbox UI
  Future<void> toggleTaskCompletion(int taskId, bool currentStatus) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'tasks',
      {'is_completed': currentStatus ? 0 : 1},
      where: 'id = ?',
      whereArgs: [taskId],
    );
    await fetchTasks(); // Refresh the task list
  }

  // 4. Hapus Tugas
  Future<void> deleteTask(int taskId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [taskId],
    );
    await fetchTasks(); // Refresh the task list
  }

  void toggleTaskStatus(int i, bool isCompleted) {}

}