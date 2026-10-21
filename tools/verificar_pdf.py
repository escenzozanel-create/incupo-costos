"""Verifica PDFs del servicio Dart y los renderiza para inspección visual.

Ejecutar después de flutter test test/pdf_service_test.dart.
Necesita pypdf y pymupdf (se admiten dependencias locales en .local/python).
"""
from pathlib import Path
import json
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / '.local/python'))
import pymupdf
from pypdf import PdfReader

folder = ROOT / '.local/pdf-qa'
expected = {
    'pan': ['Pan', '28/09/2026', '1.560,00 kg', '4,00 %', 'Harina Bolsa 25 kg',
            '$ 2.383.010,00', '$ 1.147.500,00', '$ 3.530.510,00', '$ 1.527,57',
            '$ 2.263,15', '$ 90,53', '$ 2.353,67', '$ 3.671.730,40', '$ 141.220,40',
            '1.389,05 kg', 'Amortización de bienes'],
    'vacio': ['Producto sin gastos', 'No se cargaron costos en esta categoría.', '$ 0,00',
              'costo total es cero', 'el precio debe superar'],
    'sin_equilibrio': ['Producto al costo', 'Material', '$ 100,00', '$ 10,00', '0,00 %',
                      'el precio debe superar'],
    'largo': ['Insumo 1:', 'Insumo 90:', 'Amortización de bienes', '$ 25.000,00', 'unidades'],
}
report = {}
explicaciones = [
    'Suma de los costos variables y fijos del mes.',
    'Cuánto cuesta producir una unidad según la producción informada.',
    'Porcentaje de ganancia previsto sobre el costo.',
    'Precio orientativo para cubrir costos y alcanzar la ganancia proyectada.',
    'Monto que ingresaría si se venden las unidades al precio sugerido.',
    'Ganancia aproximada luego de descontar los costos, suponiendo que se vende toda la producción.',
    'Cantidad mínima de unidades que deben venderse para cubrir los costos.',
    'Los valores de ingresos y utilidad son estimaciones basadas en la producción y el precio informado. La aplicación no registra ventas reales.',
]
for name, snippets in expected.items():
    path = folder / f'{name}.pdf'
    reader = PdfReader(path)
    doc = pymupdf.open(path)
    text = ' '.join(' '.join(page.get_text().split()) for page in doc)
    # pypdf omite algunos espacios posicionados de estas fuentes; comparar
    # también sin espacios para verificar el contenido con ambos lectores.
    compact = ''.join(''.join(page.extract_text().split()) for page in reader.pages)
    for snippet in ['Calculadora de Costos',
                    'Desarrollado por estudiantes de 3er año de la Escuela Superior de Comercio N°43 – 2026',
                    'Precio sugerido', 'Costos variables', 'Costos fijos',
                    'Punto de equilibrio', *explicaciones, *snippets]:
        assert snippet in text, (name, 'Contenido ausente', snippet)
        assert ''.join(snippet.split()) in compact, (name, 'Contenido ausente en segundo lector', snippet)
    assert 'NaN' not in text and 'Infinity' not in text
    assert 'Ganancia estimada' not in text
    assert 'INCUPO Costos' not in text
    assert 'Proyección mensual' not in text
    assert 'Ingresos mensuales' in text
    if name in ['pan', 'largo']:
        assert 'Ganancia proyectada' in text
    if name in ['pan', 'vacio', 'sin_equilibrio']:
        assert len(reader.pages) == 1, (name, 'Debe entrar en una hoja A4')
    if name in ['vacio', 'sin_equilibrio']:
        assert 'Amortización de bienes' not in text
    if name == 'largo':
        assert len(reader.pages) > 1
        for i in range(1, 91):
            assert f'Insumo {i}:' in text
    for n, page in enumerate(doc, 1):
        assert f'Página {n} de {len(reader.pages)}' in ' '.join(page.get_text().split())
    for i, page in enumerate(doc):
        page.get_pixmap(matrix=pymupdf.Matrix(1.2, 1.2)).save(folder / f'{name}-{i+1}.png')
        # Detectar texto fuera de la página. La inspección visual complementa
        # esta comprobación: no pretende detectar por sí sola superposiciones.
        for block in page.get_text('blocks'):
            rect = pymupdf.Rect(block[:4])
            margen = pymupdf.Rect(23, 23, page.rect.width - 23, page.rect.height - 23)
            assert margen.contains(rect), (name, i + 1, 'Texto fuera de márgenes', rect)
    report[name] = {'pages': len(reader.pages), 'content_verified': True}
    (folder / f'{name}.txt').write_text(text, encoding='utf-8')
(folder / 'verificacion.json').write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf-8')
print(json.dumps(report, ensure_ascii=False, indent=2))
