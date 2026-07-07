import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart'; 
import 'package:task_tide/presentation/onboarding/onboarding_screen.dart';
import 'package:task_tide/presentation/main_navigation.dart';
import 'package:task_tide/providers/activity_provider.dart';
import 'package:task_tide/providers/app_state_provider.dart';
import 'package:task_tide/providers/category_provider.dart';
import 'package:task_tide/providers/task_provider.dart';

// 2. Ubah fungsi main menjadi async
void main() async {
  // 3. Pastikan binding Flutter sudah diinisialisasi sebelum menjalankan fungsi async lain
  WidgetsFlutterBinding.ensureInitialized();

  // 4. Inisialisasi data lokal untuk format bahasa Indonesia ('id')
  await initializeDateFormatting('id', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskTide',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}