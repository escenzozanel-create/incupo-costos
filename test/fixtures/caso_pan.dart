import 'package:incupo_costos/models/calculo_costos.dart';
import 'package:incupo_costos/models/item_costo.dart';

/// Datos de COSTOS VARIABLES. Las filas opcionales vacías/cero no aportan costo.
CalculoCostos casoPan({double amortizacionMensual = 0}) => CalculoCostos(
  producto: 'Pan',
  cantidadMensual: 1560,
  unidadProduccion: 'kg',
  tasaGanancia: 0.04,
  costosVariables: const [
    ItemCosto(
      id: 'cv22',
      concepto: 'Harina Bolsa 25 kg',
      cantidad: 48,
      precioUnitario: 21900,
    ),
    ItemCosto(
      id: 'cv23',
      concepto: 'Levadura seca 20 gs',
      cantidad: 192,
      precioUnitario: 950,
    ),
    ItemCosto(
      id: 'cv24',
      concepto: 'Sal kg',
      cantidad: 24,
      precioUnitario: 1500,
    ),
    ItemCosto(
      id: 'cv25',
      concepto: 'Grasa kg',
      cantidad: 120,
      precioUnitario: 4450,
    ),
    ItemCosto(
      id: 'cv26',
      concepto: 'Gas tubo 45 kg',
      cantidad: 1,
      precioUnitario: 69000,
    ),
    ItemCosto(
      id: 'cv27',
      concepto: 'Bolsitas',
      cantidad: 1560,
      precioUnitario: 45,
    ),
    ItemCosto(
      id: 'cv35',
      concepto: 'Combustible',
      cantidad: 10,
      precioUnitario: 2045,
    ),
    ItemCosto(
      id: 'cv39',
      concepto: 'Jornales temporales',
      cantidad: 72,
      precioUnitario: 5830,
    ),
  ],
  costosFijos: [
    const ItemCosto(
      id: 'cf54',
      concepto: 'Remuneración propietario',
      cantidad: 1,
      precioUnitario: 850000,
    ),
    const ItemCosto(
      id: 'cf56',
      concepto: 'Seguros',
      cantidad: 1,
      precioUnitario: 9500,
    ),
    const ItemCosto(
      id: 'cf57',
      concepto: 'Servicios',
      cantidad: 1,
      precioUnitario: 75000,
    ),
    const ItemCosto(
      id: 'cf58',
      concepto: 'Monotributo',
      cantidad: 1,
      precioUnitario: 63000,
    ),
    const ItemCosto(
      id: 'cf59',
      concepto: 'Alquiler',
      cantidad: 1,
      precioUnitario: 150000,
    ),
    ItemCosto(
      id: 'cf60',
      concepto: 'Amortización de bienes',
      cantidad: 1,
      precioUnitario: amortizacionMensual,
    ),
  ],
);
