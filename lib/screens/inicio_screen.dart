import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/logo_institucional.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key, required this.iniciar});
  final VoidCallback iniciar;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Calculadora de Costos')),
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
                  alto: 80,
                ),
                const SizedBox(height: 8),
                const LogoInstitucional(
                  archivo: 'assets/images/fundacion_incupo.png',
                  nombre: 'Fundación INCUPO',
                  alto: 72,
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 24),
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
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                const LogoInstitucional(
                  archivo: 'assets/images/escuela_comercio.png',
                  alternativo: 'assets/images/escuela_comercio.webp',
                  nombre: 'Escuela Superior de Comercio N°43',
                  alto: 64,
                ),
                const SizedBox(height: 8),
                Text(
                  'Escuela Superior de Comercio N°43',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Desarrollado por alumnos de 3er año Tec. Sup. en Desarrollo de Software-2026',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
