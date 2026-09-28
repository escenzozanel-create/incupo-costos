import 'package:flutter/material.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key, required this.iniciar});
  final VoidCallback iniciar;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('INCUPO Costos')),
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.calculate_outlined, size: 64),
              const SizedBox(height: 24),
              Text(
                'Tus costos, más claros',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              const Text(
                'Calculá los costos de tu producto y obtené un precio de venta orientativo en pocos pasos.',
              ),
              const SizedBox(height: 16),
              const Text(
                'No necesitás registrarte y tus cálculos se realizan en este dispositivo.',
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: iniciar,
                child: const Text('Iniciar cálculo'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
