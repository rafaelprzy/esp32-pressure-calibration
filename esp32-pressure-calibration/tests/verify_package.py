"""Check retained source bytes and publication contents, using Python stdlib only."""
from pathlib import Path
import csv, hashlib, re, struct

root = Path(__file__).resolve().parents[1]
def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()
def check(ok, label):
    if not ok: raise AssertionError(label)
    print('PASS:', label)

with (root/'data/metadata/source_inventory.csv').open(encoding='utf-8', newline='') as f:
    inv = list(csv.DictReader(f))
raw_count = figure_count = 0
for row in inv:
    rel = row['source_relative_path']
    if rel.startswith('Data/raw/') and rel.endswith('.csv'):
        trial = Path(rel).stem
        phase = 'calibration' if trial.startswith('P') else 'validation'
        check(sha(root/'data/raw'/phase/(trial+'.csv')) == row['sha256'], trial+' original CSV SHA256')
        raw_count += 1
    if rel.startswith('Figures/Graphs/') and rel.endswith('.png'):
        check(sha(root/'figures/original'/Path(rel).name) == row['sha256'], Path(rel).name+' original PNG SHA256')
        figure_count += 1
check(raw_count == 14 and figure_count == 7, 'complete retained raw and original-figure inventory')
check(not list(root.rglob('config.h')), 'no private config.h in distribution')
check(not list(root.rglob('.Rhistory')) and not list(root.rglob('*.mp4')), 'interactive history and unreviewed video excluded')
check(not list(root.rglob('*.bin')) and not list(root.rglob('*.elf')), 'compiler products excluded')
sketch=(root/'firmware/esp32websensor/esp32websensor.ino').read_text(encoding='utf-8')
check('#include "config.h"' in sketch and not re.search(r'const char\* WIFI_(NAME|PASSWORD)\s*=',sketch), 'firmware credentials externalized')
text_files=[p for p in root.rglob('*') if p.is_file() and p.suffix.lower() in {'.md','.r','.ino','.h','.cff','.csv','.txt','.py','.yml','.yaml'}]
private_paths=[]
for p in text_files:
    text=p.read_text(encoding='utf-8-sig')
    if re.search(r'[A-Za-z]:[\\/](?:Users[\\/]|MSC-)',text): private_paths.append(p.relative_to(root).as_posix())
check(not private_paths, 'no machine-specific user/data paths in public text')

def png_chunks(p):
    b=p.read_bytes();i=8;names=[]
    while i+12<=len(b):
        n=struct.unpack('>I',b[i:i+4])[0];name=b[i+4:i+8];names.append(name);i+=12+n
    return names
for p in (root/'figures').rglob('*.png'):
    check(not any(c in png_chunks(p) for c in [b'eXIf',b'tEXt',b'zTXt',b'iTXt']),p.relative_to(root).as_posix()+' no textual or EXIF metadata')
for p in (root/'figures/apparatus').glob('*.jpg'):
    check(b'Exif\x00\x00' not in p.read_bytes() and b'http://ns.adobe.com/xap' not in p.read_bytes(),p.name+' no EXIF/XMP metadata')
check((root/'LICENSE').is_file() and (root/'LICENSE-DATA-DOCS.md').is_file() and (root/'CITATION.cff').is_file(),'license and citation files supplied')
check('Rafael Patrick' in (root/'CITATION.cff').read_text(encoding='utf-8') and 'rafaelprzy' in (root/'CITATION.cff').read_text(encoding='utf-8'),'confirmed author and requested profile used')
print('All package checks passed. This is an integrity check, not a live hardware test.')
