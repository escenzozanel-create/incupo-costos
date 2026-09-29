import 'package:flutter/material.dart';

import 'screens/asistente_screen.dart';
import 'theme/app_theme.dart';

void main() => runApp(const IncupoApp());

/// El estado del asistente vive únicamente durante esta sesión.
class IncupoApp extends StatelessWidget {
  const IncupoApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'INCUPO Costos',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.claro,
    home: const AsistenteScreen(),
  );
}
