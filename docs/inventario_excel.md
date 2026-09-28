# Inventario verificable del Excel

Generado por `python tools/analizar_excel.py`. El archivo original no se modifica.

SHA-256: `1f06ff91b8b4803d751a500dae819183eaaf022937de40dfe59b108ae0db3001`

Se expandieron las fórmulas compartidas y se evaluaron todas las fórmulas con sus dependencias. Los valores guardados son la caché del archivo, no una ejecución de Excel.

## COSTOS VARIABLES

| Celda | Valor guardado / texto | Fórmula expandida |
|---|---|---|
| B1 | PLANIFLLA PARA FIJAR COSTOS Y PRECIOS PARA ECONOMÍA SOCIAL  | — |
| B2 | (para trabajar con un producto a la vez) | — |
| B4 | Seguí estos 4 pasos. Solo completá SOLO LOS CASILLEROS PINTADOS EN VERDE | — |
| B7 | PASO - 1  | — |
| I7 | PASO - 3 | — |
| B8 | TU PRODUCCIÓN: ¿qué producto haces? ¿cuánto producis por mes?  | — |
| I8 | GANANCIA ¿cuánto pretendo ganar?  | — |
| B9 | Si conoces solo cuánto producis por semana multiplicalo por 4,  | — |
| B10 | si conoces la producción diaria muliplicalo por la cantidad de días producidas en el mes | — |
| I10 | GANANCIA - UTILIDAD porcentaje (Esperada) | — |
| K10 | 0.04 | — |
| I11 | GANANCIA por unidad (en pesos) | — |
| K11 | 90.52589743589745 | `=+C75*K10` |
| B12 | Bienes producidos: ej pan, pan dulce, dulces, remeras, etc | — |
| E12 | Cantidad producida por mes: kg, unidad, docenas, litros, etc.   En este casillero colocá solo números | — |
| G12 | 1560.0 | — |
| I13 | PASO - 4 | — |
| B14 | PASO - 2 | — |
| I14 | PRECIO: Determinar el precio  del producto (costo totsl unitario + Ganancia por unidad) | — |
| B15 | ¿EN QUÉ GASTÁS PARA PRODUCIR? (Costos) | — |
| B16 | Anotá TODO lo que usás para producir (aunque parezca poco)” | — |
| I16 | PRECIO FINAL POR UNIDAD  | — |
| K16 | 2353.6733333333336 | `=+C75+K11` |
| B17 | Cambiá los itms que aparecen en la planilla a modo de ejemplo. | — |
| B19 | A- COSTOS VARIABLES: Son los gastos que aumentan o disminuyen según cuánto producís. | — |
| I19 | PASO - 5 | — |
| I20 | INGRESOS MENSUAL  | — |
| B21 | Insumos | — |
| C21 | Cantidad | — |
| D21 | Precio Unitario | — |
| E21 | Total | — |
| B22 | Harina Bolsa 25 kg | — |
| C22 | 48.0 | — |
| D22 | 21900.0 | — |
| E22 | 1051200.0 | `=+C22*D22` |
| I22 | Producto o Servicio  | — |
| J22 | Cantidad | — |
| K22 | Precio Vta. | — |
| L22 | Total  | — |
| B23 | Levadura seca 20 gs | — |
| C23 | 192.0 | — |
| D23 | 950.0 | — |
| E23 | 182400.0 | `=+C23*D23` |
| B24 | Sal kg | — |
| C24 | 24.0 | — |
| D24 | 1500.0 | — |
| E24 | 36000.0 | `=+C24*D24` |
| I24 | PAN (KG) | — |
| J24 | 1560.0 | `=G12` |
| K24 | 2353.6733333333336 | `=+K16` |
| L24 | 3671730.4000000004 | `=+J24*K24` |
| B25 | Grasa kg | — |
| C25 | 120.0 | — |
| D25 | 4450.0 | — |
| E25 | 534000.0 | `=+C25*D25` |
| B26 | Gas tubo 45 kg | — |
| C26 | 1.0 | — |
| D26 | 69000.0 | — |
| E26 | 69000.0 | `=+C26*D26` |
| B27 | Bolsitas  | — |
| C27 | 1560.0 | — |
| D27 | 45.0 | — |
| E27 | 70200.0 | `=+C27*D27` |
| C28 | 0.0 | — |
| D28 | 0.0 | — |
| E28 | 0.0 | `=+C28*D28` |
| I28 | TOTAL ventas mensuales | — |
| L28 | 3671730.4000000004 | `=SUM(L24:L27)` |
| C29 | 0.0 | — |
| D29 | 0.0 | — |
| E29 | 0.0 | `=+C29*D29` |
| C30 | 0.0 | — |
| D30 | 0.0 | — |
| E30 | 0.0 | `=+C30*D30` |
| I30 | PASO - 6 | — |
| C31 | 0.0 | — |
| D31 | 0.0 | — |
| E31 | 0.0 | `=+C31*D31` |
| I31 | RESULTADO | — |
| C32 | 0.0 | — |
| D32 | 0.0 | — |
| E32 | 0.0 | `=+C32*D32` |
| C33 | 0.0 | — |
| D33 | 0.0 | — |
| E33 | 0.0 | `=+C33*D33` |
| I33 | CONCEPTOS | — |
| J33 | IMPORTE | — |
| B34 | Otros costos Variables | — |
| C34 | 0.0 | — |
| D34 | 0.0 | — |
| E34 | 0.0 | `=+C34*D34` |
| I34 | Ventas                                          | — |
| J34 | 3671730.4000000004 | `=+L28` |
| B35 | Combustible | — |
| C35 | 10.0 | — |
| D35 | 2045.0 | — |
| E35 | 20450.0 | `=+C35*D35` |
| I35 | Costos Totales                              | — |
| J35 | 3530510.0 | `=+C73` |
| B36 | Servicios  | — |
| C36 | 0.0 | — |
| D36 | 0.0 | — |
| E36 | 0.0 | `=+C36*D36` |
| I36 | Utilidad del Emprendimiento     | — |
| J36 | 141220.40000000037 | `=+J34-J35` |
| B37 | Viáticos | — |
| C37 | 0.0 | — |
| D37 | 0.0 | — |
| E37 | 0.0 | `=+C37*D37` |
| B38 | Transporte | — |
| C38 | 0.0 | — |
| D38 | 0.0 | — |
| E38 | 0.0 | `=+C38*D38` |
| I38 | GANANCIA LOGRADA | — |
| J38 | 0.040000000000000105 | `=+J36/J35` |
| B39 | Jornales Temporales | — |
| C39 | 72.0 | — |
| D39 | 5830.0 | — |
| E39 | 419760.0 | `=+C39*D39` |
| C40 | 0.0 | — |
| D40 | 0.0 | — |
| E40 | 0.0 | `=+C40*D40` |
| C41 | 0.0 | — |
| D41 | 0.0 | — |
| E41 | 0.0 | `=+C41*D41` |
| C42 | 0.0 | — |
| D42 | 0.0 | — |
| E42 | 0.0 | `=+C42*D42` |
| C43 | 0.0 | — |
| D43 | 0.0 | — |
| E43 | 0.0 | `=+C43*D43` |
| C44 | 0.0 | — |
| D44 | 0.0 | — |
| E44 | 0.0 | `=+C44*D44` |
| B45 |  Costos Variables Totales - CVT | — |
| E45 | 2383010.0 | `=SUM(E22:E44)` |
| B46 |  Costos Variables Unitarios - CVU | — |
| E46 | 1527.570512820513 | `=+E45/G12` |
| B49 | B- COSTOS FIJOS: Son los gastos que tenés aunque no produzcas nada.  | — |
| B50 | No cambian según la cantidad que producís. | — |
| B52 | Costos Fijos  | — |
| B53 | Concepto | — |
| C53 | Cantidad | — |
| D53 | Precio Unitario | — |
| E53 | Importe  | — |
| B54 | Remuneración del propietario  | — |
| C54 | 1.0 | — |
| D54 | 850000.0 | — |
| E54 | 850000.0 | `=+C54*D54` |
| B55 | Remuneración empleados fijos  | — |
| E55 | 0.0 | `=+C55*D55` |
| B56 | Seguros (Incendio) | — |
| C56 | 1.0 | — |
| D56 | 9500.0 | — |
| E56 | 9500.0 | `=+C56*D56` |
| B57 | Servicios (Luz , Agua, etc) | — |
| C57 | 1.0 | — |
| D57 | 75000.0 | — |
| E57 | 75000.0 | `=+C57*D57` |
| B58 | Impuestos Específicos -Montributo | — |
| C58 | 1.0 | — |
| D58 | 63000.0 | — |
| E58 | 63000.0 | `=+C58*D58` |
| B59 | Alquileres | — |
| C59 | 1.0 | — |
| D59 | 150000.0 | — |
| E59 | 150000.0 | `=+C59*D59` |
| B60 | Amortización de bienes (#) | — |
| E60 | 0.0 | `=+I77` |
| E61 | 0.0 | `=+C61*D61` |
| E62 | 0.0 | `=+C62*D62` |
| B63 | Otros | — |
| E63 | 0.0 | `=+C63*D63` |
| B64 | Total costos Fijos-   CFT | — |
| E64 | 1147500.0 | `=SUM(E54:E63)` |
| B67 | C- RESUMEN DE COSTOS Y CALCULO DEL COSTO UNITARIO DEL PRODUCTO | — |
| B68 | (Sin incluir la ganancia) | — |
| B70 | CONCEPTOS | — |
| C70 | IMPORTE | — |
| B71 | Costos Variables Totales | — |
| C71 | 2383010.0 | `=+E45` |
| B72 | Costos Fijos Totales | — |
| C72 | 1147500.0 | `=+E64` |
| B73 | Costos Totales  | — |
| C73 | 3530510.0 | `=SUM(C71:C72)` |
| B75 | COSTO TOTAL UNITARIO | — |
| C75 | 2263.147435897436 | `=+C73/G12` |
## PUNTO EQUILIBRIO

| Celda | Valor guardado / texto | Fórmula expandida |
|---|---|---|
| B2 | PUNTO DE EQUILIBRIO | — |
| B7 | PE= CFT/(PV-CVU) | — |
| B9 | CFT | — |
| C9 | 1147500.0 | `=+'COSTOS VARIABLES'!C72` |
| B10 | PV | — |
| C10 | 2353.6733333333336 | `=+'COSTOS VARIABLES'!K16` |
| D10 | 826.1028205128207 | `=+C10-C11` |
| B11 | CVU | — |
| C11 | 1527.570512820513 | `=+'COSTOS VARIABLES'!E46` |
| B13 | PE = | — |
| C13 | 1389.0522723160118 | `=+C9/(C10-C11)` |
| D13 | KG DE PAN | — |
| B15 | PE: Punto de  Equilibrio | — |
| B16 | PV: Precion de Venta | — |
| B17 | CVU: Costo Variable Unitario | — |

## Referencias a celdas vacías

| Fórmula | Celda vacía |
|---|---|
| COSTOS VARIABLES!E55 | COSTOS VARIABLES!C55 |
| COSTOS VARIABLES!E55 | COSTOS VARIABLES!D55 |
| COSTOS VARIABLES!E60 | COSTOS VARIABLES!I77 |
| COSTOS VARIABLES!E61 | COSTOS VARIABLES!C61 |
| COSTOS VARIABLES!E61 | COSTOS VARIABLES!D61 |
| COSTOS VARIABLES!E62 | COSTOS VARIABLES!C62 |
| COSTOS VARIABLES!E62 | COSTOS VARIABLES!D62 |
| COSTOS VARIABLES!E63 | COSTOS VARIABLES!C63 |
| COSTOS VARIABLES!E63 | COSTOS VARIABLES!D63 |
| COSTOS VARIABLES!L28 | COSTOS VARIABLES!L25 |
| COSTOS VARIABLES!L28 | COSTOS VARIABLES!L26 |
| COSTOS VARIABLES!L28 | COSTOS VARIABLES!L27 |

## Comparación completa

| Hoja / celda | Recalculado | Guardado | Coincide¹ |
|---|---|---|---|
| COSTOS VARIABLES!E22 | 1051200.0 | 1051200.0 | Sí |
| COSTOS VARIABLES!E23 | 182400.0 | 182400.0 | Sí |
| COSTOS VARIABLES!E24 | 36000.0 | 36000.0 | Sí |
| COSTOS VARIABLES!E25 | 534000.0 | 534000.0 | Sí |
| COSTOS VARIABLES!E26 | 69000.0 | 69000.0 | Sí |
| COSTOS VARIABLES!E27 | 70200.0 | 70200.0 | Sí |
| COSTOS VARIABLES!E28 | 0.0 | 0.0 | Sí |
| COSTOS VARIABLES!E29 | 0.0 | 0.0 | Sí |
| COSTOS VARIABLES!E30 | 0.0 | 0.0 | Sí |
| COSTOS VARIABLES!E31 | 0.0 | 0.0 | Sí |
| COSTOS VARIABLES!E32 | 0.0 | 0.0 | Sí |
| COSTOS VARIABLES!E33 | 0.0 | 0.0 | Sí |
| COSTOS VARIABLES!E34 | 0.0 | 0.0 | Sí |
| COSTOS VARIABLES!E35 | 20450.0 | 20450.0 | Sí |
| COSTOS VARIABLES!E36 | 0.0 | 0.0 | Sí |
| COSTOS VARIABLES!E37 | 0.0 | 0.0 | Sí |
| COSTOS VARIABLES!E38 | 0.0 | 0.0 | Sí |
| COSTOS VARIABLES!E39 | 419760.0 | 419760.0 | Sí |
| COSTOS VARIABLES!E40 | 0.0 | 0.0 | Sí |
| COSTOS VARIABLES!E41 | 0.0 | 0.0 | Sí |
| COSTOS VARIABLES!E42 | 0.0 | 0.0 | Sí |
| COSTOS VARIABLES!E43 | 0.0 | 0.0 | Sí |
| COSTOS VARIABLES!E44 | 0.0 | 0.0 | Sí |
| COSTOS VARIABLES!E45 | 2383010.0 | 2383010.0 | Sí |
| COSTOS VARIABLES!C71 | 2383010.0 | 2383010.0 | Sí |
| COSTOS VARIABLES!E54 | 850000.0 | 850000.0 | Sí |
| COSTOS VARIABLES!E55 | 0.0 | 0.0 | Sí |
| COSTOS VARIABLES!E56 | 9500.0 | 9500.0 | Sí |
| COSTOS VARIABLES!E57 | 75000.0 | 75000.0 | Sí |
| COSTOS VARIABLES!E58 | 63000.0 | 63000.0 | Sí |
| COSTOS VARIABLES!E59 | 150000.0 | 150000.0 | Sí |
| COSTOS VARIABLES!E60 | 0.0 | 0.0 | Sí |
| COSTOS VARIABLES!E61 | 0.0 | 0.0 | Sí |
| COSTOS VARIABLES!E62 | 0.0 | 0.0 | Sí |
| COSTOS VARIABLES!E63 | 0.0 | 0.0 | Sí |
| COSTOS VARIABLES!E64 | 1147500.0 | 1147500.0 | Sí |
| COSTOS VARIABLES!C72 | 1147500.0 | 1147500.0 | Sí |
| COSTOS VARIABLES!C73 | 3530510.0 | 3530510.0 | Sí |
| COSTOS VARIABLES!C75 | 2263.147435897436 | 2263.147435897436 | Sí |
| COSTOS VARIABLES!K11 | 90.52589743589745 | 90.52589743589745 | Sí |
| COSTOS VARIABLES!K16 | 2353.6733333333336 | 2353.6733333333336 | Sí |
| COSTOS VARIABLES!J24 | 1560.0 | 1560.0 | Sí |
| COSTOS VARIABLES!K24 | 2353.6733333333336 | 2353.6733333333336 | Sí |
| COSTOS VARIABLES!L24 | 3671730.4000000004 | 3671730.4000000004 | Sí |
| COSTOS VARIABLES!L28 | 3671730.4000000004 | 3671730.4000000004 | Sí |
| COSTOS VARIABLES!J34 | 3671730.4000000004 | 3671730.4000000004 | Sí |
| COSTOS VARIABLES!J35 | 3530510.0 | 3530510.0 | Sí |
| COSTOS VARIABLES!J36 | 141220.40000000037 | 141220.40000000037 | Sí |
| COSTOS VARIABLES!J38 | 0.040000000000000105 | 0.040000000000000105 | Sí |
| COSTOS VARIABLES!E46 | 1527.570512820513 | 1527.570512820513 | Sí |
| PUNTO EQUILIBRIO!C9 | 1147500.0 | 1147500.0 | Sí |
| PUNTO EQUILIBRIO!C10 | 2353.6733333333336 | 2353.6733333333336 | Sí |
| PUNTO EQUILIBRIO!C11 | 1527.570512820513 | 1527.570512820513 | Sí |
| PUNTO EQUILIBRIO!D10 | 826.1028205128207 | 826.1028205128207 | Sí |
| PUNTO EQUILIBRIO!C13 | 1389.0522723160118 | 1389.0522723160118 | Sí |

¹ Tolerancia absoluta 1e-8 o relativa 1e-12; sin redondear las operaciones. No sustituye la futura validación del motor Dart.
