# INCUPO Costos

Calculadora de costos mensuales para emprendedores, basada en la planilla de INCUPO. App Android en Flutter, offline, sin cuentas, servidor, base de datos ni historial persistente. El cálculo puede conservarse mediante un PDF.

## Estado

**INCUPO Costos 1.0 técnicamente terminada (1.0.0+1).** APK release generada, firmada y verificada con `apksigner`, instalada y abierta independientemente en el emulador Android 16. Smoke test release aprobado: cálculo, recálculo, PDF, selector de compartir, guardado nativo, nuevo cálculo y funcionamiento offline. Android toolchain correcto, licencias aceptadas, **76 pruebas aprobadas** (71 originales + 5 de integración) y análisis sin observaciones. No quedan pendientes bloqueantes. Ver [cierre Android](docs/cierre_android.md).

Asistente funcional **Inicio → Producto → Costos variables → Costos fijos → Ganancia → Resultados → PDF**, sobre el motor matemático validado. Permite cargar, editar y eliminar gastos, volver atrás conservando el borrador, recalcular y comenzar otro cálculo con confirmación. La amortización es un costo fijo mensual manual. Incluye PDF, vista previa y acciones nativas para compartir o guardar/imprimir, además de un tema Material 3 centralizado. Validación física en teléfono real pendiente, no bloqueante para el cierre técnico.

Entorno utilizado: Flutter **3.47.5**, Dart **3.13.4**, canal stable. Dependencias resueltas en `pubspec.lock`.

## Tecnologías y características

Flutter, Dart y Android; `pdf ^3.13.1` y `printing ^5.15.1` para documentos locales.
Cálculo de costos variables y fijos, amortización manual, precio sugerido, utilidad,
proyección mensual y punto de equilibrio. PDF y funcionamiento offline, sin base de
datos, registro de usuarios ni servidor. La proyección supone vender toda la producción.

## Requisitos

- Flutter; en esta máquina se usa el SDK local.
- Dart incluido con Flutter.
- Android Studio y Android SDK con Platform, Build-Tools, Platform-Tools y Command-line Tools.
- Dispositivo Android 7/API 24 o superior o emulador; la validación física es recomendable y no bloquea el cierre técnico 1.0.

## Desarrollo

Con Flutter instalado en el PATH:

```sh
flutter pub get
flutter test
flutter analyze
flutter run
```

En esta máquina se descargó el SDK en `.local/flutter`, excluido de Git. Para usarlo sin modificar el PATH ni la política de ejecución de PowerShell:

```powershell
.\tools\flutter.cmd pub get
.\tools\flutter.cmd test
.\tools\flutter.cmd analyze
.\tools\flutter.cmd doctor -v
.\tools\flutter.cmd run
```

El lanzador usa el SDK local cuando existe y, en otros equipos, el Flutter del PATH. Su caché de paquetes también queda dentro de `.local/`. Al clonar el repositorio en otro equipo hay que instalar Flutter; el SDK no se distribuye junto al código.

La descarga inicial de herramientas y dependencias necesita internet. El motor no lo requiere al ejecutarse. Android SDK ya está configurado y `flutter doctor -v` muestra Android toolchain correcto. Está disponible el emulador `INCUPO_API_36`; no hay teléfono físico disponible. Consultar la [configuración usada y conexión USB](docs/cierre_android.md).

## Pruebas y validación

```sh
flutter test --coverage
flutter analyze
```

Las **47 pruebas originales** del motor se conservan sin modificaciones. La etapa 2 agregó **8 pruebas del controller, 3 de formato/entrada y 4 del recorrido de widgets** (62). La etapa 3 agrega **4 de generación PDF, 3 de integración/errores y 2 de disposición móvil**, para un total de **71 pruebas**. Solo se actualizó el texto del botón esperado por un recorrido a «Editar datos». El caso de pan compara los 12 resultados relevantes del Excel con tolerancia absoluta de `1e-8`, usando los valores completos, sin redondearlos previamente.

