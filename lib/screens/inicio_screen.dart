import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/logo_institucional.dart';
import 'informacion_screen.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key, required this.iniciar});
  final VoidCallback iniciar;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Calculadora de Costos'),
      actions: [
        IconButton(
          tooltip: 'Información institucional',
          icon: const Icon(Icons.info_outline),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const InformacionScreen()),
          ),
        ),
      ],
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Espacios.maxContenido),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Espacios.amplio),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const LogoInstitucional(
                  archivo: 'assets/images/incupo_logo.png',
                  nombre: 'INCUPO',
                  alto: 150,
                ),
                const SizedBox(height: 28),
                Text(
                  'Calculadora de Costos',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'Calculadora de costos para emprendedores',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Conocé cuánto cuesta producir y obtené un precio de venta orientativo.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: iniciar,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Iniciar cálculo'),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Sin registro. Tus cálculos se realizan en este dispositivo.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
