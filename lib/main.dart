// lib/main.dart
// Punto de entrada principal - Configuración de providers y tema

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'providers/app_state.dart';
import 'providers/memory_state.dart';
import 'providers/file_system_state.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => MemoryState()),
        ChangeNotifierProvider(create: (_) => FileSystemState()),
      ],
      child: const SimuladorApp(),
    ),
  );
}

class SimuladorApp extends StatelessWidget {
  const SimuladorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simulador SO — Procesos & Archivos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}