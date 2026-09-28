import 'package:flutter/material.dart';

import 'screens/asistente_screen.dart';

void main() => runApp(const IncupoApp());

/// El estado del asistente vive únicamente durante esta sesión.
class IncupoApp extends StatelessWidget {
  const IncupoApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'INCUPO Costos',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF246444)),
      useMaterial3: true,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        errorMaxLines: 4,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: const Size(0, 52)),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
    ),
    home: const AsistenteScreen(),
  );
}
