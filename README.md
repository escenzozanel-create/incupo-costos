# INCUPO Costos

Calculadora de costos mensuales para emprendedores, basada en la planilla de INCUPO. El objetivo es una app Android en Flutter, offline, sin cuentas, servidor, base de datos ni historial persistente. El cálculo podrá conservarse mediante un PDF.

## Estado de esta entrega

Etapa inicial: proyecto Flutter/Android, modelos, motor Dart puro y pruebas matemáticas. La amortización está resuelta como costo fijo mensual manual. `main.dart` contiene solamente una presentación mínima, sin formularios ni navegación. Todavía **no** están implementados el asistente, el controller, el formato de resultados en pantalla ni el servicio PDF. No se generó una APK ni se probó en un teléfono.

Entorno utilizado: Flutter **3.47.5**, Dart **3.13.4**, canal stable. Dependencias resueltas en `pubspec.lock`.

## Preparar y ejecutar

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

La descarga inicial de herramientas y dependencias necesita internet. El motor no lo requiere al ejecutarse. Para Android faltan el Android SDK y un dispositivo/emulador: `flutter doctor -v` no detectó el SDK ni un teléfono Android. Consultar la [instalación oficial de Flutter](https://docs.flutter.dev/install/manual) y la [configuración oficial para Android](https://docs.flutter.dev/platform-integration/android/setup).

## Pruebas y validación

```sh
flutter test --coverage
flutter analyze
```

Se implementaron **47 pruebas** y pasaron. `flutter analyze` finalizó sin observaciones. El caso de pan compara los 12 resultados relevantes del Excel con tolerancia absoluta de `1e-8`, usando los valores completos, sin redondearlos previamente.

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

`porcentajeATasa(4)` devuelve `0.04`; el motor ya recibe la fracción y no vuelve a dividir por 100. No se redondean operaciones intermedias. La presentación argentina con dos decimales se implementará en la siguiente etapa, reutilizando los resultados completos para el PDF. Los resultados matemáticamente no disponibles incluyen `null` y un motivo legible, sin NaN/Infinity. Los datos inválidos o desbordamientos del cálculo principal producen `ValidacionException`.

## Estructura actual

```text
android/                         Base nativa generada por Flutter
lib/
  main.dart                      Entrada mínima de INCUPO
  models/
    item_costo.dart               Ítem inmutable, total derivado
    calculo_costos.dart           Producto mensual y listas inmutables
    resultado_calculo.dart       Resultados y motivos de no disponibilidad
  services/
    calculadora_service.dart     Matemática independiente de Flutter UI
  utils/
    validators.dart              Validaciones y mensajes
    porcentajes.dart             Conversión entre porcentaje y fracción
test/
  calculadora_service_test.dart   Pruebas de negocio y límites
  fixtures/caso_pan.dart          Datos del Excel
docs/
  analisis_excel.md               Análisis y decisión actualizada
  inventario_excel.md             Celdas, fórmulas y valores originales
  auditoria_excel.json            Evidencia estructurada
tools/
  analizar_excel.py              Auditoría de solo lectura del XLSX
  flutter.cmd                    Lanzador para Windows
```

El original `NUEVA PLANILLA DE COSTOS  PAN ultimo (1).xlsx` permanece en la raíz, intacto y versionado. El análisis detallado está en [docs/analisis_excel.md](docs/analisis_excel.md).

## Git

Repositorio local inicializado en la rama `main`. `.gitignore` excluye SDK, cachés, builds, configuración local y claves. `pubspec.lock`, fuentes, documentación y Excel se conservan. No se creó ni publicó un repositorio remoto de GitHub: no se proporcionó un destino.

## APK y próximas etapas

Cuando esté disponible el entorno Android:

```sh
flutter build apk --release
```

Salida esperada: `build/app/outputs/flutter-apk/app-release.apk`. También se puede usar `.\tools\flutter.cmd build apk --release` en Windows. El comando todavía no se validó aquí porque falta el Android SDK. La configuración generada utiliza temporalmente firma debug para release; antes de distribuir la versión final se debe configurar una clave de firma propia y conservarla fuera de Git. El icono sigue siendo el de la plantilla de Flutter.

Siguiente etapa: controller en memoria y asistente **Inicio → Producto → Variables → Fijos → Ganancia → Resultados**. Después, PDF offline con datos ya calculados, revisión de accesibilidad, icono, prueba en Android y APK. No agregar persistencia ni servicios externos.
