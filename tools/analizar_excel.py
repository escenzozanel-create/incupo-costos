"""Auditoría de solo lectura del XLSX, sin dependencias externas ni motor de app."""
from pathlib import Path
import ast
import hashlib
import json
import math
import re
import xml.etree.ElementTree as ET
import zipfile

ROOT = Path(__file__).resolve().parents[1]
SOURCE = next(ROOT.glob('*.xlsx'))
OUT = ROOT / 'docs'
OUT.mkdir(exist_ok=True)
NS = {'m': 'http://schemas.openxmlformats.org/spreadsheetml/2006/main'}
REF = re.compile(r"(?:(?:'([^']+)'!)?)(\$?[A-Z]+\$?\d+)(?::(\$?[A-Z]+\$?\d+))?")

def coord(address):
    letters, row = re.fullmatch(r'([A-Z]+)(\d+)', address.replace('$', '')).groups()
    col = 0
    for letter in letters:
        col = col * 26 + ord(letter) - 64
    return col, int(row)

def address(col, row):
    letters = ''
    while col:
        col, remainder = divmod(col - 1, 26)
        letters = chr(65 + remainder) + letters
    return letters + str(row)

def expand(start, end):
    c1, r1 = coord(start)
    c2, r2 = coord(end or start)
    return [address(c, r) for r in range(r1, r2 + 1) for c in range(c1, c2 + 1)]

def translate(formula, origin, target):
    c1, r1 = coord(origin)
    c2, r2 = coord(target)
    def shift(m):
        ca, letters, ra, row = m.groups()
        col, _ = coord(letters + row)
        dest = address(col if ca else col + c2 - c1, int(row) if ra else int(row) + r2 - r1)
        dl, dr = re.fullmatch(r'([A-Z]+)(\d+)', dest).groups()
        return ca + dl + ra + dr
    return re.sub(r'(\$?)([A-Z]+)(\$?)(\d+)', shift, formula)

book = {}
with zipfile.ZipFile(SOURCE) as z:
    strings = [''.join(e.itertext()) for e in ET.fromstring(z.read('xl/sharedStrings.xml')).findall('m:si', NS)]
    styles = ET.fromstring(z.read('xl/styles.xml'))
    xfs = styles.find('m:cellXfs', NS)
    workbook = ET.fromstring(z.read('xl/workbook.xml'))
    relationships = {e.get('Id'): e.get('Target') for e in ET.fromstring(z.read('xl/_rels/workbook.xml.rels'))}
    for sheet in workbook.find('m:sheets', NS):
        target = relationships[sheet.get('{http://schemas.openxmlformats.org/officeDocument/2006/relationships}id')]
        xml = ET.fromstring(z.read('xl/' + target))
        cells, shared = {}, {}
        for c in xml.findall('.//m:c', NS):
            f = c.find('m:f', NS)
            if f is not None and f.text and f.get('t') == 'shared':
                shared[f.get('si')] = (c.get('r'), f.text)
        for c in xml.findall('.//m:c', NS):
            value = c.findtext('m:v', default=None, namespaces=NS)
            if c.get('t') == 's':
                value = strings[int(value)]
            elif value is not None and c.get('t') != 'e':
                value = float(value)
            f = c.find('m:f', NS)
            formula = None
            if f is not None:
                formula = f.text or translate(shared[f.get('si')][1], shared[f.get('si')][0], c.get('r'))
            style = xfs[int(c.get('s', '0'))]
            cells[c.get('r')] = {'value': value, 'formula': formula, 'format_id': style.get('numFmtId'), 'fill_id': style.get('fillId')}
        book[sheet.get('name')] = cells
    metadata = {'sha256': hashlib.sha256(SOURCE.read_bytes()).hexdigest(), 'file': SOURCE.name,
                'sheets': [s.attrib for s in workbook.find('m:sheets', NS)],
                'calculation': workbook.find('m:calcPr', NS).attrib,
                'package_parts': z.namelist()}

