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

    if (temporaryList.isNotEmpty) {
      final now = DateTime.now();

      // Jalankan proses update algoritma skor prioritas di dalam loop
      for (int i = 0; i < temporaryList.length; i++) {
        final task = temporaryList[i];
        int baseScore = 0;

        // Atur bobot dasar sesuai tingkat kesulitan teks murni
        if (task.priorityLevel == 'High') {
          baseScore = 3000;
        } else if (task.priorityLevel == 'Medium') {
          baseScore = 2000;
        } else {
          baseScore = 1000;
        }

        // Hitung sisa tenggat waktu dalam satuan menit
        final minutesRemaining = task.deadline.difference(now).inMinutes;
        int timeUrgencyScore = 0;

        if (minutesRemaining > 0) {
          // Semakin sedikit sisa menit, pembagian menghasilkan nilai pengali skor yang semakin besar
          timeUrgencyScore = (999999 / minutesRemaining).round();
        } else {
          // Jika sudah melewati deadline, berikan bonus skor penalti keterlambatan tetap
          timeUrgencyScore = 5000;
        }

        final finalPriorityScore = baseScore + timeUrgencyScore;

        // Eksekusi pembaruan baris data di SQLite secara berkala
        await db.update(
          'tasks',
          {'priority_score': finalPriorityScore},
          where: 'id = ?',
          whereArgs: [task.id],
        );

        // PENTING: db.query ulang dan notifyListeners() TELAH DIHAPUS dari dalam loop ini
        // agar tidak terjadi infinite rebuild/spam proses I/O database yang membuat card delay.
      }
    }

    // [DIPINDAH KE SINI] Ambil ulang data secara kolektif HANYA SEKALI setelah seluruh proses loop selesai
    final List<Map<String, dynamic>> updatedMaps = await db.query(
      'tasks',
      orderBy: 'is_completed ASC, priority_score DESC',
    );

    _tasks = updatedMaps.map((map) => TaskModel.fromMap(map)).toList();
    _isLoading = false;

    // [DIPINDAH KE SINI] Cukup panggil notifyListeners() SEKALI saja di bagian paling akhir
    notifyListeners();
  }

  // 2. Tambah Tugas Baru
  Future<void> addTask(TaskModel task) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('tasks', task.toMap());
    await fetchTasks(); // Refresh daftar tugas untuk sinkronisasi otomatis
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
    await fetchTasks(); // Refresh daftar tugas untuk sinkronisasi otomatis
  }

  // 4. Sinkronisasi kompatibilitas pemicu fungsi dari Codingan 1 / Dashboard Lama
  void toggleTaskStatus(int taskId, bool isCompleted) {
    toggleTaskCompletion(taskId, isCompleted);
  }

  // 5. Hapus Tugas
  Future<void> deleteTask(int taskId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [taskId],
    );
    await fetchTasks(); // Refresh daftar tugas untuk sinkronisasi otomatis
  }

  // 6. Perbarui Tugas (Update Task)
  Future<void> updateTask(TaskModel task) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
    await fetchTasks(); // Refresh daftar agar UI otomatis terupdate
  }
}