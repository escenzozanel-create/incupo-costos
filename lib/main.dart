import 'package:flutter/material.dart';

void main() => runApp(const IncupoApp());

/// Entrada mínima. El asistente se construirá sobre el motor validado.
class IncupoApp extends StatelessWidget {
  const IncupoApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'INCUPO Costos',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF246444)),
      useMaterial3: true,
    ),
    home: Scaffold(
      appBar: AppBar(title: const Text('INCUPO Costos')),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Calculá los costos de tu producto y obtené un precio de venta orientativo.',
            style: TextStyle(fontSize: 22),
          ),
        ),
      ),
    ),
  );
}
