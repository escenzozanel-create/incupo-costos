import 'package:flutter/material.dart';

class PasoLayout extends StatelessWidget {
  const PasoLayout({
    super.key,
    required this.paso,
    required this.titulo,
    required this.children,
    required this.atras,
    this.continuar,
    this.textoContinuar = 'Continuar',
  });
  final int paso;
  final String titulo;
  final List<Widget> children;
  final VoidCallback atras;
  final VoidCallback? continuar;
  final String textoContinuar;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('INCUPO Costos'),
      automaticallyImplyLeading: false,
    ),
    body: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paso $paso de 5 · $titulo',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: paso / 5,
                  semanticsLabel: 'Paso $paso de 5',
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              key: ValueKey('contenido-$paso'),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final child in children)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: child,
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: atras,
                    child: const Text('Atrás'),
                  ),
                ),
                if (continuar != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: continuar,
                      child: Text(textoContinuar),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