Verificación final: **71 pruebas originales y 5 de integración Android aprobadas (76 en total)** y **`flutter analyze` sin observaciones**. `flutter test` ejecuta las 71; las cinco de Android se ejecutan por separado con `flutter test integration_test/android_test.dart -d emulator-5554`.

Las pruebas del asistente usan un tamaño de teléfono de 390 × 844: carga de producto y gastos, resultados, navegación hacia atrás (también botón del sistema), cambio de costo y recálculo, cancelar/confirmar reinicio, validaciones visibles, edición y eliminación, listas vacías, unidad personalizada y porcentaje mayor a 100. Son pruebas de widgets, no una prueba física de Android.

Cobertura funcional de las pruebas:

- Variables, fijos, costo total, costos unitarios, ganancia unitaria, precio, ventas, utilidad, ganancia relativa, aporte unitario y equilibrio.
- Amortización manual de $25.000: CFT $1.172.500, CT $3.555.510 y utilidad $142.220,40.
- Conversión de 4 % a 0,04 y ganancia mayor a 100 % sin límite arbitrario.
- Listas vacías, cantidad y precio cero, ganancia cero y categoría sin gastos.
- Producción cero/negativa, costos negativos, NaN, Infinity y textos obligatorios vacíos.
- Costo total cero: porcentaje de ganancia no disponible con explicación.
- Equilibrio con denominador cero/negativo: no disponible con explicación.
- Equilibrio cero válido si no hay fijos y el aporte es positivo; equilibrio fraccionario sin redondeo.
- Desbordamiento de operaciones con entradas finitas; listas protegidas de mutaciones externas; cálculo actualizado al cambiar los datos.

La prueba del denominador negativo usa directamente la operación de equilibrio: con las entradas no negativas admitidas y el precio derivado de los costos, ese denominador no es un escenario ordinario del flujo principal. No se añadieron entradas de precio o ventas reales para forzarlo.

### Referencia del pan

1560 kg por mes; tasa 0,04; amortización cero para reproducir el original:

| Resultado | Valor completo esperado |
|---|---:|
| Variables | 2383010 |
| Fijos | 1147500 |
| Total | 3530510 |
| Variable unitario | 1527.5705128205129 |
| Total unitario | 2263.147435897436 |
| Ganancia por unidad | 90.52589743589745 |
| Precio sugerido | 2353.6733333333336 |
| Ventas | 3671730.4000000004 |
| Utilidad | 141220.40000000037 |
| Ganancia sobre costo | 0.040000000000000105 |
| Aporte por unidad | 826.1028205128207 |
| Equilibrio | 1389.0522723160118 |

El fixture está en `test/fixtures/caso_pan.dart`. El motor coincide con estos valores. No depende de leer el Excel durante la ejecución.

## Lógica y validaciones

Cada ítem calcula `cantidad × precioUnitario`. El servicio suma las dos categorías, calcula costos unitarios y agrega la ganancia sobre el costo total unitario. Estima la venta de toda la producción mensual al precio sugerido. La utilidad es ventas menos costos, la ganancia relativa es utilidad / costo total y el equilibrio es fijos / (precio − variable unitario).

La amortización se ingresa como un ítem fijo normal: concepto `Amortización de bienes`, cantidad `1` y precio igual al importe mensual. Se suma una sola vez. No hay tabla de bienes, depreciación automática ni referencia a la celda vacía I77.

Se exige nombre de producto y unidad no vacíos, producción finita mayor que cero, conceptos de ítems completos y cantidades, precios y tasa finitos no negativos. Una lista vacía es válida; un ítem sin concepto no lo es. Los campos numéricos de los modelos son obligatorios y no nullable: el futuro formulario deberá validar texto vacío antes de construirlos.