evaluated, active, blanks, comparisons = {}, set(), [], []
def calculate(sheet, cell):
    key = (sheet, cell)
    if key in evaluated:
        return evaluated[key]
    if key in active:
        raise ValueError(f'Ciclo: {key}')
    c = book[sheet].get(cell, {})
    if not c.get('formula'):
        return c.get('value') if c.get('value') is not None else 0.0
    active.add(key)
    def replace(m):
        other = m.group(1) or sheet
        values = []
        for ref in expand(m.group(2), m.group(3)):
            source = book[other].get(ref, {})
            if source.get('value') is None and not source.get('formula'):
                blanks.append({'formula_sheet': sheet, 'formula_cell': cell, 'source_sheet': other, 'source_cell': ref})
            values.append(calculate(other, ref))
        return repr(sum(values)) if m.group(3) else repr(values[0])
    expr = REF.sub(replace, c['formula'])
    expr = expr.replace('SUM(', '(')
    tree = ast.parse(expr, mode='eval')
    permitted = (ast.Expression, ast.Constant, ast.BinOp, ast.UnaryOp, ast.Add, ast.Sub, ast.Mult, ast.Div, ast.UAdd, ast.USub, ast.Load)
    if any(not isinstance(n, permitted) for n in ast.walk(tree)):
        raise ValueError(f'Fórmula no soportada: {expr}')
    value = eval(compile(tree, '<formula auditada>', 'eval'), {'__builtins__': {}})
    assert math.isfinite(value)
    evaluated[key] = value
    active.remove(key)
    comparisons.append({'sheet': sheet, 'cell': cell, 'formula': '=' + c['formula'], 'cached': c['value'], 'calculated': value,
                        'matches': math.isclose(value, c['value'], rel_tol=1e-12, abs_tol=1e-8)})
    return value

for sheet, cells in book.items():
    for cell, data in cells.items():
        if data['formula']:
            calculate(sheet, cell)

report = {'metadata': metadata, 'cells': book, 'comparisons': comparisons, 'blank_references': blanks}
(OUT / 'auditoria_excel.json').write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf-8')
lines = ['# Inventario verificable del Excel', '', 'Generado por `python tools/analizar_excel.py`. El archivo original no se modifica.', '',
         f"SHA-256: `{metadata['sha256']}`", '',
         'Se expandieron las fórmulas compartidas y se evaluaron todas las fórmulas con sus dependencias. Los valores guardados son la caché del archivo, no una ejecución de Excel.', '']
for sheet, cells in book.items():
    lines += [f'## {sheet}', '', '| Celda | Valor guardado / texto | Fórmula expandida |', '|---|---|---|']
    for cell, data in cells.items():
        if data['value'] is not None or data['formula']:
            value = str(data['value']).replace('|', '\\|').replace('\n', ' ')
            lines.append(f"| {cell} | {value} | {('`=' + data['formula'] + '`') if data['formula'] else '—'} |")
lines += ['', '## Referencias a celdas vacías', '', '| Fórmula | Celda vacía |', '|---|---|']
for item in blanks:
    lines.append(f"| {item['formula_sheet']}!{item['formula_cell']} | {item['source_sheet']}!{item['source_cell']} |")
lines += ['', '## Comparación completa', '', '| Hoja / celda | Recalculado | Guardado | Coincide¹ |', '|---|---|---|---|']
for c in comparisons:
    lines.append(f"| {c['sheet']}!{c['cell']} | {c['calculated']} | {c['cached']} | {'Sí' if c['matches'] else 'NO'} |")
lines += ['', '¹ Tolerancia absoluta 1e-8 o relativa 1e-12; sin redondear las operaciones. No sustituye la futura validación del motor Dart.']
(OUT / 'inventario_excel.md').write_text('\n'.join(lines) + '\n', encoding='utf-8')
print(json.dumps({'formulas': len(comparisons), 'by_sheet': {s: sum(bool(c['formula']) for c in cs.values()) for s, cs in book.items()},
                  'all_match': all(c['matches'] for c in comparisons), 'blank_references': blanks, 'sha256': metadata['sha256']}, ensure_ascii=False, indent=2))
