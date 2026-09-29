import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key, required this.iniciar});
  final VoidCallback iniciar;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('INCUPO Costos')),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Espacios.maxContenido),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Espacios.amplio),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.calculate_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Tus costos,\nmás claros.',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'Calculadora de costos para emprendedores',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Conocé cuánto cuesta producir y obtené un precio de venta orientativo.',
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
