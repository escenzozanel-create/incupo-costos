import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'indicador_pasos.dart';

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

  Widget _contenido() => Padding(
    padding: const EdgeInsets.all(Espacios.pagina),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final child in children)
          Padding(
            padding: const EdgeInsets.only(bottom: Espacios.amplio),
            child: child,
          ),
      ],
    ),
  );

  Widget _acciones(BuildContext context) {
    final atrasBoton = OutlinedButton(
      onPressed: atras,
      child: const Text('Atrás'),
    );
    final siguiente = continuar == null
        ? null
        : FilledButton(
            onPressed: continuar,
            child: Text(textoContinuar, textAlign: TextAlign.center),
          );
    final apilados =
        MediaQuery.sizeOf(context).width < 362 &&
        MediaQuery.textScalerOf(context).scale(16) > 20;
    return Padding(
      padding: const EdgeInsets.all(Espacios.medio),
      child: apilados
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [?siguiente, const SizedBox(height: 8), atrasBoton],
            )
          : Row(
              children: [
                Expanded(child: atrasBoton),
                if (siguiente != null) ...[
                  const SizedBox(width: 12),
                  Expanded(child: siguiente),
                ],
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('INCUPO Costos'),
      automaticallyImplyLeading: false,
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Espacios.maxContenido),
          // La estructura permanece estable al abrir el teclado: no se recrea
          // el TextField enfocado. También se pueden desplazar los botones.
          child: Column(
            children: [
              IndicadorPasos(paso: paso, titulo: titulo),
              Expanded(
                child: SingleChildScrollView(
                  key: ValueKey('contenido-$paso'),
                  primary: false,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [_contenido(), _acciones(context)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
