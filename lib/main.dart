import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_tide/presentation/dashboard/dashboard_screen.dart';
import 'package:task_tide/providers/activity_provider.dart';
import 'package:task_tide/providers/app_state_provider.dart';
import 'package:task_tide/providers/category_provider.dart';
import 'package:task_tide/providers/task_provider.dart';

void main() {
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

      home: const DashboardScreen(),
    );
  }
}