`porcentajeATasa(4)` devuelve `0.04`; el motor ya recibe la fracción y no vuelve a dividir por 100. No se redondean operaciones intermedias. El helper `formatters.dart` presenta dinero, porcentajes y cantidades con formato argentino y dos decimales, sin modificar valores internos. Los resultados matemáticamente no disponibles incluyen `null` y un motivo legible, sin NaN/Infinity. Los datos inválidos o desbordamientos del cálculo principal producen `ValidacionException`, mostrada con un mensaje comprensible junto al formulario.

Los campos numéricos aceptan coma o punto decimal **sin separador de miles**, indicado junto a cada campo. Así `1500,50` y `1500.50` representan lo mismo; `1.500` es decimal, no se interpreta silenciosamente como mil quinientos. El formato de salida sí agrupa miles.

## PDF y diseño visual

Dependencias nuevas: `pdf: ^3.13.1` y `printing: ^5.15.1`. La fuente Lato se incluye localmente con su licencia OFL en `assets/fonts`; la interfaz y el PDF no descargan fuentes durante el uso.

`PdfService.generar` recibe `CalculoCostos`, `ResultadoCalculo` y una fecha. Presenta los resultados recibidos y los totales de ítem del modelo existente, usando los mismos formateadores argentinos. No llama al motor ni incorpora fórmulas de negocio. Incluye producto, producción, ganancia esperada, fecha, tablas completas de variables y fijos, subtotales, costos unitarios, precio sugerido, ventas, utilidad, ganancia estimada y equilibrio con su explicación. La amortización aparece solamente si fue cargada. Aclara el supuesto de vender toda la producción y conserva las explicaciones para resultados no disponibles.

Desde Resultados, **Guardar o compartir PDF** toma una instantánea y la fecha actual, genera el documento y abre una vista previa. **Compartir** usa el selector del sistema; **Guardar o imprimir** abre la impresión nativa, donde Android ofrece «Guardar como PDF» según disponibilidad. No se implementa almacenamiento propio. Los errores muestran mensajes comprensibles y permiten reintentar sin perder el cálculo; los detalles quedan en el registro de desarrollo.

El tema `AppTheme.claro` centraliza Material 3, verdes, fondo claro, tipografía, campos, tarjetas y botones grandes. Se reutilizan el formulario y editor de ambas categorías, los campos numéricos, tarjetas y disposición común de pasos. Resultados destaca el precio y agrupa costos, proyección y equilibrio. Se mejoraron foco, acciones del teclado y desplazamiento; hay pruebas a 390 × 844 y a 320 × 640 con texto ampliado y teclado abierto. La identidad es tipográfica, sin inventar un logo oficial.

Las pruebas de PDF generan cuatro ejemplos locales: pan, listas vacías, equilibrio no disponible y 90 ítems con descripciones largas. Para verificar texto con dos lectores independientes y renderizar todas las páginas:

```sh
flutter test test/pdf_service_test.dart
python -m pip install pypdf pymupdf
python tools/verificar_pdf.py
```

La evidencia queda en `.local/pdf-qa/`, excluida de Git. Se revisaron importes, explicaciones, paginación y límites de texto, además del aspecto de las páginas renderizadas. Las capturas de interfaz se pueden regenerar con `flutter test test/accesibilidad_layout_test.dart --dart-define=CAPTURAR_UI=true`; quedan en `.local/ui-qa/`. Los tests de widgets simulan el canal nativo; adicionalmente las cinco pruebas de integración usan Android real en emulador, y el smoke test sobre la APK release verificó vista previa, selector de compartir y guardado nativo. La impresión en papel queda pendiente de una impresora física.

## Estado, navegación y gastos

`CalculoController` extiende `ChangeNotifier` y pertenece al asistente. Conserva en memoria los textos de producto, producción, unidad y ganancia, incluso cuando todavía están incompletos. Las listas de costos solo reciben ítems completos y válidos; su edición se valida antes de reemplazar el ítem anterior. Las listas expuestas son inmutables.

