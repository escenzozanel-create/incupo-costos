# Imágenes institucionales

- `incupo_logo.png`: logo completo de la pantalla inicial y del PDF.
- `fundacion_incupo.png`: logo de Fundación INCUPO en el inicio y el encabezado del PDF.
- `escuela_comercio.png`: logo de la Escuela Superior de Comercio N°43 en el inicio y el pie del PDF.

Se admite `escuela_comercio.webp` como alternativa si no está el PNG.
Al copiar o reemplazar imágenes, volver a compilar la aplicación.
Si falta un logo, la aplicación muestra el nombre de la institución y el PDF
conserva su identificación textual.

Los íconos Android se generan desde `incupo_logo.png` con
`tools/generar_iconos_android.ps1`. Ejecutar ese script después de cambiar el
logo y volver a compilar el APK para actualizar los recursos del launcher.
