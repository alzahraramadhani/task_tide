import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart'; 
import 'package:task_tide/presentation/onboarding/onboarding_screen.dart';
import 'package:task_tide/presentation/main_navigation.dart';
import 'package:task_tide/providers/activity_provider.dart';
import 'package:task_tide/providers/app_state_provider.dart';
import 'package:task_tide/providers/category_provider.dart';
import 'package:task_tide/providers/task_provider.dart';

void main() async {
  // 1. Pastikan binding Flutter sudah diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi data lokal untuk format bahasa Indonesia ('id')
  await initializeDateFormatting('id', null);

  // 3. Buat instance AppStateProvider dan baca SharedPreferences SEBELUM runApp
  final appStateProvider = AppStateProvider();
  await appStateProvider.checkOnboardingStatus();

  runApp(
    MultiProvider(
      providers: [
        // Menggunakan .value karena instance appStateProvider sudah dibuat dan di-load di atas
        ChangeNotifierProvider.value(value: appStateProvider),
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
    // 4. Baca status isFirstTimeUser langsung dari provider yang sudah siap data-nya
    final isFirstTime = context.read<AppStateProvider>().isFirstTimeUser;

    return MaterialApp(
      title: 'TaskTide',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      // Kondisi A & B: Tentukan halaman utama secara dinamis berdasarkan data penyimpanan lokal
      home: isFirstTime ? const OnboardingScreen() : const MainNavigation(),
    );
  }
}