Cada cambio invalida el resultado anterior. “Ver resultados” construye `CalculoCostos`, convierte el porcentaje mediante el helper existente y llama una sola vez a `CalculadoraService`. Volver atrás no recalcula ni reinicia el borrador. Los subtotales y la vista previa del costo usan `sumarCostos`, la misma suma validada del motor que antes era privada: solo se cambió su visibilidad/nombre, sin alterar fórmulas.

El asistente administra cinco pasos y un inicio. `PopScope` devuelve al paso anterior con el botón del sistema. El editor de costos es una ruta independiente con campos desplazables, total automático, Guardar y Cancelar. Cancelar descarta únicamente la edición sin guardar. Variables y fijos comparten pantalla parametrizada, tarjetas y editor. Eliminar pide confirmación. “Nuevo cálculo” también confirma, limpia el controller y vuelve a Inicio; cancelar conserva los datos.

## Estructura actual

```text
android/                         Base nativa generada por Flutter
lib/
  main.dart                      Entrada al asistente
  theme/app_theme.dart           Tema Material 3 y espaciados
  models/
    item_costo.dart               Ítem inmutable, total derivado
    calculo_costos.dart           Producto mensual y listas inmutables
    resultado_calculo.dart       Resultados y motivos de no disponibilidad
  services/
    calculadora_service.dart     Matemática independiente de Flutter UI
    pdf_service.dart             Documento a partir de datos ya calculados
  utils/
    validators.dart              Validaciones y mensajes
    porcentajes.dart             Conversión entre porcentaje y fracción
    formatters.dart              Formato argentino y entrada numérica
  state/calculo_controller.dart  Borrador temporal y operaciones de costos
  screens/
    asistente_screen.dart        Navegación y ciclo de vida del controller
    inicio_screen.dart
    producto_screen.dart
    costos_screen.dart           Compartida por variables y fijos
    ganancia_screen.dart
    resultado_screen.dart
    pdf_screen.dart              Vista previa y acciones nativas
  widgets/
    paso_layout.dart             Progreso, contenido desplazable y botones
    indicador_pasos.dart          Paso actual y barra de progreso
    exportar_pdf_button.dart      Generación, carga y errores
    campo_numerico.dart
    item_costo_card.dart
    editor_costo.dart
test/
  calculadora_service_test.dart   Pruebas de negocio y límites
  calculo_controller_test.dart    Estado, CRUD, recálculo y limpieza
  formatters_test.dart            Formato y parseo de entradas
  asistente_test.dart             Recorridos funcionales en tamaño móvil
  pdf_service_test.dart           Cuatro documentos de prueba
  pdf_interaccion_test.dart       Canal nativo y errores recuperables
  accesibilidad_layout_test.dart Pantallas pequeñas, texto y teclado
  fixtures/caso_pan.dart          Datos del Excel
docs/
  analisis_excel.md               Análisis y decisión actualizada
  inventario_excel.md             Celdas, fórmulas y valores originales
  auditoria_excel.json            Evidencia estructurada
  cierre_android.md               Firma, APK release y smoke test final
integration_test/android_test.dart Recorridos y PDF nativo en Android
tools/
  analizar_excel.py              Auditoría de solo lectura del XLSX
  flutter.cmd                    Lanzador para Windows
  verificar_pdf.py                Verificación de contenido y render PDF
assets/fonts/                    Lato local, procedencia y licencia OFL
```

El original `NUEVA PLANILLA DE COSTOS  PAN ultimo (1).xlsx` permanece en la raíz, intacto y versionado. El análisis detallado está en [docs/analisis_excel.md](docs/analisis_excel.md).

## Git

Repositorio en la rama `main`, con remoto `origin` configurado. `.gitignore` excluye SDK, cachés, builds, configuración local, claves, APK y AAB. `pubspec.lock`, fuentes, documentación y Excel se conservan. Los commits de este cierre son locales; no se ejecutó un push en esta etapa.

## APK

Con el entorno y la firma local ya configurados:

```sh
flutter build apk --release
```

