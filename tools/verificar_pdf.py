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
    '¿Cuánto te cuesta producir?',
    'Costos del mes',
    'Costo por unidad',
    'Es el costo de producir',
    'Este precio cubre tus costos e incluye el',
    'Si vendés toda tu producción',
    'Ingresarías',
    'Utilidad mensual estimada',
    'Estos valores son estimaciones y suponen que se vende toda la producción.',
    'Otros datos del cálculo',
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
                    'Desarrollado por alumnos de 3er año Tec. Sup. en Desarrollo de Software - Escuela Superior de Comercio N°43 - 2026',
                    'Precio sugerido', 'Costos variables', 'Costos fijos',
                    'Fecha de emisión: 28/09/2026',
                    '¿Cuánto necesitás vender para cubrir tus costos?', *explicaciones, *snippets]:
        assert snippet in text, (name, 'Contenido ausente', snippet)
        assert ''.join(snippet.split()) in compact, (name, 'Contenido ausente en segundo lector', snippet)
    assert 'NaN' not in text and 'Infinity' not in text
    assert 'Ganancia estimada' not in text
    assert 'INCUPO Costos' not in text
    assert 'Proyección mensual' not in text
    assert 'Ingresos mensuales' in text
    if name in ['pan', 'largo']:
        assert 'Ganancia proyectada' in text
        assert 'A partir de esa cantidad cubrís los costos del mes.' in text
    if name == 'pan':
        assert 'Aproximadamente 1.390 kg' in text
        assert '1.389,05 kg exactos' in text
        assert 'Si vendés los 1.560,00 kg del mes al precio sugerido:' in text
        assert 'incluye el 4,00 % de ganancia que elegiste.' in text
    if name in ['pan', 'vacio', 'sin_equilibrio']:
        assert len(reader.pages) == 1, (name, 'Debe entrar en una hoja A4')
    if name in ['vacio', 'sin_equilibrio']:
        assert 'Amortización de bienes' not in text
    if name == 'largo':
        assert len(reader.pages) > 1
        for i in range(1, 91):
            assert f'Insumo {i}:' in text
    for n, page in enumerate(doc, 1):
        encabezados = page.search_for('Calculadora de Costos')
        assert len(encabezados) == 1, (name, n, 'Debe aparecer un título')
        centro_titulo = (encabezados[0].x0 + encabezados[0].x1) / 2
        assert abs(centro_titulo - page.rect.width / 2) < 0.5, (name, n, 'Título descentrado')
        creditos = [' '.join(block[4].split()) for block in page.get_text('blocks')
                    if 'Desarrollado por' in block[4]]
        assert creditos == ['Desarrollado por alumnos de 3er año Tec. Sup. en Desarrollo de Software - Escuela Superior de Comercio N°43 - 2026'], (name, n, 'Créditos incorrectos')
        assert page.get_text().count('Escuela Superior de Comercio') == 1, (name, n, 'Nombre de escuela duplicado')
        assert f'Página {n} de {len(reader.pages)}' in ' '.join(page.get_text().split())
        assert len(page.get_image_info()) == 3, (name, n, 'Deben aparecer los tres logos institucionales')
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
