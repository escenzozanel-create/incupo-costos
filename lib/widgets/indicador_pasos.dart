import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class IndicadorPasos extends StatelessWidget {
  const IndicadorPasos({super.key, required this.paso, required this.titulo});
  final int paso;
  final String titulo;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(Espacios.pagina, 8, Espacios.pagina, 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            'Paso $paso de 5 · $titulo',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: paso / 5,
          semanticsLabel: 'Progreso del cálculo. Paso $paso de 5',
        ),
      ],
    ),
  );
}