En esta máquina usar `.\tools\flutter.cmd` en lugar de `flutter`. Release lee `android/key.properties`, excluido de Git. La firma de distribución está configurada y validada: **reutilizar esta clave para las actualizaciones**, no crear otra. Respaldar el keystore y la contraseña fuera del repositorio. En otro equipo, restaurar esos archivos de forma privada. El procedimiento de creación inicial es `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\configurar_firma.ps1`, con contraseña ingresada únicamente en la terminal; no volver a ejecutarlo para reemplazar la firma existente. Ver [firma y validación Android](docs/cierre_android.md).

### Ubicación del APK

APK release real: `build/app/outputs/flutter-apk/app-release.apk`, **55.919.121 bytes (53,3 MiB)**. Versión **1.0.0+1**, firma de distribución válida (APK Signature Scheme v2); incluye `armeabi-v7a`, `arm64-v8a` y `x86_64`.

Ruta absoluta verificada: `C:/Users/Lenovo v15/OneDrive/Escritorio/Practicas profesionalizantes 2/incupoAPK/build/app/outputs/flutter-apk/app-release.apk`.
SHA-256: `bdcb0239da669f81281dce82f0b35714dabb4307e8ac1afa1a4672370a13174b`.
Nombre Android: **INCUPO Costos**. Identificador: `ar.org.incupo.incupo_costos`.
Icono oficial pendiente de recurso gráfico institucional; se mantiene el temporal de Flutter.

### Instalación

Transferir la APK al teléfono, abrirla, permitir la instalación desde esa fuente cuando Android lo solicite, instalar y abrir desde el icono. Completar un cálculo y verificar PDF, compartir, guardar y uso offline en esa instalación release. La prueba con `flutter run` no reemplaza esta comprobación.

## Funcionamiento offline

El motor, la interfaz y la generación PDF usan recursos locales, incluidas las fuentes Lato. No hay base de datos, cuentas ni servidor. Se comprobó cálculo, generación, vista previa y guardado PDF en el emulador con Wi-Fi y datos desactivados. Compartir hacia aplicaciones online puede necesitar conexión en la aplicación elegida. La validación en teléfono físico sigue pendiente.

## Qué se necesita para continuar

| Elemento | Estado y próxima acción |
|---|---|
| Android Studio, SDK, Java y licencias | Ya configurados. **No volver a instalarlos** en esta PC. Flutter usa `C:/Android/Sdk` y el JDK incluido con Android Studio. |
| Emulador | `INCUPO_API_36` disponible; cinco pruebas de integración aprobadas con Wi-Fi y datos desactivados. |
| Teléfono físico | Pendiente por disponibilidad. Android 7/API 24 o superior, cable USB de datos, opciones de desarrollador, depuración USB y autorización RSA de esta PC. No requiere cuenta para la app. |
| Clave de firma release | Creada y validada. Conservar y respaldar `%LOCALAPPDATA%/INCUPO/signing/incupo-release.jks`, su contraseña y `android/key.properties`; no recrearla. |
| APK release | Generada, firmada e instalada en emulador. Ruta real en la sección APK. |
| Validación final física | Completar cálculo, PDF, guardar/compartir, modo avión, teclado y pantallas; repetir smoke test con release instalada desde su icono. |
| Impresión física | Solo para probar salida en papel: impresora/servicio Android disponible. Guardar como PDF no requiere impresora física. |
| Icono oficial | Opcional; puede entregarse después. Se mantiene el temporal y no bloquea la compilación. |

No enviar archivos de firma ni contraseñas al chat o a Git. SDK, Java, licencias,
emulador y firma ya están preparados; no requieren nuevas instalaciones en esta PC.
Cuando haya teléfono, conectarlo y ejecutar `.\tools\flutter.cmd devices` para comprobar
su detección. Teléfono físico, icono institucional e impresora real son pendientes no
bloqueantes; no son funcionalidades faltantes del motor. Los detalles están en
[docs/cierre_android.md](docs/cierre_android.md).
